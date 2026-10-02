// SPDX-License-Identifier: Apache-2.0

// Offline checks over the built site (default build/jaspr). Build first:
// `fvm dart run tool/build.dart`. Run: `fvm dart run tool/html_check.dart`.
import 'dart:io';

import 'src/html_check.dart';
import 'src/seo_check.dart';

void main(List<String> args) {
  final dir = Directory(args.isEmpty ? 'build/jaspr' : args.first);
  if (!dir.existsSync()) {
    stderr.writeln('html_check: ${dir.path} does not exist; build first.');
    exit(2);
  }
  final findings = [...checkSite(dir), ...checkSeo(dir)];
  if (findings.isNotEmpty) {
    findings.forEach(stderr.writeln);
    stderr.writeln('html_check: ${findings.length} finding(s).');
    exit(1);
  }
  stdout.writeln('html_check: ${dir.path} ok.');
}
