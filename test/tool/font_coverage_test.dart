// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:test/test.dart';

import '../../tool/src/font_coverage.dart';

/// Latin + German the issue requires, independent of the manifest's own spec.
const _german = 'ÄÖÜäöüß„“‚‘–—€·…×';

void main() {
  test('parseUnicodes expands ranges and single points', () {
    expect(parseUnicodes('U+0041-0043,U+00DF'), {0x41, 0x42, 0x43, 0xDF});
    expect(() => parseUnicodes('0041'), throwsFormatException);
  });

  test('the committed fonts match the manifest and cover the subset', () {
    expect(checkFontCoverage(repoRoot: Directory.current), isEmpty);
  });

  test('every face covers ASCII and the German set', () {
    final findings = checkFontCoverage(repoRoot: Directory.current);
    expect(findings, isEmpty);
    final spec = parseUnicodes(
      RegExp('"unicodes": "(.*?)"')
          .firstMatch(File('tool/fonts/coverage.json').readAsStringSync())![1]!,
    );
    for (final c in [...List.generate(95, (i) => 0x20 + i), ..._german.runes]) {
      expect(spec, contains(c), reason: 'U+${c.toRadixString(16)}');
    }
  });

  test('copy with a character outside the subset is a finding', () {
    final dir = Directory.systemTemp.createTempSync('font_cov_');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/ok.md').writeAsStringSync('Größe – „ok“ €');
    File('${dir.path}/bad.html').writeAsStringSync('<p>caf&#233; ☃</p>');
    final findings = checkFontCoverage(
      repoRoot: Directory.current,
      copyPaths: [dir.path],
    );
    expect(findings.where((f) => f.contains('bad.html')), hasLength(2));
    expect(findings.where((f) => f.contains('ok.md')), isEmpty);
  });
}
