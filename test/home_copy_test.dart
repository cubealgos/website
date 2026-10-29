// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

/// What the shipped home page shows, in order (the named state): the statement
/// (eyebrow, H1, paragraph, the two actions) and the fact sheet. The facts are
/// typed here independently of `lib/src/legal_facts.dart`, so a drift in
/// either fails.
List<String> expectedBlocks(Lang lang) {
  final c = homeCopy[lang]!;
  final post = shippedContent.newestPostFor(lang)!;
  return [
    c.eyebrow,
    headlineText(c.h1),
    c.lede,
    c.productButton,
    c.contactLink,
    c.sheetTitle,
    c.providerLabel,
    'Cube Algos UG (haftungsbeschränkt), Heinsberg',
    c.registerLabel,
    'Amtsgericht Aachen, HRB 27008',
    c.productLabel,
    'wearenotabank',
    c.contactLabel,
    'hello@cubealgos.de',
    c.blogLabel,
    post.title,
    'Impressum',
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

  for (final lang in Lang.values) {
    group('home ${lang.code}', () {
      late String html;
      setUp(() => html = builtHtml(PageKey.home, lang));

      test('the site ships the named state', () {
        expect(namesProduct, isTrue);
      });

      test('the page shows exactly the copy, in order', () {
        expect(mainBlocks(html), expectedBlocks(lang));
      });

      test('title, description and the single H1 match the copy', () {
        final meta = pageMeta[PageKey.home]![lang]!;
        expect(meta.h1, headlineText(homeCopy[lang]!.h1));
        expect('<h1'.allMatches(html), hasLength(1));
        expect(RegExp('<title>(.*?)</title>').firstMatch(html)![1], meta.title);
        expect(html, contains('<meta name="description" content='));
        expect(html, contains('content="${meta.description}"'));
      });

      test('no <base> element: in-page links stay on the page', () {
        expect(html, isNot(contains('<base')));
      });

      test('the H1 underlines the whole word wearenotabank, nothing else', () {
        final h1 = RegExp(
          '<h1[^>]*>(.*?)</h1>',
          dotAll: true,
        ).firstMatch(html)!;
        expect(
          RegExp('<span class="mark">(.*?)</span>')
              .allMatches(h1[1]!)
              .map((m) => m[1]),
          ['wearenotabank'],
        );
      });

      test('one button, to the organisation; the contact link is text', () {
        expect('class="btn"'.allMatches(html), hasLength(1));
        final c = homeCopy[lang]!;
        expect(
          html,
          contains(
            '<a class="btn" rel="noreferrer" href="$wearenotabankOrgUrl">'
            '${c.productButton}<svg class="ext"',
          ),
        );
        expect(
          html,
          contains(
            '<a class="text-link" href="${pathFor(PageKey.contact, lang)}">'
            '${c.contactLink}</a>',
          ),
        );
      });

      test('the outbound arrow is decoration, hidden from assistive tech', () {
        final arrows = RegExp('<svg class="ext"[^>]*>').allMatches(html);
        expect(arrows, hasLength(2), reason: 'the button and the Produkt row');
        for (final m in arrows) {
          expect(m[0], contains('aria-hidden="true"'));
          expect(m[0], contains('focusable="false"'));
        }
      });

      test('the sheet: provider, register entry, product, contact, blog', () {
        final c = homeCopy[lang]!;
        expect(
          [for (final m in RegExp('<dt>(.*?)</dt>').allMatches(html)) m[1]],
          [
            c.providerLabel,
            c.registerLabel,
            c.productLabel,
            c.contactLabel,
            c.blogLabel,
          ],
        );
        // The register number stays on one line.
        expect(html, contains('<span class="nobr">HRB 27008</span>'));
        // The Impressum link under the sheet is in this language.
        expect(
          html,
          contains(
            '<p class="b-sheet-foot"><a '
            'href="${pathFor(PageKey.impressum, lang)}">',
          ),
        );
      });

      test('the blog row links the newest post itself', () {
        final post = shippedContent.newestPostFor(lang)!;
        final path = routePath(PageKey.post, post.lang, post.slug);
        expect(post.lang, lang, reason: "a post in the visitor's language");
        expect(html, contains('<a href="$path">${post.title}</a>'));
        expect(
          html,
          isNot(contains('href="${pathFor(PageKey.blog, lang)}"><')),
        );
      });

      test('the sheet holds the sting, the only mark on the page', () {
        expect('class="cas-mark"'.allMatches(html), hasLength(1));
        expect(html, contains('<div class="ledger-mark">'));
        expect(html, contains('src="/sting.js"'));
        // The page is not revealed on scroll: no reveal script, no .reveal.
        expect(html, isNot(contains('reveal.js')));
        expect(html, isNot(contains('class="reveal')));
      });

      test('the paragraph names the object, directly under the H1', () {
        final c = homeCopy[lang]!;
        // E-C-2: the first sentence says what is made, in plain words.
        expect(
          c.lede,
          startsWith(
            lang == Lang.de
                ? 'Wir bauen Werkzeuge für die Softwareentwicklung: Smart '
                      'Contracts, SDKs und Bibliotheken für EVM-Chains, mit '
                      'Schwerpunkt auf Dart.'
                : 'We make developer tools: smart contracts, SDKs and '
                      'libraries for EVM chains, with a focus on Dart.',
          ),
        );
        // E-C-3: nothing sits between the H1 and the paragraph, on any width.
        final between = RegExp(
          '</h1>(.*?)<p class="bc-lede',
          dotAll: true,
        ).firstMatch(html)![1]!;
        expect(between.trim(), isEmpty);
        // One paragraph, never a shortened phone variant.
        expect('class="bc-lede'.allMatches(html), hasLength(1));
      });

      test('the paragraph has no clause beyond the object and the founder', () {
        final text = mainBlocks(html).join('\n');
        expect(
          text,
          isNot(
            matches(
              RegExp('eigenen Betrieb|Software für unseren|run the company'),
            ),
          ),
        );
      });

      test('the only mail address is hello@cubealgos.de (sheet, footer)', () {
        final mail = RegExp('href="(mailto:[^"]*)"').allMatches(html);
        expect(mail.map((m) => m[1]).toSet(), {'mailto:hello@cubealgos.de'});
        expect(html, isNot(contains('href="tel:')));
        expect(html, isNot(contains('<form')));
      });

      test(
        'the structured data is the Organization block with its brand alone',
        () {
          final blocks = [
            for (final m in RegExp(
              r'<script type="application/ld\+json">(.*?)</script>',
              dotAll: true,
            ).allMatches(html))
              jsonDecode(m[1]!) as Map<String, dynamic>,
          ];
          expect(blocks.map((b) => b['@type']), ['Organization']);
          expect(blocks.single['brand'], {
            '@type': 'Brand',
            'name': 'wearenotabank',
            'url': wearenotabankOrgUrl,
            'description': 'Developer tools for EVM chains',
          });
          expect(blocks.single['sameAs'], [linkedinCompanyUrl]);
          expect(html, isNot(contains('FAQPage')));
        },
      );

      test('no client work: no lanes, rail, FAQ, project button or call', () {
        for (final gone in [
          'class="lane',
          'class="rail',
          'class="faq',
          '<details',
          '<summary',
          'id="projekte"',
          'id="projects"',
          'is-call',
          'FAQPage',
          'class="band',
          'class="cta',
          'class="room',
          'class="hero',
        ]) {
          expect(html, isNot(contains(gone)), reason: gone);
        }
        final text = mainBlocks(html).join('\n');
        expect(
          text,
          isNot(
            matches(
              RegExp(
                'Projekt anfragen|Start a project|Erstgespräch|first call|'
                r'kostenlos|Angebot|\bFragen\b|\bQuestions\b|Kundschaft|'
                r'\bBetriebe\b|Gründungsteams|businesses and founders',
                caseSensitive: false,
              ),
            ),
          ),
        );
      });

      test('no privacy item on Home: the fact is in the Datenschutz', () {
        final text = mainBlocks(html).join('\n');
        expect(
          text,
          isNot(matches(RegExp('Cookie|Tracking', caseSensitive: false))),
        );
      });

      test('no price, no pricing model', () {
        final text = mainBlocks(html).join('\n');
        expect(text, isNot(matches(RegExp(r'€|\bEUR\b|\bEuro\b'))));
        expect(text, isNot(matches(RegExp(r'\d\s?%'))));
        expect(text, isNot(matches(_pricing)));
      });

      test('links to other sites are the allow-listed', () {
        final hrefs = {
          for (final m in RegExp(
            '<a [^>]*href="(https?://[^"]*)"',
          ).allMatches(html))
            m[1]!,
        };
        expect(hrefs, {wearenotabankOrgUrl, linkedinCompanyUrl});
        expect(html, contains('rel="noreferrer"'));
      });
    });
  }
}

/// Words of a pricing model: the studio's pages say nothing about prices, a
/// fixed price, VAT or an hourly rate (decisions 42 and 43).
final _pricing = RegExp(
  'Festpreis|fixed price|Stundensatz|hourly|per hour|pro Stunde|'
  r'\bUSt\b|\bVAT\b|zzgl|Nettopreis|keine Kosten|costs nothing|'
  r'\bPreis|\bprices?\b',
  caseSensitive: false,
);
