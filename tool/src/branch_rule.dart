// SPDX-License-Identifier: Apache-2.0

/// The branch naming rule: `<family>/<N>-<slug>`, plus the two long-lived
/// branches.
library;

/// The working-branch families.
const branchFamilies = [
  'feature',
  'bugfix',
  'chore',
  'documentation',
  'release',
  'hotfix',
];

/// The two long-lived, merge-only branches.
const longLivedBranches = ['production', 'development'];

/// `<family>/<N>-<slug>`.
final branchNamePattern = RegExp(
  '^(${branchFamilies.join('|')})/'
  r'[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$',
);

/// Returns an error message for a non-conforming [branch], or `null`.
String? validateBranchName(String branch) {
  if (longLivedBranches.contains(branch)) return null;
  if (branchNamePattern.hasMatch(branch)) return null;
  return 'Branch "$branch" does not match <family>/<N>-<slug> '
      '(family one of ${branchFamilies.join(', ')}).';
}
