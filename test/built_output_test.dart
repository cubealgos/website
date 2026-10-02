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
import 'package:website/src/outbound.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';

const _buildDir = 'build/jaspr';

String _fileFor(String path) => path.endsWith('/') ? '${path}index.html' : path;

/// The references (`src`, `href`, `action`, `srcset`) of [html] that leave the
/// site's own host, except the `href` of an `<a>` to a URL of [outboundUrls]
/// (a link is not a request).
List<String> foreignReferences(String html) {
  final tag = RegExp(r'<([a-zA-Z0-9]+)\b([^>]*)>');
  final attr = RegExp(r'''\b(src|href|action|srcset)="([^"]*)"''');
  final host = Uri.parse(siteOrigin).host;
  return [
    for (final t in tag.allMatches(html))
      for (final a in attr.allMatches(t[2]!))
        if ((a[2]!.startsWith('//') || a[2]!.contains('://')) &&
            Uri.parse(a[2]!).host != host &&
            !(t[1] == 'a' && a[1] == 'href' && outboundUrls.contains(a[2])))
          a[2]!,
  ];
}

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

  test('every indexable page has Open Graph and Twitter tags', () {
    for (final entry in paths.entries) {
      for (final lang in Lang.values) {
        final html = read(entry.value[lang]!);
        final where = '${entry.key}/${lang.code}';
        if (entry.key == PageKey.notFound) {
          expect(html, isNot(contains('og:image')), reason: where);
          continue;
        }
        final meta = pageMeta[entry.key]![lang]!;
        for (final tag in [
          '<meta property="og:title" content="${meta.title}"/>',
          '<meta property="og:url" content="${urlFor(entry.key, lang)}"/>',
          '<meta property="og:type" content="website"/>',
          '<meta property="og:locale" content="${ogLocale(lang)}"/>',
          '<meta property="og:image" content="${shareImageUrl(lang)}"/>',
          '<meta name="twitter:card" content="summary_large_image"/>',
          '<meta name="twitter:image" content="${shareImageUrl(lang)}"/>',
        ]) {
          expect(html, contains(tag), reason: where);
        }
      }
    }
  });

  test('both home pages carry Organization and FAQPage JSON-LD', () {
    for (final lang in Lang.values) {
      final html = read(pathFor(PageKey.home, lang));
      final blocks = [
        for (final m in RegExp(
          r'<script type="application/ld\+json">(.*?)</script>',
          dotAll: true,
        ).allMatches(html))
          jsonDecode(m[1]!) as Map<String, dynamic>,
      ];
      expect(blocks.map((b) => b['@type']), ['FAQPage', 'Organization']);
      expect(blocks.last, organizationJsonLd());
    }
  });

  test('the sitemap carries the alternates and robots.txt points at it', () {
    final xml = File('$_buildDir/sitemap.xml').readAsStringSync();
    expect(xml, sitemapXml());
    expect(
      File('$_buildDir/robots.txt').readAsStringSync(),
      contains('Sitemap: https://cubealgos.de/sitemap.xml'),
    );
  });

  test('the built HTML references only same-origin resources', () {
    for (final entry in paths.values) {
      for (final path in entry.values) {
        expect(foreignReferences(read(path)), isEmpty, reason: path);
        // Scripts: only the same-origin loaders (card sting on home, reveal on
        // the content pages) and the JSON-LD data blocks (FAQ, Organization) on
        // home.
        final key = resolve(path)?.key;
        final scripts = RegExp('<script[^>]*>').allMatches(read(path));
        expect(scripts.map((m) => m[0]), switch (key) {
          PageKey.home => [
            contains('src="/sting.js"'),
            contains('src="/reveal.js"'),
            contains('type="application/ld+json"'),
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

  test('a link off the allow list is a foreign reference', () {
    for (final url in [
      'https://github.com/other',
      'https://www.linkedin.com/in/someone',
      '$githubOrgUrl?ref=x',
    ]) {
      expect(foreignReferences('<a href="$url">x</a>'), [url]);
    }
    for (final url in outboundUrls) {
      expect(foreignReferences('<a href="$url">x</a>'), isEmpty);
      // Only as the href of a link, never as a request.
      expect(foreignReferences('<img src="$url"/>'), [url]);
      expect(foreignReferences('<link href="$url" rel="stylesheet"/>'), [url]);
    }
  });

  test("home and about link Kevin's site in their own language", () {
    const own = {Lang.de: personalSiteUrl, Lang.en: personalSiteUrlEn};
    final href = RegExp('<a [^>]*href="(https://[^"]*)"');
    for (final lang in Lang.values) {
      for (final key in [PageKey.home, PageKey.about]) {
        final links = [
          for (final m in href.allMatches(read(pathFor(key, lang)))) m[1]!,
        ].where((u) => u != '$siteOrigin/' && !u.startsWith(siteOrigin));
        expect(links, contains(own[lang]), reason: '$key ${lang.code}');
        expect(links, contains(githubOrgUrl), reason: '$key ${lang.code}');
        expect(
          links.toSet().difference(outboundUrls),
          isEmpty,
          reason: '$key ${lang.code}',
        );
        expect(links, isNot(contains(own[lang.other])));
      }
    }
  });

  test('no built text file names the product in development', () {
    // Decision 45: no name, no mark, no section, in no page, script, style
    // sheet, sitemap, JSON-LD block or manifest.
    final name = RegExp('barrierewacht', caseSensitive: false);
    final seen = <String>[];
    for (final f in Directory(_buildDir).listSync(recursive: true)) {
      if (f is! File) continue;
      final rel = p.relative(f.path, from: _buildDir);
      expect(rel, isNot(matches(name)), reason: rel);
      if (!RegExp(r'\.(html|css|js|json|xml|txt|svg|webmanifest)$')
          .hasMatch(rel)) {
        continue;
      }
      seen.add(rel);
      expect(f.readAsStringSync(), isNot(matches(name)), reason: rel);
    }
    expect(seen, isNotEmpty);
  });

  test('no page description names a price', () {
    for (final entry in pageMeta.values) {
      for (final meta in entry.values) {
        expect(
          meta.description,
          isNot(
            matches(
              RegExp(r'€|Festpreis|fixed price|\bab \d', caseSensitive: false),
            ),
          ),
          reason: meta.title,
        );
      }
    }
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
        "Visitors' IP addresses are therefore not stored on this server.",
        'It acts for us as a processor',
        'Right to object:',
        '(Art. 77 GDPR)',
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
        'Auf diesem Server werden deshalb keine IP-Adressen der '
            'Besucherinnen und Besucher gespeichert.',
        'Sie ist dabei als Auftragsverarbeiterin für uns tätig',
        'Widerspruchsrecht:',
        '(Art. 77 DSGVO)',
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
        tagline: 'Cube Algos, Heinsberg. Software studio since 2023.',
        links: ['Home', 'About', 'Contact'],
        skip: 'Skip to content',
      ),
      Lang.de: (
        tagline: 'Cube Algos, Heinsberg. Softwarestudio seit 2023.',
        links: ['Start', 'Über', 'Kontakt'],
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
