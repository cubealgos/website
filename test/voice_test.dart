// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

/// The studio voice (decision 28): Cube Algos speaks as the studio, never in
/// the first person. The legal pages keep their legal register and are not
/// checked.
const List<PageKey> _voicePages = [
  PageKey.home,
  PageKey.about,
  PageKey.contact,
  PageKey.notFound,
];

final Map<Lang, RegExp> _firstPerson = {
  Lang.en: RegExp(r'\b(we|our|ours|us|i|my|me|mine)\b', caseSensitive: false),
  Lang.de: RegExp(
    r'\b(wir|uns|unser\w*|ich|mein\w*|mir|mich)\b',
    caseSensitive: false,
  ),
};

void main() {
  setUpAll(() async {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tool/build.dart',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  for (final lang in Lang.values) {
    for (final key in _voicePages) {
      test('${key.name} ${lang.code} has no first-person words', () {
        final html = builtHtml(key, lang);
        final head = [
          RegExp('<title>(.*?)</title>').firstMatch(html)![1]!,
          RegExp('<meta name="description" content="([^"]*)"')
              .firstMatch(html)![1]!,
        ];
        final text = [...head, ...mainBlocks(html)];
        expect(text, isNotEmpty);
        final hits = [
          for (final block in text)
            for (final m in _firstPerson[lang]!.allMatches(block))
              '"${m[0]}" in "$block"',
        ];
        expect(hits, isEmpty);
      });
    }
  }

  test('the pronoun check catches first-person text', () {
    expect(_firstPerson[Lang.en]!.hasMatch('We build it for us'), isTrue);
    expect(_firstPerson[Lang.en]!.hasMatch('I build it'), isTrue);
    expect(_firstPerson[Lang.de]!.hasMatch('Ich baue es für mich'), isTrue);
    expect(_firstPerson[Lang.en]!.hasMatch('Cube Algos builds it'), isFalse);
    expect(_firstPerson[Lang.de]!.hasMatch('Kevin baut es'), isFalse);
  });
}
