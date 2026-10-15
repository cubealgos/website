// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/copy/blog_copy.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

import 'support/page_text.dart';

/// What the shipped home page shows, in order: no work ships, so the hero
/// button leads to the studio and there is no works section.
List<String> expectedBlocks(Lang lang) {
  final c = homeCopy[lang]!;
  final post = shippedContent.postById(lang, aiPostId)!;
  return [
    c.eyebrow,
    c.h1,
    c.subline,
    c.sublineShort,
    c.buttonStudio,
    c.secondaryCta,
    c.stackTitle,
    for (final row in c.stack) ...[row.label, row.value],
    c.studioTitle,
    for (final i in c.studio.where((i) => !i.needsSource))
      [i.lead, plainText(i.text), if (i.postId != null) post.title].join(' '),
    c.blogTitle,
    formatDate(post.date, lang),
    post.title,
    post.description,
    c.allPosts,
    c.ctaTitle,
    c.ctaText,
    c.ctaButton,
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

      test('the page shows exactly the copy, in order', () {
        expect(mainBlocks(html), expectedBlocks(lang));
      });

      test('title, description and the single H1 match the copy', () {
        final meta = pageMeta[PageKey.home]![lang]!;
        expect(meta.h1, homeCopy[lang]!.h1);
        expect('<h1'.allMatches(html), hasLength(1));
        expect(RegExp('<title>(.*?)</title>').firstMatch(html)![1], meta.title);
      });

      test('no <base> element: in-page links stay on the page', () {
        expect(html, isNot(contains('<base')));
      });

      test('with no work, the hero button leads to the studio', () {
        final c = homeCopy[lang]!;
        expect(html, contains('id="${c.studioAnchor}"'));
        expect(
          html,
          contains(
            '<a class="btn" href="#${c.studioAnchor}">${c.buttonStudio}</a>',
          ),
        );
        expect(html, isNot(contains('id="${c.workAnchor}"')));
        expect(html, isNot(contains(c.buttonWork)));
        expect(html, isNot(contains('class="room')));
      });

      test(
        'no claim that contracts are published with source, none is yet',
        () {
          final c = homeCopy[lang]!;
          expect(html, isNot(contains(c.sublineSource)));
          expect(html, isNot(contains(c.studio[3].text.split('[').first)));
          expect(shippedContent.hasPublicSource, isFalse);
        },
      );

      test('the secondary link leads to the contact page', () {
        expect(
          html,
          contains(
            '<a class="text-link" href="${pathFor(PageKey.contact, lang)}">'
            '${homeCopy[lang]!.secondaryCta}</a>',
          ),
        );
      });

      test('the only mail address is hello@cubealgos.de (panel, footer)', () {
        final mail = RegExp('href="(mailto:[^"]*)"').allMatches(html);
        expect(mail.map((m) => m[1]).toSet(), {'mailto:hello@cubealgos.de'});
        expect(html, isNot(contains('href="tel:')));
        expect(html, isNot(contains('<form')));
      });

      test(
        'the structured data is the Organization block alone, no FAQPage',
        () {
          final blocks = [
            for (final m in RegExp(
              r'<script type="application/ld\+json">(.*?)</script>',
              dotAll: true,
            ).allMatches(html))
              jsonDecode(m[1]!) as Map<String, dynamic>,
          ];
          expect(blocks.map((b) => b['@type']), ['Organization']);
          expect(html, isNot(contains('FAQPage')));
        },
      );

      test('the sublines both exist: full, and short for phones', () {
        expect(html, contains('hero-sub hero-sub--full'));
        expect(html, contains('hero-sub hero-sub--short'));
      });

      test(
        'six stack rows, five studio items shown, no note under the card',
        () {
          final c = homeCopy[lang]!;
          expect(c.stack, hasLength(6));
          expect(c.studio, hasLength(6));
          expect(c.studio.where((i) => i.needsSource), hasLength(1));
          expect(html, isNot(contains(c.studio[3].lead)));
          expect(html, isNot(contains('stack-note')));
          expect('<dt>'.allMatches(html), hasLength(6));
        },
      );

      test(
        'no client work: no lanes, rail, FAQ, project button or first call',
        () {
          for (final gone in [
            'class="lane',
            'class="rail',
            'class="faq',
            '<details',
            '<summary',
            'route-block',
            'id="projekte"',
            'id="projects"',
            'id="own-software"',
            'id="eigene-software"',
            'is-call',
            'FAQPage',
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
          // The one mention of client projects says there are none.
          expect(
            text,
            contains(
              lang == Lang.de
                  ? 'nehmen keine Kundenprojekte an'
                  : 'take no client projects',
            ),
          );
          expect(
            'Kundenprojekte'.allMatches(text).length,
            lang == Lang.de ? 1 : 0,
          );
        },
      );

      test('no price, no pricing model, no product name', () {
        final text = mainBlocks(html).join('\n');
        expect(text, isNot(matches(RegExp(r'€|\bEUR\b|\bEuro\b'))));
        expect(text, isNot(matches(RegExp(r'\d\s?%'))));
        expect(text, isNot(matches(_pricing)));
        expect(
          html,
          isNot(matches(RegExp('barrierewacht', caseSensitive: false))),
        );
      });

      test('links to other sites are the allow-listed', () {
        final hrefs = {
          for (final m in RegExp(
            '<a [^>]*href="(https?://[^"]*)"',
          ).allMatches(html))
            m[1]!,
        };
        // No work links its source yet, so the item that links the code on
        // GitHub is not shown: only the footer's company page remains.
        expect(hrefs, {linkedinCompanyUrl});
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
