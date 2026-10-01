// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/html_check.dart';

const _head = '''
<title>Home | Cube Algos</title>
<meta name="description" content="A page."/>
<link href="https://cubealgos.de/" rel="canonical"/>
<link hreflang="en" href="https://cubealgos.de/" rel="alternate"/>
<link hreflang="de" href="https://cubealgos.de/de/" rel="alternate"/>
<link hreflang="x-default" href="https://cubealgos.de/" rel="alternate"/>
<link href="/icon.svg" rel="icon" type="image/svg+xml"/>
<link href="/icon.ico" rel="icon" sizes="any"/>
<link href="/touch.png" rel="apple-touch-icon"/>
<link href="/site.webmanifest" rel="manifest"/>''';

String _page({
  String lang = 'en',
  String head = _head,
  String body = '<h1 id="top">Home</h1>',
}) =>
    '<!DOCTYPE html><html lang="$lang"><head><base href="/"/>$head</head>\n'
    '<body>$body</body></html>';

const _head404 = '''
<title>Page not found | Cube Algos</title>
<meta name="description" content="Not found."/>
<meta name="robots" content="noindex"/>
<link href="/icon.svg" rel="icon" type="image/svg+xml"/>
<link href="/icon.ico" rel="icon" sizes="any"/>
<link href="/touch.png" rel="apple-touch-icon"/>
<link href="/site.webmanifest" rel="manifest"/>''';

const _sitemap = '''
<urlset>
  <url><loc>https://cubealgos.de/</loc></url>
  <url><loc>https://cubealgos.de/de/</loc></url>
</urlset>''';

/// A valid two-page built site, with [overrides] replacing or adding files
/// (a `null` value removes one).
Directory _site(Map<String, String?> overrides) {
  final files = <String, String?>{
    'index.html': _page(),
    'de/index.html': _page(lang: 'de'),
    'sitemap.xml': _sitemap,
    'icon.svg': '<svg/>',
    'icon.ico': 'ico',
    'touch.png': 'png',
    'site.webmanifest': '{"name":"Cube Algos","icons":[{"src":"/touch.png"}]}',
    ...overrides,
  };
  final dir = Directory.systemTemp.createTempSync('html_check_');
  addTearDown(() => dir.deleteSync(recursive: true));
  for (final e in files.entries) {
    final value = e.value;
    if (value == null) continue;
    File(p.join(dir.path, e.key))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(value);
  }
  return dir;
}

List<String> _rules(Directory dir) => [for (final f in checkSite(dir)) f.rule];

void main() {
  test('a valid site passes', () {
    expect(checkSite(_site({})), isEmpty);
  });

  group('icons', () {
    test('fail when a page lacks the icon links', () {
      final dir = _site({
        'index.html': _page(
          head: _head.replaceAll(RegExp('<link href="/icon[^>]*>'), ''),
        ),
      });
      expect(_rules(dir), contains('icons'));
    });
    test('fail when a linked icon file is not in the build', () {
      expect(_rules(_site({'touch.png': null})), contains('icons'));
    });
    test('fail without a manifest or when it lists a missing icon', () {
      expect(_rules(_site({'site.webmanifest': null})), contains('icons'));
      final dir = _site({
        'site.webmanifest': '{"name":"x","icons":[{"src":"/nope.png"}]}',
      });
      expect(_rules(dir), contains('icons'));
    });
  });

  group('title', () {
    test('passes with a title', () => expect(_rules(_site({})), isEmpty));
    test('fails on an empty title', () {
      final dir = _site({
        'index.html': _page(head: _head.replaceAll('Home | Cube Algos', '')),
      });
      expect(_rules(dir), contains('title'));
    });
  });

  group('description', () {
    test('passes with a description', () => expect(_rules(_site({})), isEmpty));
    test('fails on a missing description', () {
      final dir = _site({
        'index.html': _page(
          head: _head.replaceAll(RegExp('<meta name="description"[^>]*>'), ''),
        ),
      });
      expect(_rules(dir), contains('description'));
    });
  });

  group('lang', () {
    test('passes with lang', () => expect(_rules(_site({})), isEmpty));
    test('fails on an empty lang', () {
      final dir = _site({'index.html': _page(lang: '')});
      expect(_rules(dir), contains('lang'));
    });
  });

  group('hreflang', () {
    test('passes with en, de and x-default', () {
      expect(_rules(_site({})), isEmpty);
    });
    test('fails when x-default is missing', () {
      final dir = _site({
        'index.html': _page(
          head: _head.replaceAll(
            RegExp('<link hreflang="x-default"[^>]*>'),
            '',
          ),
        ),
      });
      expect(_rules(dir), contains('hreflang'));
    });
  });

  group('canonical', () {
    test(
      'passes with a canonical link',
      () => expect(_rules(_site({})), isEmpty),
    );
    test('fails on a missing canonical link', () {
      final dir = _site({
        'index.html': _page(
          head: _head.replaceAll(RegExp('<link href[^>]*canonical[^>]*>'), ''),
        ),
      });
      expect(_rules(dir), contains('canonical'));
    });
  });

  group('internal links', () {
    test('pass when they resolve', () {
      final dir = _site({
        'index.html': _page(
          body: '<a href="/de/">de</a><a href="/about/">a</a>',
        ),
        'about/index.html': _page(),
        'sitemap.xml': _sitemap.replaceFirst(
          '</urlset>',
          '<url><loc>https://cubealgos.de/about/</loc></url></urlset>',
        ),
      });
      expect(checkSite(dir), isEmpty);
    });
    test('fail on a broken link', () {
      final dir = _site({
        'index.html': _page(body: '<a href="/missing/">x</a>'),
      });
      expect(_rules(dir), ['broken-link']);
    });
    test('fail on a broken src', () {
      final dir = _site({'index.html': _page(body: '<img src="/nope.png"/>')});
      expect(_rules(dir), ['broken-link']);
    });
  });

  group('fragments', () {
    test('pass when the target exists', () {
      final dir = _site({
        'index.html': _page(body: '<h1 id="top">x</h1><a href="/#top">t</a>'),
      });
      expect(checkSite(dir), isEmpty);
    });
    test('fail when the target is missing', () {
      final dir = _site({
        'index.html': _page(body: '<a href="/#nowhere">t</a>'),
      });
      expect(_rules(dir), ['fragment']);
    });
  });

  group('foreign hosts', () {
    test('pass for cubealgos.de, mailto and tel', () {
      final dir = _site({
        'index.html': _page(
          body: [
            '<a href="https://cubealgos.de/de/">d</a>',
            '<a href="mailto:hello@cubealgos.de">m</a>',
            '<a href="tel:+491">t</a>',
          ].join(),
        ),
      });
      expect(checkSite(dir), isEmpty);
    });
    test('fail for another host', () {
      final dir = _site({
        'index.html': _page(body: '<a href="https://example.com/">x</a>'),
      });
      expect(_rules(dir), ['foreign-host']);
    });
    test('fail for a protocol-relative script', () {
      final dir = _site({
        'index.html': _page(
          body: '<script src="//cdn.example.com/a.js"></script>',
        ),
      });
      expect(_rules(dir), ['foreign-host']);
    });
  });

  group('third-party hosts', () {
    test('pass for a stylesheet with local font urls', () {
      final dir = _site({
        'fonts/fonts.css': "@font-face{src:url('/fonts/a.woff2')}",
        'fonts/a.woff2': 'x',
      });
      expect(checkSite(dir), isEmpty);
    });
    test('fail for Google Fonts in a page', () {
      final dir = _site({
        'index.html': _page(
          head:
              '$_head<link href="https://fonts.googleapis.com/css2" '
              'rel="stylesheet"/>',
        ),
      });
      expect(_rules(dir), containsAll(['third-party', 'foreign-host']));
    });
    test('fail for a foreign url or import in a stylesheet', () {
      final dir = _site({
        'a.css':
            '@import "https://cdn.example.com/x.css"; '
            '@font-face{src:url(//fonts.gstatic.com/a.woff2)}',
      });
      expect(_rules(dir), ['third-party', 'third-party']);
    });
    test('fail for a local url that does not resolve', () {
      final dir = _site({'a.css': '@font-face{src:url(/fonts/gone.woff2)}'});
      expect(_rules(dir), ['broken-link']);
    });
  });

  group('404 pages', () {
    test('are exempt from canonical and hreflang, and need noindex', () {
      final dir = _site({'404.html': _page(head: _head404)});
      expect(checkSite(dir), isEmpty);
    });
    test('fail without noindex', () {
      final dir = _site({
        '404.html': _page(
          head: _head404.replaceAll(
            '<meta name="robots" content="noindex"/>',
            '',
          ),
        ),
      });
      expect(_rules(dir), ['noindex']);
    });
    test('fail with a canonical or hreflang alternates', () {
      final dir = _site({'404.html': _page()});
      expect(_rules(dir), containsAll(['noindex', 'canonical', 'hreflang']));
    });
    test('fail on a relative URL', () {
      final dir = _site({
        '404.html': _page(
          head: _head404,
          body: '<h1>x</h1><a href="index.html">home</a>',
        ),
      });
      expect(_rules(dir), ['relative-url']);
    });
    test('accept root-absolute URLs', () {
      final dir = _site({
        '404.html': _page(
          head: _head404,
          body: '<h1>x</h1><a href="/">home</a><a href="/de/">de</a>',
        ),
      });
      expect(checkSite(dir), isEmpty);
    });
  });

  group('sitemap', () {
    test('passes when every page is listed (404 pages excepted)', () {
      final dir = _site({
        '404.html': _page(head: _head404),
        'de/404.html': _page(lang: 'de', head: _head404),
      });
      expect(checkSite(dir), isEmpty);
    });
    test('fails when a page is missing from the sitemap', () {
      final dir = _site({
        'sitemap.xml': _sitemap.replaceFirst(
          '<url><loc>https://cubealgos.de/de/</loc></url>',
          '',
        ),
      });
      expect(_rules(dir), ['sitemap']);
    });
    test('fails when there is no sitemap', () {
      final dir = _site({'sitemap.xml': null});
      expect(_rules(dir), ['sitemap']);
    });
  });

  group('storage', () {
    test('fails on any storage API in a built script', () {
      for (final js in [
        'sessionStorage.getItem("a")',
        'localStorage.x',
        'indexedDB.open("a")',
        'document.cookie = "a=b"',
      ]) {
        expect(_rules(_site({'sting.js': js})), ['storage'], reason: js);
      }
      expect(_rules(_site({'sting.js': 'document.referrer'})), isEmpty);
    });
  });

  group('hard-coded colours', () {
    test('tokens pass, brand files are exempt', () {
      final dir = _site({
        'site.css': 'a { color: var(--color-fg); background: transparent; }',
        'brand/tokens.css': ':root { --color-bg: #EDEEF1; }',
      });
      expect(_rules(dir), isEmpty);
    });
    test('fails on a hex, a colour function, a name or an inline style', () {
      for (final css in [
        'a { color: #fff; }',
        'a { background: rgba(0, 0, 0, .5); }',
        'a { border: 1px solid red; }',
      ]) {
        expect(_rules(_site({'site.css': css})), [
          'hard-coded-colour',
        ], reason: css);
      }
      final dir = _site({
        'index.html': _page(body: '<h1 id="top" style="color:#123">Home</h1>'),
      });
      expect(_rules(dir), ['hard-coded-colour']);
    });
  });

  group('motion', () {
    test('tokens pass, brand files are exempt', () {
      final dir = _site({
        'site.css': '''
@keyframes rise { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: none; } }
.a { animation: rise var(--duration-base) var(--ease-settle) both; animation-delay: calc(var(--i) * var(--duration-instant) * 0.6); }
.b { transition: transform var(--duration-press) var(--ease-settle), opacity var(--duration-instant) var(--ease-out); }
@media (prefers-reduced-motion: reduce) { .a { animation: none; transition: none; } }
''',
        'brand/fish/fish.css':
            '.f { animation: x 900ms cubic-bezier(.65,0,.35,1); }',
      });
      expect(_rules(dir), isEmpty);
    });
    test('fails on duration and easing literals', () {
      for (final css in [
        '.a { transition: transform 200ms var(--ease-out); }',
        '.a { animation-duration: .3s; }',
        '.a { transition: transform var(--duration-base) ease-in-out; }',
        '.a { animation-timing-function: cubic-bezier(.5, 0, .5, 1); }',
      ]) {
        expect(_rules(_site({'site.css': css})), [
          'literal-motion',
        ], reason: css);
      }
    });
    test('fails on animating anything but transform and opacity', () {
      for (final css in [
        '@keyframes g { from { width: 0; } to { width: 10px; } }',
        '.a { transition: color var(--duration-base) var(--ease-out) }',
        '.a { transition-property: height; }',
      ]) {
        final rules = _rules(_site({'site.css': css}));
        expect(rules, isNotEmpty, reason: css);
        expect(rules, everyElement('layout-motion'), reason: css);
      }
    });
    test('allows background-size (paint-only: the inline underline)', () {
      const css =
          '@keyframes d { from { background-size: 0 0.1em; } '
          'to { background-size: 100% 0.1em; } }';
      expect(_rules(_site({'site.css': css})), isEmpty);
    });
  });
}
