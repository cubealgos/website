// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/pages/home_page.dart';
import 'package:website/src/routes.dart';

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
    // The price ledger beside the headline.
    c.offersTitle,
    for (final o in c.offers) offerHeading(o),
    c.vatNote,
    c.studioTitle,
    c.studioText,
    c.lanesTitle,
    for (final lane in c.lanes) ...[lane.title, lane.text, lane.link],
    c.offersTitle,
    c.offersIntro,
    for (final o in c.offers) ...[
      offerHeading(o),
      o.text,
      for (final e in o.examples) '${e.label} · ${e.price}',
    ],
    '${c.vatNote} · ${c.accessibleNote}',
    c.workflowTitle,
    for (final s in c.steps) '${s.title} ${s.text}',
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

      test('the offers anchor exists and the secondary CTA targets it', () {
        expect(html, contains('id="offers"'));
        expect(html, contains('href="#offers"'));
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
        expect(entities, hasLength(8));
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
    test('home ${lang.code}: no separate after-launch section', () {
      final html = builtHtml(PageKey.home, lang);
      expect(html, isNot(contains('id="after-launch"')));
      expect(html, contains('id="offer-after"'));
    });

    test('home ${lang.code}: lane links point at their offer', () {
      final html = builtHtml(PageKey.home, lang);
      final c = homeCopy[lang]!;
      for (final lane in c.lanes) {
        expect(
          html,
          contains(
            'class="lane-link" href="#offer-${lane.offerId}">${lane.link}</a>',
          ),
        );
      }
    });

    test('home ${lang.code}: full and short hero sublines both built', () {
      final html = builtHtml(PageKey.home, lang);
      expect(html, contains('hero-sub hero-sub--full'));
      expect(html, contains('hero-sub hero-sub--short'));
    });
  }

  test('prices are formatted per language', () {
    final en = homeCopy[Lang.en]!.offers.map((o) => o.price);
    final de = homeCopy[Lang.de]!.offers.map((o) => o.price);
    expect(en, ['free', 'from €1,000', 'from €3,000', '€95 an hour']);
    expect(de, ['kostenlos', 'ab 1.000 €', 'ab 3.000 €', '95 € pro Stunde']);
  });

  test('three lanes, the third for processes, each linking to an offer', () {
    for (final lang in Lang.values) {
      final c = homeCopy[lang]!;
      expect(c.lanes, hasLength(3));
      expect(c.lanes.last.offerId, 'automation');
    }
  });

  test('no website offer, no care plans', () {
    for (final lang in Lang.values) {
      final html = builtHtml(PageKey.home, lang);
      expect(
        html,
        isNot(matches(RegExp('€ ?49|49 €|149|2[.,]490|490|8[.,]900'))),
      );
      expect(html, isNot(contains('Idea check')));
    }
  });

  for (final lang in Lang.values) {
    test('every ledger link on home ${lang.code} has a target', () {
      final html = builtHtml(PageKey.home, lang);
      for (final id in ['call', 'apps', 'automation', 'after']) {
        expect(html, contains('id="offer-$id"'));
        expect('href="#offer-$id"'.allMatches(html), isNotEmpty);
      }
    });
  }
}
