// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

import 'support/page_text.dart';

List<String> expectedBlocks(Lang lang) {
  final c = homeCopy[lang]!;
  return [
    c.eyebrow,
    c.h1,
    c.subline,
    c.sublineShort,
    startProject[lang]!,
    c.secondaryCta,
    // The stack card beside the headline, and the note beneath it.
    c.stackTitle,
    for (final row in c.stack) ...[row.label, row.value],
    c.stackNote,
    c.ownTitle,
    c.ownText,
    c.projectsTitle,
    c.projectsIntro,
    for (final lane in c.lanes) ...[
      lane.title,
      lane.text,
      c.examplesLabel,
      ...lane.examples,
    ],
    c.routeTitle,
    for (final s in c.steps) '${s.title} ${s.text}',
    startProject[lang]!,
    c.routeNote,
    c.studioTitle,
    for (final i in c.studio)
      [
        i.lead,
        plainText(i.text),
        if (i.aside != null) plainText(i.aside!),
      ].join(' '),
    c.faqTitle,
    for (final q in c.faq) ...[q.question, q.answer],
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

      test('the secondary CTA targets the own-software section', () {
        final c = homeCopy[lang]!;
        expect(html, contains('id="${c.ownAnchor}"'));
        expect(html, contains('href="#${c.ownAnchor}"'));
        expect(html, contains('id="${c.projectsAnchor}"'));
      });

      test('the only contact route is mailto:hello@cubealgos.de', () {
        final mail = RegExp('href="(mailto:[^"]*)"').allMatches(html);
        expect(mail.map((m) => m[1]).toSet(), {'mailto:hello@cubealgos.de'});
        expect(html, isNot(contains('href="tel:')));
        expect(html, isNot(contains('<form')));
      });

      test('FAQPage JSON-LD mirrors the visible FAQ 1:1', () {
        final m = RegExp(
          r'<script type="application/ld\+json">(.*?)</script>',
          dotAll: true,
        ).allMatches(html).toList();
        // The FAQ block, then the Organization block (see built_output_test).
        expect(m, hasLength(2));
        final ld = jsonDecode(m.first[1]!) as Map<String, dynamic>;
        expect(ld['@type'], 'FAQPage');
        final entities = ld['mainEntity'] as List<dynamic>;
        expect(entities, hasLength(9));
        final blocks = mainBlocks(html);
        final start = blocks.indexOf(homeCopy[lang]!.faqTitle) + 1;
        for (var i = 0; i < entities.length; i++) {
          final e = entities[i] as Map<String, dynamic>;
          expect(e['name'], blocks[start + 2 * i], reason: 'question $i');
          expect(
            (e['acceptedAnswer'] as Map<String, dynamic>)['text'],
            blocks[start + 2 * i + 1],
            reason: 'answer $i',
          );
        }
      });
    });
  }

  for (final lang in Lang.values) {
    test('home ${lang.code}: full and short hero sublines both built', () {
      final html = builtHtml(PageKey.home, lang);
      expect(html, contains('hero-sub hero-sub--full'));
      expect(html, contains('hero-sub hero-sub--short'));
    });

    test(
      'home ${lang.code}: three lanes, five studio items, nine questions',
      () {
        final c = homeCopy[lang]!;
        expect(c.lanes, hasLength(3));
        expect(c.studio, hasLength(5));
        expect(c.faq, hasLength(9));
        expect(c.stack, hasLength(6));
      },
    );

    test('home ${lang.code}: no price, no pricing model, no product name', () {
      final html = builtHtml(PageKey.home, lang);
      final text = mainBlocks(html).join('\n');
      expect(text, isNot(matches(RegExp(r'€|\bEUR\b|\bEuro\b'))));
      expect(text, isNot(matches(RegExp(r'\d\s?%'))));
      expect(text, isNot(matches(_pricing)));
      expect(html, isNot(contains('id="offers"')));
      expect(
        html,
        isNot(matches(RegExp('barrierewacht', caseSensitive: false))),
      );
    });

    test(
      'home ${lang.code}: the free first call is the one thing about money',
      () {
        final c = homeCopy[lang]!;
        expect(c.stack.last.value, lang == Lang.de ? 'kostenlos' : 'free');
        expect(
          c.steps.first.title,
          contains(lang == Lang.de ? 'Kostenloses' : 'Free'),
        );
      },
    );

    test('home ${lang.code}: links to other sites are the allow-listed', () {
      final html = builtHtml(PageKey.home, lang);
      final hrefs = {
        for (final m in RegExp(
          '<a [^>]*href="(https?://[^"]*)"',
        ).allMatches(html))
          m[1]!,
      };
      expect(hrefs, {
        if (lang == Lang.de) personalSiteUrl else personalSiteUrlEn,
        githubOrgUrl,
      });
      expect(html, contains('rel="noreferrer"'));
    });
  }
}

/// Words of a pricing model: the studio's marketing pages say nothing about
/// prices, a fixed price, VAT or an hourly rate (decisions 42 and 43).
final _pricing = RegExp(
  'Festpreis|fixed price|Stundensatz|hourly|per hour|pro Stunde|'
  r'\bUSt\b|\bVAT\b|zzgl|Nettopreis|keine Kosten|costs nothing|'
  r'\bPreis|\bprices?\b',
  caseSensitive: false,
);
