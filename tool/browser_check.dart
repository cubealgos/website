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
//    language;
//  * UI motion: the sting plays once per session on the home pages only (a
//    new tab is a new session), uses the theme's background, and is replaced
//    by its still under reduced motion (a second Chrome started with
//    `--force-prefers-reduced-motion`); durations and easings are the tokens;
//    only transform and opacity animate; button press and hover.
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
        (key: PageKey.home, lang: Lang.en),
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
      final want = pathFor(r.key, r.lang.other);
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

    // 6. The favicon set loads without a 404 and the SVG mark switches to
    // paper in a dark browser theme.
    failures.addAll(await _iconChecks(page, base));

    // 5. Screenshots for review (optional).
    if (shots != null) {
      for (final lang in Lang.values) {
        for (final width in [375, 1280]) {
          for (final dark in [false, true]) {
            // A new tab is a new session: the sting plays; shoot once it ends.
            final shot = await chrome.newPage();
            await shot.setViewport(width, 800);
            await shot.setMedia(dark: dark);
            await shot.goto('$base${pathFor(PageKey.home, lang)}');
            final name = 'home-${lang.code}-$width-${dark ? 'dark' : 'light'}';
            if (width == 1280 && !dark) {
              await Future<void>.delayed(const Duration(milliseconds: 700));
              await shot.screenshot('$shots/$name-sting-mid.png');
            }
            await Future<void>.delayed(const Duration(milliseconds: 2400));
            await shot.screenshot('$shots/$name.png');
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
    (key: PageKey.home, lang: Lang.en),
    (key: PageKey.impressum, lang: Lang.de),
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

const _stingState = '''
(() => {
  const anim = document.querySelector('.sting-anim');
  const stills = [...document.querySelectorAll('.sting-still')];
  return {
    box: !!document.querySelector('[data-sting]'),
    anim: !!anim,
    animSrc: anim ? anim.getAttribute('src') : null,
    animLoaded: anim ? anim.complete && anim.naturalWidth > 0 : null,
    stillVisible: stills.some(i => i.offsetParent !== null && i.getClientRects().length > 0),
    stillSrcs: stills.filter(i => getComputedStyle(i).display !== 'none').map(i => i.getAttribute('src')),
    flag: (() => { try { return sessionStorage.getItem('sting-seen'); } catch (e) { return 'blocked'; } })(),
    scripts: document.scripts.length,
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
    markName: css(mark, 'animationName', '::after'),
    markDuration: css(mark, 'animationDuration', '::after'),
    markEasing: css(mark, 'animationTimingFunction', '::after'),
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
    for (final dark in [false, true]) {
      final theme = dark ? 'ink' : 'paper';
      final page = await session(dark: dark);
      await page.goto(home);
      final first = await page.evalMap(_stingState);
      final probe = await page.evalMap(_motionProbe);
      if (reduced) {
        if (first['anim'] == true || first['stillVisible'] != true) {
          out.add('$where: sting is not the still: $first');
        }
        final stills = first['stillSrcs']! as List<dynamic>;
        if (stills.length != 1 ||
            !'${stills.first}'.contains('sting-$theme-still')) {
          out.add('$where: wrong still $stills for $theme');
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
      if (first['anim'] != true ||
          first['stillVisible'] == true ||
          !'${first['animSrc']}'.endsWith('sting-$theme.svg') ||
          first['flag'] != '1') {
        out.add('$where ($theme): first load does not play the sting: $first');
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (await page.eval("document.querySelector('.sting-anim').complete") !=
          true) {
        out.add('$where: animated sting did not load');
      }
      // Navigate away and back in the same session: the still, no replay.
      await page.goto('$base${pathFor(PageKey.about, lang)}');
      final about = await page.evalMap(_stingState);
      if (about['box'] == true ||
          about['anim'] == true ||
          about['scripts'] != 0) {
        out.add(
          '${pathFor(PageKey.about, lang)}: sting or script on another '
          'page: $about',
        );
      }
      await page.goto(home);
      final back = await page.evalMap(_stingState);
      if (back['anim'] == true || back['stillVisible'] != true) {
        out.add('$where ($theme): sting replays on return to home: $back');
      }
      // A new session (a new tab) plays it again.
      final fresh = await session(dark: dark);
      await fresh.goto(home);
      if ((await fresh.evalMap(_stingState))['anim'] != true) {
        out.add('$where ($theme): a new session does not play the sting');
      }
      // Blocked storage falls back to once per page load.
      final blocked = await session(dark: dark);
      await blocked.send('Page.addScriptToEvaluateOnNewDocument', {
        'source':
            'Object.defineProperty(window, "sessionStorage", '
            '{ get() { throw new Error("blocked"); } });',
      });
      await blocked.goto(home);
      if ((await blocked.evalMap(_stingState))['anim'] != true) {
        out.add('$where: blocked storage does not play the sting once');
      }
    }
    // Every other page has no sting, whatever the session.
    for (final key in PageKey.values.where((k) => k != PageKey.home)) {
      final page = await session();
      await page.goto('$base${pathFor(key, lang)}');
      final s = await page.evalMap(_stingState);
      if (s['box'] == true || s['anim'] == true || s['scripts'] != 0) {
        out.add('${pathFor(key, lang)} ($mode): sting on a non-home page: $s');
      }
    }
  }

  if (reduced) return out;

  // Tokens on the real elements, transform/opacity only, stagger, press, hover.
  final page = await session();
  await page.goto('$base${pathFor(PageKey.home, Lang.en)}');
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
  if ('${p['animatedProps']}' != '[opacity, transform]') {
    out.add('motion: animated properties ${p['animatedProps']}');
  }
  if (!(p['animations']! as int > 0)) out.add('motion: nothing animates');
  final delays = (p['staggerDelays']! as List<dynamic>).join(' ');
  if (delays != '0s 0.06s') out.add('motion: stagger delays $delays');

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
