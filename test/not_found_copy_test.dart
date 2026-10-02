// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/copy/not_found_copy.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

void main() {
  setUpAll(() async {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tool/build.dart',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  for (final lang in Lang.values) {
    group('404 ${lang.code}', () {
      late String html;
      setUp(() => html = builtHtml(PageKey.notFound, lang));
      final c = notFoundCopy[lang]!;

      test('is emitted at the flat path and shows exactly the copy', () {
        expect(
          pathFor(PageKey.notFound, lang),
          lang == Lang.en ? '/404.html' : '/de/404.html',
        );
        expect(mainBlocks(html), [
          c.headline,
          c.body,
          c.homeAction,
          c.mailAction,
        ]);
        expect(pageMeta[PageKey.notFound]![lang]!.h1, c.headline);
        expect(
          RegExp('<title>(.*?)</title>').firstMatch(html)![1],
          pageMeta[PageKey.notFound]![lang]!.title,
        );
      });

      test('links home and to mailto, all URLs root-absolute', () {
        final home = lang == Lang.en ? '/' : '/de/';
        expect(html, contains('href="$home"'));
        expect(html, contains('href="mailto:hello@cubealgos.de"'));
        for (final m in RegExp(r'\b(?:href|src)="([^"]*)"').allMatches(html)) {
          final url = m[1]!;
          expect(
            url.startsWith('/') ||
                url.startsWith('#') ||
                url.startsWith('mailto:') ||
                url.startsWith('https://cubealgos.de/'),
            isTrue,
            reason: url,
          );
        }
      });

      test('shows the confused fish, decorative', () {
        expect(html, contains('/brand/fish/animated/confused.svg'));
      });

      test('is noindex, with no canonical or hreflang', () {
        expect(html, contains('<meta name="robots" content="noindex"/>'));
        expect(html, isNot(contains('rel="canonical"')));
        expect(html, isNot(contains('rel="alternate"')));
      });
    });
  }

  test('the sitemap does not list the 404 pages', () {
    final sitemap = File('build/jaspr/sitemap.xml').readAsStringSync();
    expect(sitemap, isNot(contains('404')));
  });
}
