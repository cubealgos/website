// SPDX-License-Identifier: Apache-2.0

// Fails if a character the page copy needs is missing from a font face.
// `fvm dart run tool/fonts/check_coverage.dart [copy file or dir]...`, for
// example `build/jaspr` (CI) or the brand copy directory. See README.md.
import 'dart:io';

import '../src/font_coverage.dart';

void main(List<String> args) {
  final findings = checkFontCoverage(
    repoRoot: Directory.current,
    copyPaths: args,
  );
  if (findings.isNotEmpty) {
    findings.forEach(stderr.writeln);
    stderr.writeln('check_coverage: ${findings.length} finding(s).');
    exit(1);
  }
  stdout.writeln('check_coverage: ok.');
}
