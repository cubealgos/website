// SPDX-License-Identifier: Apache-2.0

// Checks that CHANGELOG.md exists and has an "Unreleased" section.
// Run: `fvm dart run tool/changelog_check.dart`.
import 'dart:io';

void main() {
  final file = File('CHANGELOG.md');
  if (!file.existsSync()) {
    stderr.writeln('changelog_check: CHANGELOG.md is missing.');
    exit(1);
  }
  if (!RegExp(
    r'^## Unreleased\s*$',
    multiLine: true,
  ).hasMatch(file.readAsStringSync())) {
    stderr.writeln('changelog_check: CHANGELOG.md has no "## Unreleased".');
    exit(1);
  }
  stdout.writeln('changelog_check: CHANGELOG.md ok.');
}
