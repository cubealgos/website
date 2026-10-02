// SPDX-License-Identifier: Apache-2.0

// Lighthouse accessibility audits over the built site (`build/jaspr`, build
// first with `fvm dart run tool/build.dart`), served locally: every built HTML
// page, German and English, 404 pages included, as a phone and as a desktop.
// Accessibility category only; any failed accessibility audit fails the run.
//
// Run from the repo root: `npm --prefix tool/a11y ci` once, then
// `node tool/a11y/lighthouse_a11y.mjs [build-dir]`. `CHROME_PATH` picks the
// Chrome binary (the runner's preinstalled one by default).
import { createServer } from 'node:http';
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, relative, resolve, sep } from 'node:path';
import * as chromeLauncher from 'chrome-launcher';
import lighthouse, { desktopConfig } from 'lighthouse';

const root = resolve(process.argv[2] ?? 'build/jaspr');

const types = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.json': 'application/json',
  '.webmanifest': 'application/manifest+json',
  '.woff2': 'font/woff2',
  '.xml': 'application/xml',
  '.txt': 'text/plain; charset=utf-8',
};

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? walk(path) : [path];
  });
}

// Every built HTML page, as a URL path: `a/index.html` is `/a/`, the flat 404
// pages keep their file name (they are served with status 200 here).
const pages = walk(root)
  .filter((f) => f.endsWith('.html'))
  .map((f) => '/' + relative(root, f).split(sep).join('/'))
  .map((u) => u.replace(/index\.html$/, ''))
  .sort();

const server = createServer((req, res) => {
  const path = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  const file = path.endsWith('/') ? path + 'index.html' : path;
  try {
    const full = join(root, file);
    if (!full.startsWith(root)) throw new Error('outside root');
    const body = readFileSync(full);
    const ext = file.slice(file.lastIndexOf('.'));
    res.writeHead(200, { 'content-type': types[ext] ?? 'application/octet-stream' });
    res.end(body);
  } catch {
    res.writeHead(404).end('not found');
  }
});
await new Promise((ok) => server.listen(0, '127.0.0.1', ok));
const base = `http://127.0.0.1:${server.address().port}`;

const chrome = await chromeLauncher.launch({
  chromeFlags: ['--headless=new', '--no-sandbox', '--disable-gpu'],
});

const failures = [];
let runs = 0;
try {
  for (const form of ['mobile', 'desktop']) {
    for (const path of pages) {
      const flags = {
        port: chrome.port,
        output: 'json',
        logLevel: 'error',
        onlyCategories: ['accessibility'],
      };
      const result = await lighthouse(
        base + path,
        flags,
        form === 'desktop' ? desktopConfig : undefined,
      );
      const lhr = result.lhr;
      runs++;
      if (lhr.runtimeError) {
        failures.push(`${path} (${form}): ${lhr.runtimeError.message}`);
        continue;
      }
      const category = lhr.categories.accessibility;
      const failed = category.auditRefs
        .map((ref) => lhr.audits[ref.id])
        .filter((a) => a.score !== null && a.score < 1);
      for (const a of failed) {
        const items = (a.details?.items ?? [])
          .slice(0, 3)
          .map((i) => i.node?.snippet ?? i.node?.selector ?? '')
          .filter(Boolean)
          .join(' | ');
        failures.push(`${path} (${form}): ${a.id}: ${a.title} ${items}`);
      }
      console.log(
        `${String(Math.round(category.score * 100)).padStart(3)}  ${form.padEnd(7)} ${path}`,
      );
    }
  }
} finally {
  await chrome.kill();
  server.close();
}

if (failures.length > 0) {
  console.error(failures.join('\n'));
  console.error(`lighthouse_a11y: ${failures.length} failed audit(s).`);
  process.exit(1);
}
console.log(`lighthouse_a11y: ${runs} runs over ${pages.length} pages, no failed audit.`);
