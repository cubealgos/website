// SPDX-License-Identifier: Apache-2.0

// Headless-Chrome checks over the built site (build first:
// `fvm dart run tool/build.dart`). Serves build/jaspr on localhost and drives
// the system Chrome (`$CHROME`, `google-chrome`, or the macOS app):
//
//  * no horizontal scroll or off-screen element at 320/375/768/1280 px, every
//    page in both languages;
//  * a keyboard walkthrough of header and footer (skip link first and moving
//    focus to <main>, tab order = document order, a 2px focus ring in the
//    focus token on every stop) in light and dark;
//  * the language switch on every page lands on the same page in the other
//    language.
//
// `--screenshots <dir>` also writes Home EN/DE at 375 and 1280, light and dark.
// Run: `fvm dart run tool/browser_check.dart [--screenshots <dir>]`.
import 'dart:io';

import 'package:website/src/routes.dart';

import 'src/chrome.dart';
import 'src/static_server.dart';

const _widths = [320, 375, 768, 1280];

const _overflowProbe = '''
(() => {
  const w = innerWidth;
  const bad = [];
  for (const e of document.querySelectorAll('body *')) {
    if (e.classList.contains('skip')) continue;
    const r = e.getBoundingClientRect();
    if (r.width && (r.right > w + 0.5 || r.left < -0.5)) {
      bad.push(e.tagName.toLowerCase() + '.' + e.className + ' right=' + Math.round(r.right));
    }
  }
  return { scrollWidth: document.documentElement.scrollWidth, innerWidth: w, bad };
})()
''';

// The focus colour as the browser computes it, so it can be compared with the
// computed outline colour.
const _focusToken = '''
(() => {
  const probe = document.createElement('span');
  probe.style.color = getComputedStyle(document.documentElement).getPropertyValue('--color-focus').trim();
  document.body.append(probe);
  const c = getComputedStyle(probe).color;
  probe.remove();
  return c;
})()
''';

const _focusState = '''
(() => {
  const all = [...document.querySelectorAll('a[href],button')];
  const e = document.activeElement;
  const cs = getComputedStyle(e);
  const r = e.getBoundingClientRect();
  return {
    index: all.indexOf(e),
    count: all.length,
    skip: e.classList.contains('skip'),
    style: cs.outlineStyle,
    width: cs.outlineWidth,
    color: cs.outlineColor,
    visible: r.top >= 0 && r.bottom > 0,
  };
})()
''';

Future<void> main(List<String> args) async {
  final shots = args.contains('--screenshots')
      ? args[args.indexOf('--screenshots') + 1]
      : null;
  if (!Directory('build/jaspr').existsSync()) {
    stderr.writeln('browser_check: build/jaspr missing; build first.');
    exit(2);
  }
  final server = await serveDirectory('build/jaspr');
  final base = 'http://localhost:${server.port}';
  final chrome = await Chrome.launch();
  final page = await chrome.newPage();
  final failures = <String>[];

  final all = [
    for (final key in PageKey.values)
      for (final lang in Lang.values) (key: key, lang: lang),
  ];

  try {
    // 1. No horizontal scroll.
    for (final width in _widths) {
      await page.setViewport(width, 800);
      for (final r in all) {
        await page.goto('$base${pathFor(r.key, r.lang)}');
        final m = await page.evalMap(_overflowProbe);
        final where = '${pathFor(r.key, r.lang)} @$width';
        if ((m['scrollWidth']! as num) > (m['innerWidth']! as num)) {
          failures.add(
            'horizontal scroll: $where '
            '(scrollWidth ${m['scrollWidth']} > ${m['innerWidth']})',
          );
        }
        for (final b in m['bad']! as List<dynamic>) {
          failures.add('element outside the viewport: $where: $b');
        }
      }
    }

    // 2. Keyboard walkthrough, light and dark, one EN and one DE page.
    await page.setViewport(1280, 800);
    for (final dark in [false, true]) {
      await page.setMedia(dark: dark);
      for (final r in [
        (key: PageKey.about, lang: Lang.en),
        (key: PageKey.contact, lang: Lang.de),
      ]) {
        final where = '${pathFor(r.key, r.lang)} (${dark ? 'dark' : 'light'})';
        await page.goto('$base${pathFor(r.key, r.lang)}');
        final focus = await page.eval(_focusToken);
        final count =
            (await page.eval(
                  "document.querySelectorAll('a[href],button').length",
                ))!
                as int;
        for (var i = 0; i < count; i++) {
          await page.press('Tab');
          final s = await page.evalMap(_focusState);
          if (s['index'] != i) {
            failures.add('tab order: $where: stop $i focused #${s['index']}');
            break;
          }
          if (i == 0 && s['skip'] != true) {
            failures.add('skip link is not the first tab stop: $where');
          }
          if (i == 0 && s['visible'] != true) {
            failures.add('skip link is not visible when focused: $where');
          }
          if (s['style'] != 'solid' ||
              s['width'] != '2px' ||
              s['color'] != focus) {
            failures.add(
              'focus ring: $where: stop $i has '
              '${s['style']} ${s['width']} ${s['color']}, expected '
              'solid 2px $focus',
            );
          }
        }
        // The skip link moves focus to <main>.
        await page.goto('$base${pathFor(r.key, r.lang)}');
        await page.press('Tab');
        await page.press('Enter');
        // The fragment navigation moves focus asynchronously.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final id = await page.eval('document.activeElement.id');
        if (id != 'main') {
          failures.add('skip link did not focus main ($id): $where');
        }
      }
    }

    // 3. The language switch lands on the same page in the other language.
    await page.setMedia();
    for (final r in all) {
      await page.goto('$base${pathFor(r.key, r.lang)}');
      final loaded = page.waitForLoad();
      await page.eval(
        "document.querySelector('.site-header .lang-switch "
        "a:not([aria-current])').click()",
      );
      await loaded;
      final path = await page.eval('location.pathname');
      final lang = await page.eval('document.documentElement.lang');
      final want = pathFor(r.key, r.lang.other);
      if (path != want || lang != r.lang.other.code) {
        failures.add(
          'language switch: ${pathFor(r.key, r.lang)} -> $path ($lang), '
          'expected $want (${r.lang.other.code})',
        );
      }
    }

    // 4. Screenshots for review (optional).
    if (shots != null) {
      for (final lang in Lang.values) {
        for (final width in [375, 1280]) {
          for (final dark in [false, true]) {
            await page.setViewport(width, 800);
            await page.setMedia(dark: dark);
            await page.goto('$base${pathFor(PageKey.home, lang)}');
            await page.screenshot(
              '$shots/home-${lang.code}-$width-${dark ? 'dark' : 'light'}.png',
            );
          }
        }
      }
    }
  } finally {
    await chrome.close();
    await server.close(force: true);
  }

  if (failures.isNotEmpty) {
    failures.forEach(stderr.writeln);
    stderr.writeln('browser_check: ${failures.length} finding(s).');
    exit(1);
  }
  stdout.writeln(
    'browser_check: ${all.length} pages x ${_widths.length} widths, '
    'keyboard walkthrough, language switch ok.',
  );
}
