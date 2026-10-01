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
<link hreflang="x-default" href="https://cubealgos.de/" rel="alternate"/>''';

String _page({
  String lang = 'en',
  String head = _head,
  String body = '<h1 id="top">Home</h1>',
}) =>
    '<!DOCTYPE html><html lang="$lang"><head><base href="/"/>$head</head>\n'
    '<body>$body</body></html>';

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

  group('sitemap', () {
    test('passes when every page is listed (404 pages excepted)', () {
      final dir = _site({
        '404.html': _page(),
        'de/404.html': _page(lang: 'de'),
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
}
