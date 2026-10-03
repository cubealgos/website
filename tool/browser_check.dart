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
//    language (on the 404 pages: on the home page of the other language);
//  * UI motion: the mark sting sits in the home hero's stack card (not in the
//    header, which has the same height on every page) and starts once the card
//    is in view, on a direct load and not when arriving from a page of this
//    site (same-origin referrer), with nothing written to session or local
//    storage; it is the still mark under reduced motion (a second
//    Chrome started with `--force-prefers-reduced-motion`); durations and
//    easings are the tokens; only transform, opacity and the underline's
//    background-size animate; button press and hover;
//  * reveal on scroll: scrolling each content page to the bottom leaves every
//    `.reveal` element at opacity 1; with reduced motion or JavaScript off
//    (`--blink-settings=scriptEnabled=false`) they are visible without
//    scrolling.
//
// `--screenshots <dir>` also writes the content pages EN/DE at 375 and 1280,
// light and dark.
// Run: `fvm dart run tool/browser_check.dart [--screenshots <dir>]`.
import 'dart:io';

import 'package:website/src/routes.dart';

import 'src/chrome.dart';
import 'src/static_server.dart';

const _widths = [320, 375, 768, 1280];

/// The pages `--screenshots` writes (EN and DE, 375 and 1280 px, light and
/// dark).
const List<PageKey> _shotPages = [
  PageKey.home,
  PageKey.about,
  PageKey.contact,
  PageKey.notFound,
];

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
  const all = [...document.querySelectorAll('a[href],button,summary')];
  const e = document.activeElement;
  const cs = getComputedStyle(e);
  const r = e.getBoundingClientRect();
  return {
    index: all.indexOf(e),
    count: all.length,
    skip: e.classList.contains('skip'),
    btn: e.classList.contains('btn'),
    filter: getComputedStyle(e.parentElement).filter,
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
        (key: PageKey.home, lang: Lang.de),
        (key: PageKey.about, lang: Lang.de),
        (key: PageKey.contact, lang: Lang.en),
      ]) {
        final where = '${pathFor(r.key, r.lang)} (${dark ? 'dark' : 'light'})';
        await page.goto('$base${pathFor(r.key, r.lang)}');
        final focus = await page.eval(_focusToken);
        final count =
            (await page.eval(
                  "document.querySelectorAll('a[href],button,summary').length",
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
          if (s['btn'] == true) {
            // A chamfered button: clip-path would clip an outline, so the ring
            // is a drop-shadow on the wrapper (and the outline is off).
            if (!'${s['filter']}'.contains('$focus')) {
              failures.add(
                'focus ring: $where: button stop $i has filter '
                '${s['filter']}, expected $focus',
              );
            }
          } else if (s['style'] != 'solid' ||
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
      final want = switchPath(r.key, r.lang.other);
      if (path != want || lang != r.lang.other.code) {
        failures.add(
          'language switch: ${pathFor(r.key, r.lang)} -> $path ($lang), '
          'expected $want (${r.lang.other.code})',
        );
      }
    }

    // 4. UI motion.
    failures.addAll(await _motionChecks(chrome, base, reduced: false));
    final calm = await Chrome.launch(args: ['--force-prefers-reduced-motion']);
    try {
      failures.addAll(await _motionChecks(calm, base, reduced: true));
    } finally {
      await calm.close();
    }

    // 4a. Reveal on scroll: scrolled through, with reduced motion, JS off.
    failures.addAll(await _revealChecks(chrome, base, mode: _Reveal.scroll));
    final calmReveal = await Chrome.launch(
      args: ['--force-prefers-reduced-motion'],
    );
    try {
      failures.addAll(
        await _revealChecks(calmReveal, base, mode: _Reveal.reduced),
      );
    } finally {
      await calmReveal.close();
    }
    final noJs = await Chrome.launch(
      args: ['--blink-settings=scriptEnabled=false'],
    );
    try {
      failures.addAll(await _revealChecks(noJs, base, mode: _Reveal.noScript));
    } finally {
      await noJs.close();
    }

    // 4b. Unknown paths: the server falls back to the 404 page of the path's
    // language (German, or English below /en/), from any depth, and the page
    // renders with its styles and fish.
    for (final probe in [
      (path: '/xyz', h1: 'Diese Seite ist davongeschwommen.'),
      (
        path: '/some/deep/missing/path',
        h1: 'Diese Seite ist davongeschwommen.',
      ),
      (path: '/en/xyz', h1: 'This page swam off.'),
      (path: '/en/some/deep/missing/path', h1: 'This page swam off.'),
    ]) {
      await page.setViewport(1280, 800);
      await page.goto('$base${probe.path}');
      final s = await page.evalMap('''
(() => ({
  h1: document.querySelector('h1')?.textContent,
  fishLoaded: [...document.querySelectorAll('img.fish-img')].every(i => i.complete && i.naturalWidth > 0),
  styled: getComputedStyle(document.body).backgroundColor !== 'rgba(0, 0, 0, 0)',
}))()
''');
      if (s['h1'] != probe.h1 ||
          s['fishLoaded'] != true ||
          s['styled'] != true) {
        failures.add('unknown path ${probe.path}: $s');
      }
    }

    // 6. The favicon set loads without a 404 and the SVG mark switches to
    // paper in a dark browser theme.
    failures.addAll(await _iconChecks(page, base));

    // 5. Screenshots for review (optional).
    if (shots != null) {
      for (final key in _shotPages) {
        for (final lang in Lang.values) {
          for (final width in [375, 1280]) {
            for (final dark in [false, true]) {
              // A fresh tab has no referrer: the home sting plays once the
              // card is in view; shoot it frozen 1.3 s after it starts, then
              // at rest.
              final shot = await chrome.newPage();
              await shot.setViewport(width, 800);
              await shot.setMedia(dark: dark);
              await shot.goto('$base${pathFor(key, lang)}');
              final mode = dark ? 'dark' : 'light';
              final name = '${key.name}-${lang.code}-$width-$mode';
              if (key == PageKey.home) {
                await shot.eval(
                  "document.querySelector('.ledger').scrollIntoView()",
                );
                for (var i = 0; i < 40; i++) {
                  final on = await shot.eval(
                    "!!document.querySelector('.cas-mark.is-playing')",
                  );
                  if (on == true) break;
                  await Future<void>.delayed(const Duration(milliseconds: 50));
                }
                await Future<void>.delayed(const Duration(milliseconds: 1300));
                await shot.eval(
                  'document.getAnimations().forEach(a => a.pause())',
                );
                await shot.screenshot('$shots/$name-sting-mid.png');
                await shot.eval(
                  'document.getAnimations().forEach(a => a.play())',
                );
              }
              await Future<void>.delayed(
                Duration(milliseconds: key == PageKey.home ? 1500 : 400),
              );
              await shot.screenshot('$shots/$name.png');
            }
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

// --- Reveal on scroll --------------------------------------------------------

enum _Reveal { scroll, reduced, noScript }

const _revealState = '''
(() => {
  const els = [...document.querySelectorAll('.reveal')];
  return {
    count: els.length,
    on: document.documentElement.classList.contains('reveal-on'),
    hidden: els.filter(e => getComputedStyle(e).opacity !== '1').length,
    moved: els.filter(e => getComputedStyle(e).transform !== 'none').length,
    storage: sessionStorage.length + localStorage.length,
  };
})()
''';

Future<List<String>> _revealChecks(
  Chrome chrome,
  String base, {
  required _Reveal mode,
}) async {
  final out = <String>[];
  for (final key in [PageKey.home, PageKey.about, PageKey.contact]) {
    for (final lang in Lang.values) {
      for (final width in [375, 1280]) {
        final where = '${pathFor(key, lang)} @$width (${mode.name})';
        final page = await chrome.newPage();
        await page.setViewport(width, 800);
        await page.setMedia(
          reducedMotion: mode == _Reveal.scroll ? false : null,
        );
        await page.goto('$base${pathFor(key, lang)}');
        await Future<void>.delayed(const Duration(milliseconds: 600));
        final first = await page.evalMap(_revealState);
        if ((first['count']! as int) == 0) {
          out.add('$where: no .reveal elements');
          continue;
        }
        if (mode != _Reveal.scroll) {
          if (first['on'] == true || first['hidden'] != 0) {
            out.add('$where: not visible without scrolling: $first');
          }
          continue;
        }
        if (first['on'] != true) out.add('$where: reveal-on missing: $first');
        // Content below the fold waits for its first view.
        if ((first['hidden']! as int) == 0) {
          out.add('$where: nothing waits below the fold: $first');
        }
        // Scroll through in steps, as a visitor does.
        final height =
            (await page.eval('document.documentElement.scrollHeight'))! as num;
        for (var y = 0; y < height; y += 300) {
          await page.eval('scrollTo(0, $y)');
          await Future<void>.delayed(const Duration(milliseconds: 60));
        }
        await page.eval('scrollTo(0, document.documentElement.scrollHeight)');
        await Future<void>.delayed(const Duration(milliseconds: 900));
        final end = await page.evalMap(_revealState);
        if (end['hidden'] != 0 || end['moved'] != 0) {
          out.add('$where: not all revealed at the bottom: $end');
        }
        // Once: scrolling back up leaves everything shown.
        await page.eval('scrollTo(0, 0)');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final back = await page.evalMap(_revealState);
        if (back['hidden'] != 0 || back['storage'] != 0) {
          out.add('$where: re-hidden or stored on the way back: $back');
        }
      }
    }
  }
  return out;
}

// --- Icons -------------------------------------------------------------------

const _iconProbe = '''
(async () => {
  const out = [];
  const hrefs = [...document.querySelectorAll(
    'link[rel~="icon"],link[rel="apple-touch-icon"],link[rel="manifest"]')]
    .map(l => l.href);
  for (const href of hrefs) {
    const r = await fetch(href);
    out.push(href + ' ' + r.status);
  }
  const m = await (await fetch(document.querySelector(
    'link[rel="manifest"]').href)).json();
  for (const i of m.icons) {
    const r = await fetch(i.src);
    out.push(new URL(i.src, location.href).href + ' ' + r.status);
  }
  return out;
})()
''';

const _svgPixel = '''
new Promise((resolve, reject) => {
  const img = new Image();
  img.onload = () => {
    const c = document.createElement('canvas');
    c.width = 64; c.height = 64;
    const x = c.getContext('2d');
    x.drawImage(img, 0, 0, 64, 64);
    const d = x.getImageData(4, 4, 1, 1).data;
    resolve([d[0], d[1], d[2], d[3]]);
  };
  img.onerror = () => reject(new Error('favicon.svg did not load'));
  img.src = '/brand/favicon/favicon.svg';
})
''';

Future<List<String>> _iconChecks(ChromePage page, String base) async {
  final failures = <String>[];
  await page.setViewport(1280, 800);
  await page.setMedia();
  for (final r in [
    (key: PageKey.home, lang: Lang.de),
    (key: PageKey.impressum, lang: Lang.en),
  ]) {
    await page.goto('$base${pathFor(r.key, r.lang)}');
    final results = (await page.eval(_iconProbe))! as List<dynamic>;
    if (results.length < 8) {
      failures.add('icons: ${pathFor(r.key, r.lang)}: only $results');
    }
    for (final line in results) {
      if (!'$line'.endsWith(' 200')) failures.add('icons: $line');
    }
  }
  // The mark is ink in a light theme and paper in a dark one.
  for (final dark in [false, true]) {
    await page.setMedia(dark: dark);
    await page.goto('$base/');
    final px = (await page.eval(_svgPixel))! as List<dynamic>;
    final want = dark ? [0xED, 0xEE, 0xF1, 255] : [0x16, 0x18, 0x1D, 255];
    if ('$px' != '$want') {
      failures.add(
        'favicon.svg ${dark ? 'dark' : 'light'}: pixel $px, '
        'expected $want',
      );
    }
  }
  await page.setMedia();
  return failures;
}

// --- UI motion ---------------------------------------------------------------

final String _tokens = File('web/brand/tokens.css').readAsStringSync();

String _token(String name) =>
    RegExp('$name:\\s*([^;]+);').firstMatch(_tokens)![1]!.trim();

/// `900ms` -> `0.9s`, how Chrome reports computed times.
String _seconds(String ms) => '${int.parse(ms.replaceAll('ms', '')) / 1000}s';

/// `cubic-bezier(.2,.8,.3,1)` -> `cubic-bezier(0.2, 0.8, 0.3, 1)`.
String _bezier(String token) {
  final n = RegExp(r'[\d.]+')
      .allMatches(token.substring(token.indexOf('(')))
      .map((m) => num.parse(m[0]!))
      .join(', ');
  return 'cubic-bezier($n)';
}

/// Clicks the site's own link to [path] (so the next page has a same-origin
/// referrer, which `Page.navigate` would not give) and waits for the load.
Future<void> _clickTo(ChromePage page, String path) async {
  final loaded = page.waitForLoad();
  final found = await page.eval(
    "(() => { const a = document.querySelector('a[href=\"$path\"]'); "
    'if (a) a.click(); return !!a; })()',
  );
  if (found != true) throw StateError('no link to $path on the page');
  await loaded;
}

const _stingState = '''
(() => {
  const mark = document.querySelector('.cas-mark');
  const outline = document.querySelector('.cas-outline');
  const outlineStyle = outline ? getComputedStyle(outline) : null;
  return {
    inCard: !!document.querySelector('.ledger-head .ledger-mark .cas-mark'),
    inHeader: !!document.querySelector('.site-header .cas-mark'),
    marks: document.querySelectorAll('.cas-mark').length,
    logos: document.querySelectorAll('.site-header img.logo').length,
    headerHeight: document.querySelector('.site-header').getBoundingClientRect().height,
    armed: document.documentElement.classList.contains('sting-play'),
    playing: !!mark && mark.classList.contains('is-playing'),
    animName: outlineStyle ? outlineStyle.animationName : null,
    playState: outlineStyle ? outlineStyle.animationPlayState : null,
    markWidth: document.querySelector('.ledger-mark')
      ? document.querySelector('.ledger-mark').getBoundingClientRect().width : null,
    sessionLen: sessionStorage.length,
    localLen: localStorage.length,
    scripts: document.scripts.length,
  };
})()
''';

const _faqProbe = '''
(() => {
  const d = document.querySelector('.faq details');
  const summary = d.querySelector('summary');
  const answer = d.querySelector('p');
  const icon = getComputedStyle(summary, '::after');
  const props = new Set();
  for (const a of answer.getAnimations()) {
    for (const k of a.effect.getKeyframes()) {
      for (const p of Object.keys(k)) {
        if (!['offset', 'computedOffset', 'easing', 'composite'].includes(p)) props.add(p);
      }
    }
  }
  const style = getComputedStyle(answer);
  return {
    open: d.open,
    answerAnimations: answer.getAnimations().length,
    answerProps: [...props].sort(),
    answerName: style.animationName,
    answerDuration: style.animationDuration,
    answerEasing: style.animationTimingFunction,
    iconDuration: icon.transitionDuration,
    iconEasing: icon.transitionTimingFunction,
    iconProperty: icon.transitionProperty,
    iconMatrix: icon.transform,
  };
})()
''';

const _motionProbe = '''
(() => {
  const css = (el, prop, pseudo) => getComputedStyle(el, pseudo)[prop];
  const rise = document.querySelector('.rise');
  const mark = document.querySelector('.mark');
  const btn = document.querySelector('.btn');
  const props = new Set();
  for (const a of document.getAnimations()) {
    for (const k of a.effect.getKeyframes()) {
      for (const p of Object.keys(k)) {
        if (!['offset', 'computedOffset', 'easing', 'composite'].includes(p)) props.add(p);
      }
    }
  }
  return {
    animations: document.getAnimations().length,
    animatedProps: [...props].sort(),
    riseName: css(rise, 'animationName'),
    riseDuration: css(rise, 'animationDuration'),
    riseEasing: css(rise, 'animationTimingFunction'),
    markName: css(mark, 'animationName'),
    markDuration: css(mark, 'animationDuration'),
    markEasing: css(mark, 'animationTimingFunction'),
    pressDuration: css(btn, 'transitionDuration'),
    pressEasing: css(btn, 'transitionTimingFunction'),
    hoverDuration: css(btn, 'transitionDuration', '::before'),
    hoverEasing: css(btn, 'transitionTimingFunction', '::before'),
    staggerDelays: [...document.querySelectorAll('.rise')].map(e => css(e, 'animationDelay')),
    btnRect: (() => { const r = btn.getBoundingClientRect(); return [r.x + r.width / 2, r.y + r.height / 2]; })(),
  };
})()
''';

Future<List<String>> _motionChecks(
  Chrome chrome,
  String base, {
  required bool reduced,
}) async {
  final out = <String>[];
  final mode = reduced ? 'reduced motion' : 'motion';
  Future<ChromePage> session({bool dark = false}) async {
    final page = await chrome.newPage();
    await page.setViewport(1280, 800);
    // The reduced-motion Chrome keeps its command-line flag; the other one
    // emulates no preference.
    await page.setMedia(dark: dark, reducedMotion: reduced ? null : false);
    return page;
  }

  for (final lang in Lang.values) {
    final home = '$base${pathFor(PageKey.home, lang)}';
    final where = '${pathFor(PageKey.home, lang)} ($mode)';
    // The header is the same height on every page: home against the others.
    double? headerOf(Map<String, Object?> m) =>
        (m['headerHeight'] as num?)?.toDouble();
    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      // Phone width: the card is below the fold, so the sting waits for it.
      final page = await session(dark: dark);
      await page.setViewport(375, 500);
      await page.goto(home);
      final first = await page.evalMap(_stingState);
      final probe = await page.evalMap(_motionProbe);
      // The sting is in the card, once, and not in the header.
      if (first['inCard'] != true ||
          first['inHeader'] == true ||
          first['marks'] != 1 ||
          first['logos'] != 2) {
        out.add('$where ($theme): the sting is not only in the card: $first');
      }
      if (reduced) {
        if (first['armed'] == true ||
            first['playing'] == true ||
            first['animName'] != 'none') {
          out.add('$where: sting is not the still: $first');
        }
        if (probe['animations'] != 0 ||
            probe['riseName'] != 'none' ||
            probe['markName'] != 'none' ||
            probe['pressDuration'] != '0s' ||
            probe['hoverDuration'] != '0s') {
          out.add('$where: something still animates: $probe');
        }
        continue;
      }
      // A direct load: armed, but not started while the card is off screen.
      if (first['armed'] != true || first['playing'] == true) {
        out.add('$where ($theme): sting not waiting for the card: $first');
      }
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if ((await page.evalMap(_stingState))['playing'] == true) {
        out.add('$where ($theme): sting started while off screen');
      }
      // Scrolled into view: it starts (after the card has faded in).
      await page.eval("document.querySelector('.ledger').scrollIntoView()");
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final started = await page.evalMap(_stingState);
      if (started['playing'] != true || started['playState'] != 'running') {
        out.add('$where ($theme): sting did not start in view: $started');
      }
      final width = (started['markWidth'] as num?)?.toDouble() ?? 0;
      if ((width - 40).abs() > 1) {
        out.add('$where ($theme): mark is $width px wide, expected 40');
      }
      // Home -> About -> Home through the site's own links: the second home
      // load has a same-origin referrer, so the still, no replay.
      await page.setViewport(1280, 800);
      final homeHeader = headerOf(await page.evalMap(_stingState));
      await _clickTo(page, pathFor(PageKey.about, lang));
      final about = await page.evalMap(_stingState);
      if (about['marks'] != 0 || about['scripts'] != 1) {
        out.add(
          '${pathFor(PageKey.about, lang)}: sting on another page: $about',
        );
      }
      if (headerOf(about) != homeHeader) {
        out.add(
          '$where ($theme): header height $homeHeader on home, '
          '${headerOf(about)} on About',
        );
      }
      await _clickTo(page, pathFor(PageKey.home, lang));
      final back = await page.evalMap(_stingState);
      if (back['armed'] == true ||
          back['playing'] == true ||
          back['animName'] != 'none') {
        out.add('$where ($theme): sting replays on return to home: $back');
      }
      await page.eval("document.querySelector('.ledger').scrollIntoView()");
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if ((await page.evalMap(_stingState))['playing'] == true) {
        out.add('$where ($theme): sting plays after on-site navigation');
      }
      // A reload keeps the same-origin referrer but is an arrival: it plays.
      final reloaded = page.waitForLoad();
      await page.eval('location.reload()');
      await reloaded;
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if ((await page.evalMap(_stingState))['playing'] != true) {
        out.add('$where ($theme): a reload does not play the sting');
      }
      // Nothing is written to any storage over the whole walk.
      if (back['sessionLen'] != 0 || back['localLen'] != 0) {
        out.add('$where ($theme): storage written: $back');
      }
      // A direct load in a fresh tab (no referrer) at desktop width: the card
      // is in view, so it starts by itself.
      final fresh = await session(dark: dark);
      await fresh.goto(home);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      final freshState = await fresh.evalMap(_stingState);
      if (freshState['playing'] != true) {
        out.add('$where ($theme): a direct load does not play the sting');
      }
      if (freshState['sessionLen'] != 0 || freshState['localLen'] != 0) {
        out.add('$where ($theme): storage written on direct load');
      }
    }
    // Every other page has no sting, whatever the session.
    for (final key in PageKey.values.where((k) => k != PageKey.home)) {
      final page = await session();
      await page.goto('$base${pathFor(key, lang)}');
      final s = await page.evalMap(_stingState);
      // The content pages carry reveal.js (one script), the rest none.
      final scripts = {PageKey.about, PageKey.contact}.contains(key) ? 1 : 0;
      if (s['marks'] != 0 || s['scripts'] != scripts) {
        out.add('${pathFor(key, lang)} ($mode): sting on a non-home page: $s');
      }
    }
  }

  // FAQ: the answer fades in and rises (opacity/transform, base, settle) and
  // the "+" turns a quarter (quick, settle); none of it with reduced motion.
  for (final lang in Lang.values) {
    final page = await session();
    await page.goto('$base${pathFor(PageKey.home, lang)}');
    await page.eval("document.querySelector('.faq details').scrollIntoView()");
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await page.eval("document.querySelector('.faq summary').click()");
    final mid = await page.evalMap(_faqProbe);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final done = await page.evalMap(_faqProbe);
    final where = '${pathFor(PageKey.home, lang)} FAQ ($mode)';
    final turned = ((done['iconMatrix'] as String?) ?? '').startsWith(
      'matrix(0.70',
    );
    if (done['open'] != true || !turned) {
      out.add('$where: the opened item is not settled with a ×: $done');
    }
    if (reduced) {
      if (mid['answerAnimations'] != 0 ||
          mid['answerName'] != 'none' ||
          mid['iconDuration'] != '0s') {
        out.add('$where: the opening still animates: $mid');
      }
      continue;
    }
    if (mid['answerAnimations'] != 1 ||
        '${mid['answerProps']}' != '[opacity, transform]') {
      out.add('$where: answer animation is not opacity/transform only: $mid');
    }
    if (mid['answerDuration'] != _seconds(_token('--duration-base')) ||
        mid['answerEasing'] != _bezier(_token('--ease-settle'))) {
      out.add('$where: answer motion is not base/settle: $mid');
    }
    if (mid['iconDuration'] != _seconds(_token('--duration-quick')) ||
        mid['iconEasing'] != _bezier(_token('--ease-settle'))) {
      out.add('$where: icon motion is not quick/settle: $mid');
    }
    if (mid['iconProperty'] != 'transform') {
      out.add('$where: icon transitions ${mid['iconProperty']}: $mid');
    }
  }

  if (reduced) return out;

  // Tokens on the real elements, transform/opacity (and background-size), stagger, press, hover.
  final page = await session();
  await page.goto('$base${pathFor(PageKey.home, Lang.de)}');
  final p = await page.evalMap(_motionProbe);
  void expectEq(String what, Object? got, Object want) {
    if (got != want) out.add('motion: $what is $got, expected $want');
  }

  expectEq(
    'rise duration',
    p['riseDuration'],
    _seconds(_token('--duration-base')),
  );
  expectEq('rise easing', p['riseEasing'], _bezier(_token('--ease-settle')));
  expectEq(
    'underline duration',
    p['markDuration'],
    _seconds(_token('--duration-draw')),
  );
  expectEq('underline easing', p['markEasing'], _bezier(_token('--ease-draw')));
  expectEq(
    'press duration',
    p['pressDuration'],
    _seconds(_token('--duration-press')),
  );
  expectEq('press easing', p['pressEasing'], _bezier(_token('--ease-settle')));
  expectEq(
    'hover duration',
    p['hoverDuration'],
    _seconds(_token('--duration-instant')),
  );
  expectEq('hover easing', p['hoverEasing'], _bezier(_token('--ease-out')));
  // strokeDashoffset: the brand's mark sting draws its outline (the vendored
  // SVG's own keyframes, exempt like the rest of brand/).
  if ('${p['animatedProps']}' !=
      '[backgroundSize, opacity, strokeDashoffset, transform]') {
    out.add('motion: animated properties ${p['animatedProps']}');
  }
  if (!(p['animations']! as int > 0)) out.add('motion: nothing animates');
  final delays = (p['staggerDelays']! as List<dynamic>).join(' ');
  // Eyebrow, headline, subline, buttons; then the stack card (data-i 2) and
  // its note (data-i 3).
  if (delays != '0s 0.06s 0.12s 0.18s 0.12s 0.18s') {
    out.add('motion: stagger delays $delays');
  }

  final [x, y] = (p['btnRect']! as List<dynamic>)
      .cast<num>()
      .map((n) => n.toDouble())
      .toList();
  await page.mouse('mouseMoved', x, y);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final hover = await page.eval(
    "getComputedStyle(document.querySelector('.btn'), '::before').opacity",
  );
  if (hover != '0.15') out.add('motion: hover overlay opacity $hover');
  await page.mouse('mousePressed', x, y);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final pressed = await page.eval(
    "getComputedStyle(document.querySelector('.btn')).transform",
  );
  final scale = _token('--press-scale');
  if (pressed != 'matrix($scale, 0, 0, $scale, 0, 0)') {
    out.add('motion: pressed transform $pressed, expected scale $scale');
  }
  // Release away from the link, so no mailto: is opened.
  await page.mouse('mouseMoved', 1, 1);
  await page.mouse('mouseReleased', 1, 1);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final rest = await page.eval(
    "getComputedStyle(document.querySelector('.btn')).transform",
  );
  if (rest != 'none') out.add('motion: button does not settle back: $rest');
  return out;
}
