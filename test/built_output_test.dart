// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:website/src/icons.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

const _buildDir = 'build/jaspr';

String _fileFor(String path) => path.endsWith('/') ? '${path}index.html' : path;

void main() {
  setUpAll(() async {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tool/build.dart',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  String read(String path) =>
      File(p.join(_buildDir, _fileFor(path).substring(1))).readAsStringSync();

  test('the build holds exactly the pages of the route table', () {
    final built = [
      for (final f in Directory(_buildDir).listSync(recursive: true))
        if (f is File && f.path.endsWith('.html'))
          '/${p.relative(f.path, from: _buildDir)}',
    ]..sort();
    final expected = [
      for (final m in paths.values)
        for (final path in m.values) _fileFor(path),
    ]..sort();
    expect(built, expected);
  });

  test('every page has lang, a unique title, hreflang and canonical', () {
    final titles = <String>{};
    for (final entry in paths.entries) {
      for (final lang in Lang.values) {
        final html = read(entry.value[lang]!);
        final where = '${entry.key}/${lang.code}';
        expect(html, contains('<html lang="${lang.code}">'), reason: where);
        final title = RegExp('<title>(.*?)</title>').firstMatch(html)![1]!;
        expect(title, pageMeta[entry.key]![lang]!.title, reason: where);
        expect(titles.add('${lang.code}:$title'), isTrue, reason: where);
        for (final alt in Lang.values) {
          expect(
            html,
            contains(
              '<link hreflang="${alt.code}" '
              'href="${urlFor(entry.key, alt)}" rel="alternate"/>',
            ),
            reason: where,
          );
        }
        expect(
          html,
          contains(
            '<link hreflang="x-default" '
            'href="${urlFor(entry.key, Lang.en)}" rel="alternate"/>',
          ),
          reason: where,
        );
        expect(
          html,
          contains('<link href="${urlFor(entry.key, lang)}" rel="canonical"/>'),
          reason: where,
        );
      }
    }
  });

  test('the built HTML references only same-origin resources', () {
    final ref = RegExp(r'''\b(?:src|href|action|srcset)="([^"]*)"''');
    for (final entry in paths.values) {
      for (final path in entry.values) {
        for (final m in ref.allMatches(read(path))) {
          final url = m[1]!;
          if (url.startsWith('//') || url.contains('://')) {
            expect(
              Uri.parse(url).host,
              Uri.parse(siteOrigin).host,
              reason: '$path references $url',
            );
          }
        }
        // Scripts: only the sting loader, same-origin, on the home pages.
        final scripts = RegExp('<script[^>]*>').allMatches(read(path));
        expect(
          scripts.map((m) => m[0]),
          resolve(path)?.key == PageKey.home
              ? [contains('src="/sting.js"')]
              : isEmpty,
          reason: path,
        );
      }
    }
  });

  test('every page links the icon set and the manifest; the files exist', () {
    for (final entry in paths.values) {
      for (final path in entry.values) {
        final html = read(path);
        for (final href in [faviconSvg, faviconIco, appleTouchIcon]) {
          expect(html, contains('href="$href"'), reason: path);
        }
        expect(html, contains('<link href="$manifestPath" rel="manifest"/>'));
      }
    }
    for (final f in iconFiles) {
      expect(File('$_buildDir$f').existsSync(), isTrue, reason: f);
    }
    final manifest = jsonDecode(
      File('$_buildDir$manifestPath').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(manifest['name'], 'Cube Algos');
    expect(manifest['theme_color'], '#EDEEF1');
    expect(manifest['background_color'], '#EDEEF1');
    expect((manifest['icons'] as List).length, 4);
  });

  test('fonts: only the display face is preloaded, all faces are built', () {
    for (final entry in paths.values) {
      for (final path in entry.values) {
        final html = read(path);
        expect(
          RegExp('rel="preload"').allMatches(html),
          hasLength(1),
          reason: path,
        );
        expect(
          html,
          matches(RegExp(r'<link [^>]*href="/fonts/onest-800\.woff2"[^>]*>')),
          reason: path,
        );
        final tag = RegExp('<link [^>]*preload[^>]*>').firstMatch(html)![0]!;
        for (final attr in ['as="font"', 'type="font/woff2"', 'crossorigin']) {
          expect(tag, contains(attr), reason: path);
        }
        expect(html, contains('href="/fonts/fonts.css"'), reason: path);
      }
    }
    final css = File('$_buildDir/fonts/fonts.css').readAsStringSync();
    expect('font-display: swap'.allMatches(css), hasLength(3));
    for (final f in [
      'onest-400.woff2',
      'onest-800.woff2',
      'dm-mono-400.woff2',
    ]) {
      expect(File('$_buildDir/fonts/$f').existsSync(), isTrue, reason: f);
      expect(css, contains('/fonts/$f'));
    }
    expect(
      File('$_buildDir/fonts/licenses/Onest-OFL.txt').existsSync() &&
          File('$_buildDir/fonts/licenses/DMMono-OFL.txt').existsSync(),
      isTrue,
    );
  });

  test('the three font files total under 120 KB', () {
    final total = [
      for (final f in Directory('$_buildDir/fonts').listSync())
        if (f is File && f.path.endsWith('.woff2')) f.lengthSync(),
    ].fold<int>(0, (a, b) => a + b);
    expect(total, lessThan(120 * 1000));
  });

  group('page frame', () {
    // The footer is the brand copy (home.md "Footer"), character for character.
    const footer = {
      Lang.en: (
        tagline: 'Cube Algos, Heinsberg. Websites and apps, fixed prices.',
        links: ['Home', 'About', 'Contact'],
        skip: 'Skip to content',
      ),
      Lang.de: (
        tagline: 'Cube Algos, Heinsberg. Websites und Apps zum Festpreis.',
        links: ['Start', 'Über mich', 'Kontakt'],
        skip: 'Zum Inhalt springen',
      ),
    };
    const bottom = '© 2026 Cube Algos UG (haftungsbeschränkt)';
    final anchor = RegExp('<a ([^>]*)>(.*?)</a>');

    for (final entry in paths.entries) {
      for (final lang in Lang.values) {
        final path = entry.value[lang]!;
        test('$path renders through the shell', () {
          final html = read(path);
          final f = footer[lang]!;
          // Skip link first, then landmarks in order.
          final order = [
            '<a class="skip" href="#main">${f.skip}</a>',
            '<header',
            '<nav',
            '<main id="main" tabindex="-1">',
            '<footer',
          ].map(html.indexOf).toList();
          expect(order, everyElement(isNonNegative), reason: path);
          expect(order, orderedEquals([...order]..sort()), reason: path);
          // Footer text.
          final footerHtml = html.substring(html.indexOf('<footer'));
          expect(footerHtml, contains('<p class="tagline">${f.tagline}</p>'));
          expect(footerHtml, contains('<p>$bottom</p>'));
          expect(
            footerHtml,
            contains(
              '<a href="mailto:hello@cubealgos.de">hello@cubealgos.de</a>',
            ),
          );
          final labels = [
            for (final m in anchor.allMatches(
              footerHtml.split('class="bottom"')[0],
            ))
              m[2]!,
          ];
          expect(labels, [
            ...f.links,
            'Impressum',
            'Datenschutz',
            'hello@cubealgos.de',
          ]);
          // Header nav and the language switch (header and footer).
          final switchLinks = [
            for (final m in anchor.allMatches(html))
              if (m[1]!.contains('hreflang=')) m,
          ];
          expect(switchLinks, hasLength(4), reason: path);
          for (final m in switchLinks) {
            final target = Lang.values.firstWhere(
              (l) => m[2] == l.code.toUpperCase(),
            );
            expect(m[1], contains('href="${pathFor(entry.key, target)}"'));
            expect(m[1], contains('lang="${target.code}"'));
            expect(m[1], contains('hreflang="${target.code}"'));
            expect(
              m[1]!.contains('aria-current="true"'),
              target == lang,
              reason: '$path ${m[2]}',
            );
          }
        });
      }
    }
  });
}
