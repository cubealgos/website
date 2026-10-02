// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

// The expected sentences are written as adjacent literals for line length.
// ignore_for_file: no_adjacent_strings_in_list

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
        if (entry.key == PageKey.notFound) {
          // noindex, no canonical, no hreflang alternates.
          expect(html, contains('<meta name="robots" content="noindex"/>'));
          expect(html, isNot(contains('rel="canonical"')), reason: where);
          expect(html, isNot(contains('rel="alternate"')), reason: where);
          continue;
        }
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
            'href="${urlFor(entry.key, Lang.de)}" rel="alternate"/>',
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
        // Scripts: only the same-origin loaders (card sting on home, reveal on
        // the content pages) and the FAQ JSON-LD data block on home.
        final key = resolve(path)?.key;
        final scripts = RegExp('<script[^>]*>').allMatches(read(path));
        expect(scripts.map((m) => m[0]), switch (key) {
          PageKey.home => [
            contains('src="/sting.js"'),
            contains('src="/reveal.js"'),
            contains('type="application/ld+json"'),
          ],
          PageKey.about || PageKey.contact => [contains('src="/reveal.js"')],
          _ => isEmpty,
        }, reason: path);
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

  group('Impressum', () {
    // The facts, as in the company's facts file (typed here independently of
    // lib/src/legal_facts.dart so a drift in either fails the test).
    const facts = [
      'Cube Algos UG (haftungsbeschränkt)',
      'An der Maar 19',
      '52525 Heinsberg',
      'Kevin Scheeren',
      'Amtsgericht Aachen',
      'HRB 27008',
      'DE363092217',
      '+49 1525 7107984',
    ];
    const mail = '<a href="mailto:hello@cubealgos.de">hello@cubealgos.de</a>';
    const tel = '<a href="tel:+4915257107984">+49 1525 7107984</a>';

    for (final lang in Lang.values) {
      test('${lang.code} page carries every fact and both links', () {
        final html = read(pathFor(PageKey.impressum, lang));
        for (final f in facts) {
          expect(html, contains(f));
        }
        expect(html, contains(mail));
        expect(html, contains(tel));
        // The VAT ID is text, not a link.
        expect(html, isNot(contains('href="DE363092217')));
        expect(RegExp('<h1[^>]*>Impressum</h1>').hasMatch(html), isTrue);
      });
    }

    test('only the English page says the German text is authoritative', () {
      const line = 'The German version of this page is legally authoritative.';
      expect(read('/en/impressum/'), contains(line));
      expect(read('/impressum/'), isNot(contains(line)));
    });

    test('the German page has § 5 DDG and both liability sections', () {
      final html = read('/impressum/');
      for (final h in [
        'Angaben gemäß § 5 DDG',
        'Haftung für Inhalte',
        'Haftung für Links',
      ]) {
        expect(html, contains('<h2>$h</h2>'));
      }
    });

    test('title and description are as specified; indexable; in sitemap', () {
      const desc = {
        Lang.en:
            'Legal notice under section 5 DDG for Cube Algos UG '
            '(haftungsbeschränkt), operator of cubealgos.de.',
        Lang.de:
            'Angaben gemäß § 5 DDG für die Cube Algos UG (haftungsbeschränkt), '
            'Betreiberin von cubealgos.de.',
      };
      final sitemap = File('$_buildDir/sitemap.xml').readAsStringSync();
      for (final lang in Lang.values) {
        final html = read(pathFor(PageKey.impressum, lang));
        expect(html, contains('<title>Impressum | Cube Algos</title>'));
        expect(html, contains('content="${desc[lang]}"'));
        expect(html, isNot(contains('noindex')));
        expect(sitemap, contains(urlFor(PageKey.impressum, lang)));
      }
    });

    test('every page links the Impressum in the footer', () {
      for (final entry in paths.values) {
        for (final path in entry.values) {
          final lang = resolve(path)!.lang;
          final footerHtml = read(path)
              .substring(read(path).indexOf('<footer'));
          expect(
            footerHtml,
            contains('href="${pathFor(PageKey.impressum, lang)}"'),
            reason: path,
          );
        }
      }
    });
  });

  group('Datenschutz', () {
    const mail = '<a href="mailto:hello@cubealgos.de">hello@cubealgos.de</a>';
    const tel = '<a href="tel:+4915257107984">+49 1525 7107984</a>';
    const identical = [
      'Cube Algos UG (haftungsbeschränkt)',
      'An der Maar 19',
      '52525 Heinsberg',
      mail,
      tel,
    ];
    // Plain statements, per language: [text, ...].
    const must = {
      Lang.en: [
        'The German version of this page is legally authoritative.',
        'This website is served from a server in Germany. Cube Algos rents '
            'the server from STRATO AG (Berlin) and operates it itself.',
        'No access logs, no storage of IP addresses',
        'to write no access logs for this website',
        "Visitors' IP addresses are therefore not stored.",
        'This website sets no cookies and uses no tracking or analytics.',
        'loads no content from third parties and embeds no external content',
        'The fonts of this website are self-hosted',
        'Your browser makes no request to Google Fonts or to any other '
            'third party for them.',
        'The mailbox is provided by Proton AG (Switzerland)',
        'LDI NRW',
        'We use no automated decision-making',
        'We have not appointed a data protection officer.',
      ],
      Lang.de: [
        'Den Server mietet Cube Algos bei der STRATO AG (Berlin) und '
            'betreibt ihn selbst.',
        'Keine Zugriffsprotokolle, keine Speicherung von IP-Adressen',
        'keine Zugriffsprotokolle (Access Logs) schreiben',
        'Es werden deshalb keine IP-Adressen der Besucherinnen und Besucher '
            'gespeichert.',
        'Diese Website setzt keine Cookies, verwendet kein Tracking und keine '
            'Analysedienste.',
        'Die Schriftarten dieser Website sind selbst gehostet',
        'Ihr Browser stellt dafür keine Verbindung zu Google Fonts oder '
            'einem anderen Dritten her.',
        'Das Postfach stellt Proton AG (Schweiz) bereit',
        'LDI NRW',
        'keine automatisierte Entscheidungsfindung',
        'Wir haben keinen Datenschutzbeauftragten bestellt.',
      ],
    };

    for (final lang in Lang.values) {
      test('${lang.code} page states every required point', () {
        final html = read(pathFor(PageKey.datenschutz, lang));
        for (final text in [...identical, ...must[lang]!]) {
          expect(html, contains(text));
        }
        // Providers: STRATO and Proton once each, no others.
        expect('STRATO'.allMatches(html), hasLength(1));
        expect('Proton'.allMatches(html), hasLength(1));
        for (final other in [
          'Hetzner',
          'Cloudflare',
          'Amazon',
          'Microsoft',
          'Google Analytics',
          'Matomo',
          'Plausible',
        ]) {
          expect(html, isNot(contains(other)));
        }
        // The page never mentions accessibility law.
        expect(html, isNot(contains('BFSG')));
        expect(html, isNot(contains('Barrierefreiheitsstärkungsgesetz')));
      });
    }

    test('only the English page says the German text is authoritative', () {
      expect(read('/datenschutz/'), isNot(contains('legally authoritative')));
    });

    test('title and description are as specified', () {
      const desc = {
        Lang.en:
            'How Cube Algos UG (haftungsbeschränkt) handles personal data on '
            'cubealgos.de: no cookies, no tracking, no access logs.',
        Lang.de:
            'Wie Cube Algos UG (haftungsbeschränkt) auf cubealgos.de mit '
            'personenbezogenen Daten umgeht: keine Cookies, kein Tracking, '
            'keine Zugriffsprotokolle.',
      };
      final sitemap = File('$_buildDir/sitemap.xml').readAsStringSync();
      for (final lang in Lang.values) {
        final html = read(pathFor(PageKey.datenschutz, lang));
        expect(html, contains('<title>Datenschutz | Cube Algos</title>'));
        expect(html, contains('content="${desc[lang]}"'));
        expect(html, isNot(contains('noindex')));
        expect(sitemap, contains(urlFor(PageKey.datenschutz, lang)));
      }
    });

    test('contact details match the Impressum exactly', () {
      for (final lang in Lang.values) {
        final imp = read(pathFor(PageKey.impressum, lang));
        final ds = read(pathFor(PageKey.datenschutz, lang));
        for (final f in identical) {
          expect(imp, contains(f));
          expect(ds, contains(f));
        }
      }
    });

    test('the claims hold for the built site', () {
      // No form, no cookie access, no third-party host (html_check covers the
      // hosts), no storage of any kind (html_check enforces it too).
      for (final f in Directory(_buildDir).listSync(recursive: true)) {
        if (f is! File) continue;
        final name = p.relative(f.path, from: _buildDir);
        if (name.startsWith('fonts/') || name.endsWith('.woff2')) continue;
        if (!RegExp(r'\.(html|js|css)$').hasMatch(name)) continue;
        final text = f.readAsStringSync();
        expect(text, isNot(contains('document.cookie')), reason: name);
        expect(text, isNot(contains('localStorage')), reason: name);
        expect(text, isNot(contains('indexedDB')), reason: name);
        if (name.endsWith('.html')) {
          expect(text, isNot(contains('<form')), reason: name);
        }
        expect(text, isNot(contains('sessionStorage')), reason: name);
        expect(text, isNot(contains('sting-seen')), reason: name);
      }
    });
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
        tagline:
            'Cube Algos, Heinsberg. Apps and internal tools, fixed prices.',
        links: ['Home', 'About', 'Contact'],
        skip: 'Skip to content',
      ),
      Lang.de: (
        tagline:
            'Cube Algos, Heinsberg. Apps und interne Werkzeuge zum Festpreis.',
        links: ['Start', 'Über Cube Algos', 'Kontakt'],
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
            '<main ',
            '<footer',
          ].map(html.indexOf).toList();
          expect(order, everyElement(isNonNegative), reason: path);
          expect(html, matches(RegExp('<main [^>]*id="main"')), reason: path);
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
            expect(m[1], contains('href="${switchPath(entry.key, target)}"'));
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
