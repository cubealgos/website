// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/copy/contact_copy.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

import 'support/page_text.dart';

List<String> expectedBlocks(Lang lang) {
  final c = contactCopy[lang]!;
  return [
    c.h1,
    c.lede,
    'hello@cubealgos.de',
    c.note,
    c.topicsTitle,
    for (final t in contactTopics(lang)) '${t.lead} ${t.text}',
    c.securityTitle,
    plainText(c.security),
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
    group('contact ${lang.code}', () {
      late String html;
      setUp(() => html = builtHtml(PageKey.contact, lang));

      test('the page shows exactly the copy, in order', () {
        expect(mainBlocks(html), expectedBlocks(lang));
      });

      test('title, description and the single H1 match', () {
        final meta = pageMeta[PageKey.contact]![lang]!;
        expect(meta.h1, contactCopy[lang]!.h1);
        expect('<h1'.allMatches(html), hasLength(1));
        expect(RegExp('<title>(.*?)</title>').firstMatch(html)![1], meta.title);
      });

      test(
        'hello@ for enquiries, security@ for vulnerabilities, nothing else',
        () {
          final mail = RegExp('href="(mailto:[^"]*)"').allMatches(html);
          expect(mail.map((m) => m[1]).toSet(), {
            'mailto:hello@cubealgos.de',
            'mailto:security@cubealgos.de',
          });
          expect(html, isNot(contains('href="tel:')));
        },
      );

      test('no first call, no offer, no investor line', () {
        final text = mainBlocks(html).join('\n');
        expect(
          text,
          isNot(
            matches(
              RegExp(
                r'Erstgespräch|first call|Projekt anfragen|Angebot|offer\b|'
                'Invest|Beteiligung|Rendite|Bewertung|valuation|returns',
                caseSensitive: false,
              ),
            ),
          ),
        );
      });

      test('client projects are not mentioned, offered or denied', () {
        // Decision 56: the page says what the studio is and does, and never
        // that it takes no client work. The four topics are the whole scope.
        final text = [
          ...mainBlocks(html),
          RegExp('content="([^"]*)"').allMatches(html).map((m) => m[1]).join(),
        ].join('\n');
        expect(
          text,
          isNot(
            matches(
              RegExp(
                'Kundenprojekt|client project|Kundenauftr|Aufträge|'
                r'nehmen keine|\bno client',
                caseSensitive: false,
              ),
            ),
          ),
        );
      });

      test('the topics name wearenotabank and the SEO line carries it', () {
        final text = mainBlocks(html).join('\n');
        expect(text, contains('wearenotabank'));
        expect(
          pageMeta[PageKey.contact]![lang]!.description,
          contains('wearenotabank'),
        );
        // Integrations point to the repositories of the product, in public.
        expect(
          contactCopy[lang]!.topics.map((t) => t.lead).toList(),
          lang == Lang.de
              ? [
                  'Zusammenarbeit.',
                  'Integrationen.',
                  'Förderprogramme.',
                  'Presse.',
                ]
              : ['Collaboration.', 'Integrations.', 'Grants.', 'Press.'],
        );
      });

      test('the vulnerability text names the file and asks for consent', () {
        final c = contactCopy[lang]!;
        expect(c.security, contains('`SECURITY.md`'));
        expect(
          c.security,
          contains(
            lang == Lang.de
                ? 'nur mit Ihrer Zustimmung'
                : 'only with your consent',
          ),
        );
        expect(html, contains('<code>SECURITY.md</code>'));
      });

      test('no form, no input, only the reveal script', () {
        for (final tag in ['<form', '<input', '<textarea', '<button']) {
          expect(html, isNot(contains(tag)), reason: tag);
        }
        expect(html, isNot(contains('action=')));
        // The only script is the same-origin scroll reveal, nothing inline.
        expect(RegExp('<script[^>]*>').allMatches(html).map((m) => m[0]), [
          '<script src="/reveal.js">',
        ]);
      });
    });
  }
}
