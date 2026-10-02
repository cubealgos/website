// SPDX-License-Identifier: Apache-2.0

/// The commit subject rule (the same one `tool/hooks/commit-msg` enforces).
library;

/// The allowed Conventional Commit types.
const commitTypes = [
  'feat',
  'fix',
  'docs',
  'style',
  'refactor',
  'perf',
  'test',
  'build',
  'ci',
  'chore',
  'revert',
  'merge',
  'release',
];

/// `type(scope): description (#N)`.
final commitSubjectPattern = RegExp(
  '^(${commitTypes.join('|')})'
  r'\([a-z0-9._/-]+\)!?: .+ \(#[0-9]+\)$',
);

/// Returns an error message for a non-conforming [subject], or `null`.
String? validateCommitSubject(String subject) {
  final trimmed = subject.trimRight();
  if (commitSubjectPattern.hasMatch(trimmed)) return null;
  return 'Commit subject "$trimmed" does not match type(scope): '
      'description (#N); type is one of ${commitTypes.join(' ')}.';
}

/// Commits (`<sha>\t<subject>` lines) that violate the rule and are not in
/// [baseline] (full SHAs).
List<String> findOffenders(List<String> lines, Set<String> baseline) {
  final offenders = <String>[];
  for (final line in lines) {
    final tab = line.indexOf('\t');
    if (tab < 0) continue;
    final sha = line.substring(0, tab);
    final subject = line.substring(tab + 1);
    if (baseline.contains(sha)) continue;
    final error = validateCommitSubject(subject);
    if (error != null) offenders.add('${sha.substring(0, 12)}  $error');
  }
  return offenders;
}

/// Reads SHAs from a baseline file's lines (blank lines and `#` comments
/// ignored).
Set<String> parseBaseline(List<String> lines) => {
  for (final l in lines.map((l) => l.trim()))
    if (l.isNotEmpty && !l.startsWith('#')) l,
};
