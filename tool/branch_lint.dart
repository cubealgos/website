// SPDX-License-Identifier: Apache-2.0

// Checks branch names. With a branch name argument, checks that one (CI passes
// the pushed or PR branch); without, audits every local branch.
// Run: `fvm dart run tool/branch_lint.dart [branch]`.
import 'dart:io';

import 'src/branch_rule.dart';

Future<void> main(List<String> args) async {
  final List<String> branches;
  if (args.isNotEmpty) {
    branches = args;
  } else {
    final result = await Process.run('git', [
      'for-each-ref',
      '--format=%(refname:short)',
      'refs/heads/',
    ]);
    branches = (result.stdout as String).trim().split('\n');
  }
  final errors = [for (final b in branches) ?validateBranchName(b)];
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('branch_lint: ${branches.length} branch name(s) conform.');
}
