// SPDX-License-Identifier: Apache-2.0

// Installs the repo's git hooks: points `core.hooksPath` at `tool/hooks`.
//
// Run once per clone: `fvm dart run tool/hooks.dart`.
import 'dart:io';

Future<void> main() async {
  final result = await Process.run('git', [
    'config',
    'core.hooksPath',
    'tool/hooks',
  ]);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
  stdout.writeln('git hooks installed (core.hooksPath = tool/hooks)');
}
