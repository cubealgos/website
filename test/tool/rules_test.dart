// SPDX-License-Identifier: Apache-2.0

import 'package:test/test.dart';

import '../../tool/src/branch_rule.dart';
import '../../tool/src/commit_rule.dart';

void main() {
  group('commit subject', () {
    test('accepts conforming subjects', () {
      for (final s in [
        'chore(repo): test (#3)',
        'feat(site)!: break things (#12)',
        'merge(site): feature/4-x into development (#4)',
        'release(site): 1.0.0 (#9)',
      ]) {
        expect(validateCommitSubject(s), isNull, reason: s);
      }
    });
    test('rejects non-conforming subjects', () {
      for (final s in [
        'bad',
        'chore: no scope (#3)',
        'chore(repo): no issue',
        'wip(repo): x (#1)',
        'fixup! chore(repo): x (#1)',
        'Merge pull request #5 from x/y',
      ]) {
        expect(validateCommitSubject(s), isNotNull, reason: s);
      }
    });
    test('baseline exempts by full SHA only', () {
      final sha = 'a' * 40;
      final lines = ['$sha\tbad subject', '${'b' * 40}\tbad subject'];
      expect(findOffenders(lines, {sha}), hasLength(1));
      expect(parseBaseline(['# c', '', sha]), {sha});
    });
  });

  group('branch name', () {
    test('accepts long-lived and conforming branches', () {
      for (final b in [
        'development',
        'production',
        'feature/4-jaspr-scaffold',
        'hotfix/10-x',
      ]) {
        expect(validateBranchName(b), isNull, reason: b);
      }
    });
    test('rejects others', () {
      for (final b in ['main', 'feature/no-number', 'wip/4-x', 'chore/4-Big']) {
        expect(validateBranchName(b), isNotNull, reason: b);
      }
    });
  });
}
