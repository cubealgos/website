// SPDX-License-Identifier: Apache-2.0

// Checks every commit reachable from HEAD against the commit subject rule.
// Grandfathered commits are exempt by full SHA only, listed in
// tool/commit-baseline.txt. Run: `fvm dart run tool/lint_history.dart`.
import 'dart:io';

import 'src/commit_rule.dart';

Future<void> main() async {
  final baselineFile = File('tool/commit-baseline.txt');
  final baseline = baselineFile.existsSync()
      ? parseBaseline(baselineFile.readAsLinesSync())
      : <String>{};
  final result = await Process.run('git', ['log', '--format=%H%x09%s']);
  if (result.exitCode != 0) {
    stderr.writeln('git log failed:\n${result.stderr}');
    exit(2);
  }
  final out = (result.stdout as String).trim();
  final lines = out.isEmpty ? <String>[] : out.split('\n');
  final offenders = findOffenders(lines, baseline);
  if (offenders.isNotEmpty) {
    stderr.writeln('lint_history: ${offenders.length} offending commit(s):');
    for (final o in offenders) {
      stderr.writeln('  $o');
    }
    exit(1);
  }
  stdout.writeln(
    'lint_history: ${lines.length} commit(s) checked, '
    '${baseline.length} baseline exemption(s), no offenders.',
  );
}
