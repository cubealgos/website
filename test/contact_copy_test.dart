// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/copy/contact_copy.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

List<String> expectedBlocks(Lang lang) {
  final c = contactCopy[lang]!;
  return [
    c.h1,
    c.lede,
    'hello@cubealgos.de',
    c.includeTitle,
    c.includeIntro,
    ...c.include,
    c.includeOutro,
    c.nextTitle,
    ...c.next,
    c.nextNote,
    c.details,
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

      test('every contact action is mailto:hello@cubealgos.de', () {
        final mail = RegExp('href="(mailto:[^"]*)"').allMatches(html);
        expect(mail.map((m) => m[1]).toSet(), {'mailto:hello@cubealgos.de'});
        expect(html, isNot(contains('href="tel:')));
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
