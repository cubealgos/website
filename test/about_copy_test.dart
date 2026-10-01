// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/copy/about_copy.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

List<String> expectedBlocks(Lang lang) {
  final c = aboutCopy[lang]!;
  return [
    c.h1,
    c.lede,
    c.whoTitle,
    ...c.who,
    c.oneTitle,
    c.one,
    c.howTitle,
    ...c.how,
    c.whereTitle,
    c.where,
    c.ctaTitle,
    writeToKevin[lang]!,
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
    group('about ${lang.code}', () {
      late String html;
      setUp(() => html = builtHtml(PageKey.about, lang));

      test('the page shows exactly the copy, in order', () {
        expect(mainBlocks(html), expectedBlocks(lang));
      });

      test('title, description and the single H1 match', () {
        final meta = pageMeta[PageKey.about]![lang]!;
        expect(meta.h1, aboutCopy[lang]!.h1);
        expect('<h1'.allMatches(html), hasLength(1));
        expect(RegExp('<title>(.*?)</title>').firstMatch(html)![1], meta.title);
      });

      test('the closing CTA is the only contact route', () {
        final mail = RegExp('href="(mailto:[^"]*)"').allMatches(html);
        expect(mail.map((m) => m[1]).toSet(), {'mailto:hello@cubealgos.de'});
        expect(html, isNot(contains('<form')));
      });

      test('the portrait slot is a decorative figure with the idle fish', () {
        final figure = RegExp(
          '<figure class="portrait[^"]*"[^>]*>(.*?)</figure>',
          dotAll: true,
        ).firstMatch(html)![1]!;
        expect(figure, contains('/brand/fish/animated/idle.svg'));
        // Empty alt text renders as the bare attribute.
        expect(
          figure,
          matches(RegExp(r'<img [^>]*\balt(=""| )', dotAll: true)),
        );
        expect(figure, contains('aria-hidden="true"'));
      });
    });
  }
}
