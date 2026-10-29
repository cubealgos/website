// SPDX-License-Identifier: Apache-2.0

// The constraints of wearenotabank `DEC-082` (D1 to D10) that a built site can
// break, as tests over the built output and over the scans themselves:
//  * D2: the name is one lower-case word, `wearenotabank`; an emphasis covers
//    the whole word; "bank" is never set apart.
//  * D3: the name never meets a reader alone: the meta description and the
//    first paragraph of Home carry a business-object word.
//  * D5, D6, D8: no banking vocabulary, no comparison with banks, no currency
//    imagery (the regulated-language test covers the words of the pages).
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

const _buildDir = 'build/jaspr';

/// Every way of writing the name that is not allowed or is the allowed one:
/// the words run together or apart, any case, `notabank` alone.
final _name = RegExp(
  r'we[\s_-]*are[\s_-]*not[\s_-]*a[\s_-]*bank|notabank',
  caseSensitive: false,
);

/// The ways [text] writes the name that D2 does not allow: any spelling but
/// `wearenotabank` in one piece, the name glued to letters or digits, and any
/// "bank" that is not the end of `wearenotabank` (split by a tag, in capitals,
/// or on its own).
List<String> nameProblems(String text) {
  final problems = <String>[];
  for (final m in _name.allMatches(text)) {
    if (m[0] != 'wearenotabank') problems.add('spelled "${m[0]}"');
    final before = m.start == 0 ? '' : text[m.start - 1];
    final after = m.end == text.length ? '' : text[m.end];
    if (RegExp('[A-Za-z0-9]').hasMatch(before) ||
        RegExp('[A-Za-z0-9]').hasMatch(after)) {
      problems.add('glued to a letter: "$before${m[0]}$after"');
    }
  }
  for (final m in RegExp('bank', caseSensitive: false).allMatches(text)) {
    final from = m.start - 'wearenota'.length;
    final whole = from >= 0 && text.substring(from, m.end) == 'wearenotabank';
    if (!whole) {
      final around = text.substring(
        (m.start - 12).clamp(0, text.length),
        (m.end + 4).clamp(0, text.length),
      );
      problems.add('"bank" set apart: "$around"');
    }
  }
  return problems;
}

/// The text files of the build (pages, sitemap, manifest, scripts, styles,
/// SVGs): everything the name could be written in.
Iterable<File> _textFiles() sync* {
  for (final f in Directory(_buildDir).listSync(recursive: true)) {
    if (f is File &&
        RegExp(r'\.(html|xml|txt|json|webmanifest|svg|css|js)$')
            .hasMatch(f.path)) {
      yield f;
    }
  }
}

void main() {
  setUpAll(() async {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tool/build.dart',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  test('the scan catches every wrong spelling and passes the right one', () {
    for (final bad in [
      'Wearenotabank',
      'WeAreNotABank',
      'We Are Not A Bank',
      'we are not a bank',
      'notabank',
      'WEARENOTABANK',
      'wearenotabanks',
      'mywearenotabank',
      'wearenota<b>bank</b>',
      'wearenot<span>abank</span>',
      'a Bank',
      'bank',
    ]) {
      expect(nameProblems(bad), isNotEmpty, reason: bad);
    }
    for (final good in [
      'wearenotabank',
      'Cube Algos ist das Studio hinter <span class="mark">wearenotabank</span>.',
      'href="https://github.com/wearenotabank"',
      '"name":"wearenotabank"',
      'Cube Algos is the studio behind wearenotabank.',
      'no name at all',
    ]) {
      expect(nameProblems(good), isEmpty, reason: good);
    }
  });

  test('D2: no file of the build writes the name any other way', () {
    final hits = <String>[];
    var named = 0;
    for (final f in _textFiles()) {
      final text = f.readAsStringSync();
      if (text.contains('wearenotabank')) named++;
      for (final problem in nameProblems(text)) {
        hits.add('${f.path}: $problem');
      }
    }
    expect(hits, isEmpty);
    // The scan saw the name: Home and Contact in both languages, the sitemap
    // does not carry it.
    expect(named, greaterThanOrEqualTo(4));
  });

  test('D2: an emphasis covers the whole word, and only that', () {
    for (final lang in Lang.values) {
      final html = builtHtml(PageKey.home, lang);
      final marks = [
        for (final m in RegExp(
          '<span class="mark">(.*?)</span>',
          dotAll: true,
        ).allMatches(html))
          m[1],
      ];
      expect(marks, ['wearenotabank'], reason: lang.code);
    }
    // No element wraps a part of the word either: the scan of every file
    // above reports a name split by a tag as a spelling or a loose "bank".
  });

  test('D3: the description and the paragraph carry the business object', () {
    final object = {
      Lang.de: RegExp('Software|Smart Contracts|Werkzeuge'),
      Lang.en: RegExp('software|smart contracts|developer tools'),
    };
    for (final lang in Lang.values) {
      final html = builtHtml(PageKey.home, lang);
      final description = RegExp('<meta name="description" content="([^"]*)"')
          .firstMatch(html)![1]!;
      expect(description, contains('wearenotabank'));
      expect(description, matches(object[lang]!), reason: lang.code);
      // The share tags repeat it; the share image carries the eyebrow.
      expect(
        html,
        contains('<meta property="og:description" content="$description"/>'),
      );
      // The first paragraph, directly under the H1, names it too.
      final paragraph = mainBlocks(html)[2];
      expect(paragraph, matches(object[lang]!), reason: lang.code);
      expect(paragraph, isNot(contains('wearenotabank')));
      // And so does the title's neighbour: the eyebrow names the studio kind.
      expect(
        mainBlocks(html).first,
        matches(RegExp('studio', caseSensitive: false)),
      );
    }
  });

  test('D5, D6, D8: no banking vocabulary, no currency or bank imagery', () {
    final banking = RegExp(
      r'\bBank(en|ing)?\b|Konto|Einlage|Zinsen|Sparen|IBAN|Girocard|'
      r'\baccount\b|deposit|interest|savings|credit card|\bIBAN\b|€|&euro;|'
      'Sparkasse|better than a bank|besser als eine Bank|statt einer Bank|'
      'instead of a bank|no bank',
      caseSensitive: false,
    );
    final hits = <String>[];
    for (final route in routesFor(shippedContent)) {
      if (route.key == PageKey.impressum || route.key == PageKey.datenschutz) {
        continue;
      }
      final html = builtHtmlAt(route.path);
      final head = [
        RegExp('<title>(.*?)</title>').firstMatch(html)![1]!,
        RegExp('<meta name="description" content="([^"]*)"')
            .firstMatch(html)![1]!,
      ];
      for (final block in [...head, ...mainBlocks(html)]) {
        // "wearenotabank" is the one word that holds "bank"; D2 covers it.
        final rest = block.replaceAll('wearenotabank', '');
        for (final m in banking.allMatches(rest)) {
          hits.add('${route.path}: "${m[0]}" in "$block"');
        }
      }
    }
    expect(hits, isEmpty);
    // No currency sign in any page, legal ones included, or in any SVG.
    for (final f in _textFiles().where(
      (f) => f.path.endsWith('.html') || f.path.endsWith('.svg'),
    )) {
      expect(f.readAsStringSync(), isNot(contains('€')), reason: f.path);
    }
  });
}
