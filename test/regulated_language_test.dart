// SPDX-License-Identifier: Apache-2.0

// The words the site must never use (regulatory check of 2026-10-14 and copy
// v2, section "Regulated language"): the studio shows software, it offers no
// bank, financial service, investment, return, guarantee or advice, and no
// oracle is "recommended" or "official". Scanned over the text of every built
// page except the legal pages, which keep their legal register.
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

final _forbidden = <Lang, RegExp>{
  Lang.de: RegExp(
    r'\bBank\b|Banking|Finanzdienstleistung|Investition|investier|Rendite|'
    r'\bsicher\b|garantiert|kostenlos|\bKonto\b|jeder Token|empfohlen|'
    r'kuratiert|\boffiziell|Anlageberatung',
    caseSensitive: false,
  ),
  Lang.en: RegExp(
    r'\bbank\b|banking|financial service|investment|\byields?\b|\breturns\b|'
    r'\bsecure\b|guaranteed|any token|no fees|recommended|curated|vetted|'
    r'powered by|\bofficial|Chainlink oracle|investment advice',
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

  test('no built page uses a word the regulatory check rules out', () {
    final hits = <String>[];
    for (final route in routesFor(shippedContent)) {
      if (route.key == PageKey.impressum ||
          route.key == PageKey.datenschutz ||
          route.key == PageKey.notFound) {
        continue;
      }
      final html = builtHtmlAt(route.path);
      final head = [
        RegExp('<title>(.*?)</title>').firstMatch(html)![1]!,
        RegExp('<meta name="description" content="([^"]*)"')
            .firstMatch(html)![1]!,
      ];
      for (final block in [...head, ...mainBlocks(html)]) {
        for (final m in _forbidden[route.lang]!.allMatches(block)) {
          hits.add('${route.path}: "${m[0]}" in "$block"');
        }
      }
    }
    expect(hits, isEmpty);
  });

  test('the scan catches the words and passes the intended ones', () {
    expect(_forbidden[Lang.de]!.hasMatch('Unsere Bank ist sicher'), isTrue);
    expect(_forbidden[Lang.de]!.hasMatch('Hohe Rendite, garantiert'), isTrue);
    expect(_forbidden[Lang.en]!.hasMatch('Powered by Chainlink'), isTrue);
    expect(_forbidden[Lang.en]!.hasMatch('A recommended token'), isTrue);
    // The product's name holds "bank" in one word: no word boundary, no hit
    // (wearenotabank `DEC-082`); "bank" on its own is still caught.
    for (final lang in Lang.values) {
      expect(
        _forbidden[lang]!.hasMatch(
          'Cube Algos ist das Studio hinter wearenotabank, the studio behind '
          'wearenotabank, github.com/wearenotabank',
        ),
        isFalse,
      );
      expect(_forbidden[lang]!.hasMatch('wearenotabank is a bank'), isTrue);
    }
    // Intended: licence rows, the "no guarantee" talk of the post, MF-8.
    expect(
      _forbidden[Lang.en]!.hasMatch(
        'Apache-2.0, open source; source-available',
      ),
      isFalse,
    );
    expect(
      _forbidden[Lang.de]!.hasMatch('Garantieversprechen und Schwachstelle'),
      isFalse,
    );
    expect(
      _forbidden[Lang.en]!.hasMatch('Not affiliated with or endorsed by'),
      isFalse,
    );
  });
}
