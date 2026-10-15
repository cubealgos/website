// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

/// The studio voice (decision 50): Cube Algos speaks as "we" / „wir", the
/// studio, and addresses the reader formally („Sie"); no „du". The legal pages
/// keep their legal register and are not checked.
const List<PageKey> _voicePages = [
  PageKey.home,
  PageKey.about,
  PageKey.contact,
  PageKey.blog,
  PageKey.notFound,
];

/// The informal address: forbidden in German, in every page and post.
final _informal = RegExp(r'\b(du|dich|dir|dein\w*|euch)\b');

void main() {
  setUpAll(() async {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tool/build.dart',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  for (final key in _voicePages) {
    test('${key.name} de addresses the reader as „Sie", never „du"', () {
      final html = builtHtml(key, Lang.de);
      final head = [
        RegExp('<title>(.*?)</title>').firstMatch(html)![1]!,
        RegExp('<meta name="description" content="([^"]*)"')
            .firstMatch(html)![1]!,
      ];
      final text = [...head, ...mainBlocks(html)];
      expect(text, isNotEmpty);
      final hits = [
        for (final block in text)
          for (final m in _informal.allMatches(block)) '"${m[0]}" in "$block"',
      ];
      expect(hits, isEmpty);
    });
  }

  test('the German post uses the studio voice and the formal address', () {
    final html = builtHtmlAt(
      routePath(PageKey.post, Lang.de, 'ki-agenten-in-unseren-repositories'),
    );
    final text = mainBlocks(html).join('\n');
    expect(text, contains('Wir arbeiten gern mit moderner Technik'));
    expect(_informal.hasMatch(text), isFalse);
  });

  test('the check catches informal address and ignores formal', () {
    expect(_informal.hasMatch('Hast du Fragen? Schreib dir etwas'), isTrue);
    expect(_informal.hasMatch('Schreiben Sie uns'), isFalse);
    expect(_informal.hasMatch('Wir bauen eigene Anwendungen'), isFalse);
  });
}
