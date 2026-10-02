// SPDX-License-Identifier: Apache-2.0

/// The JavaScript probes of `tool/a11y_check.dart`, run in the page by
/// headless Chrome. Each returns a JSON list of finding strings.
library;

/// Landmarks, headings, `lang`, names, images, ids and tabindex of one page.
/// `%LANG%` is replaced with the language the route table says the page has.
const structureProbe = r'''
(() => {
  const out = [];
  const q = (s) => [...document.querySelectorAll(s)];
  const shown = (e) => {
    const cs = getComputedStyle(e);
    return cs.display !== 'none' && cs.visibility !== 'hidden';
  };
  const hidden = (e) => !!e.closest('[aria-hidden="true"]') || !shown(e);
  const textOf = (e) => {
    let t = '';
    const walk = (n) => {
      if (n.nodeType === 3) t += n.textContent;
      else if (n.nodeType === 1 && !(n.getAttribute('aria-hidden') === 'true')) {
        if (n.tagName === 'IMG') t += n.getAttribute('alt') ?? '';
        else if (n.tagName === 'SVG' || n.tagName === 'svg') t += n.getAttribute('aria-label') ?? n.querySelector('title')?.textContent ?? '';
        else n.childNodes.forEach(walk);
      }
    };
    walk(e);
    return t.replace(/\s+/g, ' ').trim();
  };
  const nameOf = (e) => {
    const label = e.getAttribute('aria-label');
    if (label && label.trim()) return label.trim();
    const by = e.getAttribute('aria-labelledby');
    if (by) {
      const t = by.split(/\s+/).map((id) => document.getElementById(id)).filter(Boolean).map(textOf).join(' ').trim();
      if (t) return t;
    }
    return textOf(e);
  };

  // lang
  const lang = document.documentElement.getAttribute('lang');
  if (lang !== '%LANG%') out.push(`<html lang> is "${lang}", expected "%LANG%"`);
  for (const e of q('[lang]')) {
    if (e === document.documentElement) continue;
    if (!/^[a-z]{2,3}(-[A-Za-z0-9]+)*$/.test(e.getAttribute('lang'))) {
      out.push(`invalid lang="${e.getAttribute('lang')}" on <${e.tagName.toLowerCase()}>`);
    }
  }
  if (!document.title.trim()) out.push('empty <title>');

  // landmarks: exactly one banner, main and contentinfo; navs are named when
  // there is more than one; all content sits in a landmark (the skip link is
  // the one exception).
  const banners = q('body > header, [role="banner"]');
  const mains = q('main, [role="main"]');
  const infos = q('body > footer, [role="contentinfo"]');
  if (banners.length !== 1) out.push(`${banners.length} banner landmarks, expected 1`);
  if (mains.length !== 1) out.push(`${mains.length} main landmarks, expected 1`);
  if (infos.length !== 1) out.push(`${infos.length} contentinfo landmarks, expected 1`);
  const navs = q('nav, [role="navigation"]');
  if (navs.length > 1) {
    const names = navs.map(nameOf);
    names.forEach((n, i) => { if (!n) out.push(`navigation landmark #${i + 1} has no name`); });
    if (new Set(names).size !== names.length) out.push(`navigation landmarks share a name: ${names.join(' / ')}`);
  }
  for (const e of q('section[aria-labelledby], aside[aria-labelledby], [role="region"]')) {
    if (!nameOf(e)) out.push(`landmark <${e.tagName.toLowerCase()}> aria-labelledby points nowhere`);
  }
  if (mains[0] && !mains[0].hasAttribute('tabindex')) out.push('<main> is not focusable for the skip link');
  for (const e of document.body.children) {
    const tag = e.tagName.toLowerCase();
    if (['script', 'style', 'link', 'template', 'noscript'].includes(tag)) continue;
    if (['header', 'main', 'footer'].includes(tag)) continue;
    if (tag === 'a' && e.classList.contains('skip')) continue;
    out.push(`<${tag}> sits outside every landmark`);
  }
  const skip = document.querySelector('a.skip');
  if (!skip || skip !== q('a[href]')[0]) out.push('the skip link is not the first link');
  else {
    const target = document.getElementById(skip.getAttribute('href').slice(1));
    if (!target || target !== mains[0]) out.push('the skip link does not lead to <main>');
  }

  // headings: one h1, starts with it, no skipped level
  const heads = q('h1,h2,h3,h4,h5,h6').filter((h) => !hidden(h));
  const h1s = heads.filter((h) => h.tagName === 'H1');
  if (h1s.length !== 1) out.push(`${h1s.length} visible h1, expected 1`);
  if (heads[0] && heads[0].tagName !== 'H1') out.push(`first heading is ${heads[0].tagName}, not H1`);
  if (!h1s[0] || !h1s[0].closest('main')) out.push('the h1 is not inside <main>');
  let prev = 0;
  for (const h of heads) {
    const level = +h.tagName[1];
    if (prev && level > prev + 1) out.push(`heading jumps from H${prev} to H${level}: "${textOf(h).slice(0, 40)}"`);
    if (!textOf(h)) out.push(`empty <${h.tagName.toLowerCase()}>`);
    prev = level;
  }

  // names of interactive elements; link text that says nothing; same text,
  // different target
  const seen = new Map();
  for (const e of q('a[href], button, summary, [role="button"], input, select, textarea')) {
    if (hidden(e)) continue;
    const name = nameOf(e);
    const where = `<${e.tagName.toLowerCase()}${e.getAttribute('href') ? ` href="${e.getAttribute('href')}"` : ''}>`;
    if (!name) { out.push(`${where} has no accessible name`); continue; }
    if (/^(click here|here|more|read more|link|hier|mehr|weiterlesen)$/i.test(name)) out.push(`${where} is named "${name}"`);
    if (e.tagName === 'A') {
      const href = new URL(e.href, location.href).href;
      if (seen.has(name) && seen.get(name) !== href) out.push(`links named "${name}" lead to different targets`);
      seen.set(name, href);
      if (e.target === '_blank' && !/(noopener|noreferrer)/.test(e.rel)) out.push(`${where} opens a new tab without rel=noopener`);
    }
  }
  for (const e of q('[tabindex]')) {
    if (+e.getAttribute('tabindex') > 0) out.push(`positive tabindex on <${e.tagName.toLowerCase()}>`);
  }

  // images and inline svg: named, or explicitly decorative
  for (const e of q('img')) {
    if (!e.hasAttribute('alt')) out.push(`<img src="${e.getAttribute('src')}"> has no alt attribute`);
    else if (e.getAttribute('alt') === '' && e.closest('a, button') && !nameOf(e.closest('a, button'))) out.push(`decorative <img> is the only content of a link`);
  }
  for (const e of q('svg')) {
    if (e.closest('[aria-hidden="true"]')) continue;
    if (!(e.getAttribute('role') === 'img' && nameOf(e))) out.push('an inline <svg> is neither aria-hidden nor a named role=img');
  }

  // ids unique, references resolve
  const ids = q('[id]').map((e) => e.id);
  for (const id of new Set(ids.filter((id, i) => ids.indexOf(id) !== i))) out.push(`duplicate id "${id}"`);
  for (const e of q('[aria-labelledby], [aria-describedby], [aria-controls]')) {
    for (const attr of ['aria-labelledby', 'aria-describedby', 'aria-controls']) {
      for (const id of (e.getAttribute(attr) ?? '').split(/\s+/).filter(Boolean)) {
        if (!document.getElementById(id)) out.push(`${attr}="${id}" points at no element`);
      }
    }
  }

  // The copy never claims legal conformance (decision 21: "from the start" or
  // "barrierearm" wording only).
  const claim = /\b(WCAG|BFSG|BITV|EN 301 549)\b|(fully|completely|vollst(ä|ae)ndig) (accessible|barrierefrei)|(AA|AAA)[- ](konform|conform)|barrierefrei nach/i;
  const hit = document.body.innerText.match(claim);
  if (hit) out.push(`text claims accessibility conformance: "${hit[0]}"`);

  // FAQ disclosures are native <details>/<summary> with a name
  for (const d of q('details')) {
    const s = d.firstElementChild;
    if (!s || s.tagName !== 'SUMMARY') out.push('<details> without a <summary> as first child');
  }
  return out;
})()
''';

/// The tab stops of a page in document order (visible, focusable by Tab).
const stopsProbe = '''
(() => {
  const sel = 'a[href], button, summary, input, select, textarea, [tabindex]:not([tabindex="-1"])';
  return [...document.querySelectorAll(sel)].filter((e) => {
    const cs = getComputedStyle(e);
    const r = e.getBoundingClientRect();
    return !e.disabled && cs.display !== 'none' && cs.visibility !== 'hidden' && (r.width > 0 || r.height > 0);
  }).length;
})()
''';

/// The focused element's identity, order and focus indication.
const focusProbe = r'''
(() => {
  const sel = 'a[href], button, summary, input, select, textarea, [tabindex]:not([tabindex="-1"])';
  const stops = [...document.querySelectorAll(sel)].filter((e) => {
    const cs = getComputedStyle(e);
    const r = e.getBoundingClientRect();
    return !e.disabled && cs.display !== 'none' && cs.visibility !== 'hidden' && (r.width > 0 || r.height > 0);
  });
  const e = document.activeElement;
  const cs = getComputedStyle(e);
  const r = e.getBoundingClientRect();
  const vh = innerHeight, vw = innerWidth;
  const tag = e.tagName.toLowerCase();
  return {
    index: stops.indexOf(e),
    label: `<${tag}${e.getAttribute('href') ? ` href="${e.getAttribute('href')}"` : ''}>${(e.textContent || '').trim().slice(0, 30)}`,
    outlineStyle: cs.outlineStyle,
    outlineWidth: cs.outlineWidth,
    outlineColor: cs.outlineColor,
    boxShadow: cs.boxShadow,
    parentFilter: e.parentElement ? getComputedStyle(e.parentElement).filter : 'none',
    inView: r.bottom > 0 && r.top < vh && r.right > 0 && r.left < vw,
    obscured: (() => {
      const x = Math.min(Math.max(r.left + r.width / 2, 0), vw - 1);
      const y = Math.min(Math.max(r.top + r.height / 2, 0), vh - 1);
      const top = document.elementFromPoint(x, y);
      return !!top && top !== e && !e.contains(top) && !top.contains(e);
    })(),
  };
})()
''';

/// Rendered text contrast of every visible text node against its effective
/// background (WCAG 2 ratio: 4.5, or 3 for large text). Elements whose
/// backdrop is an image or gradient are counted, not judged.
const contrastProbe = r'''
(() => {
  const parse = (s) => {
    const m = s.match(/rgba?\(([^)]+)\)/);
    if (!m) return null;
    const p = m[1].split(/[ ,\/]+/).filter(Boolean).map(Number);
    return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 };
  };
  const over = (top, bot) => {
    const a = top.a + bot.a * (1 - top.a);
    const mix = (t, b) => (t * top.a + b * bot.a * (1 - top.a)) / (a || 1);
    return { r: mix(top.r, bot.r), g: mix(top.g, bot.g), b: mix(top.b, bot.b), a };
  };
  const lum = (c) => {
    const f = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
    return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
  };
  const ratio = (a, b) => {
    const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
    return (hi + 0.05) / (lo + 0.05);
  };
  const root = parse(getComputedStyle(document.documentElement).backgroundColor);
  const canvas = root && root.a > 0 ? root : parse(getComputedStyle(document.body).backgroundColor) ?? { r: 255, g: 255, b: 255, a: 1 };
  const backdrop = (e) => {
    let layers = [];
    for (let n = e; n && n.nodeType === 1; n = n.parentElement) {
      const cs = getComputedStyle(n);
      if (cs.backgroundImage !== 'none') return null;
      const c = parse(cs.backgroundColor);
      if (c && c.a > 0) { layers.push(c); if (c.a === 1) break; }
    }
    let acc = layers.length && layers[layers.length - 1].a === 1 ? layers.pop() : canvas;
    for (const l of layers.reverse()) acc = over(l, acc);
    return acc;
  };
  const out = [];
  let checked = 0, skipped = 0;
  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
  const done = new Set();
  for (let t = walker.nextNode(); t; t = walker.nextNode()) {
    if (!t.textContent.trim()) continue;
    const e = t.parentElement;
    if (!e || done.has(e) || ['SCRIPT', 'STYLE', 'TITLE'].includes(e.tagName)) continue;
    done.add(e);
    if (e.closest('[aria-hidden="true"]')) continue;
    const cs = getComputedStyle(e);
    const r = e.getBoundingClientRect();
    if (cs.display === 'none' || cs.visibility === 'hidden' || r.width <= 1 || r.height <= 1) continue;
    if (cs.webkitTextFillColor && cs.webkitTextFillColor !== cs.color && /rgba\(.*, 0\)|transparent/.test(cs.webkitTextFillColor)) { skipped++; continue; }
    const bg = backdrop(e);
    if (!bg) { skipped++; continue; }
    let fg = parse(cs.color);
    if (!fg) { skipped++; continue; }
    fg = over({ ...fg, a: fg.a * (+cs.opacity || 1) }, bg);
    const size = parseFloat(cs.fontSize);
    const bold = +cs.fontWeight >= 700;
    const large = size >= 24 || (size >= 18.66 && bold);
    const need = large ? 3 : 4.5;
    const got = ratio(fg, bg);
    checked++;
    if (got < need) out.push(`text "${t.textContent.trim().slice(0, 30)}" in <${e.tagName.toLowerCase()}${e.className ? '.' + String(e.className).split(' ')[0] : ''}>: contrast ${got.toFixed(2)}:1, needs ${need}:1`);
  }
  return { findings: out, checked, skipped };
})()
''';
