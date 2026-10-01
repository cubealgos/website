// SPDX-License-Identifier: Apache-2.0

/// The licence gate: every pub dependency (from `pubspec.lock`) and every npm
/// dev tool (from `package-lock.json`, if one exists) must be on the policy's
/// allow list, or be recorded as a per-package exception.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'licence_policy.dart';

/// Returns the licence identifiers of a pub package: pub.dev `license:` tag
/// suffixes (e.g. `mit`, `bsd-3-clause`).
typedef PubLicenceLookup = Future<List<String>> Function(String package);

/// A recorded exception in `tool/licence-exceptions.yaml`.
class LicenceException {
  /// Creates an exception for [package] under [licence].
  const new(this.package, this.licence, this.reason);

  /// The package name.
  final String package;

  /// The SPDX identifier the exception was granted for (a relicense stops it
  /// matching).
  final String licence;

  /// Why this is safe.
  final String reason;

  @override
  String toString() => '$package ($licence): $reason';
}

/// A hand-verified licence for a package pub.dev detected nothing for (a
/// detection gap, not a policy call). Matches the exact version only and never
/// overrides a licence pub.dev did detect; the recorded licence must itself be
/// on the allow list.
class VerifiedLicence {
  /// Creates a verified entry for [package] at [version].
  const new(this.package, this.version, this.licence, this.reason);

  /// The package name.
  final String package;

  /// The exact resolved version that was read.
  final String version;

  /// The SPDX identifier found in the package's LICENSE file.
  final String licence;

  /// How it was verified.
  final String reason;

  @override
  String toString() => '$package $version ($licence): $reason';
}

/// One dependency to check.
class Dependency {
  /// Creates a dependency of [ecosystem] (`pub` or `npm`).
  const new(this.ecosystem, this.name, this.version, this.licences);

  /// `pub` or `npm`.
  final String ecosystem;

  /// The package name.
  final String name;

  /// The resolved version.
  final String version;

  /// Detected SPDX identifiers (empty when unknown).
  final List<String> licences;

  @override
  String toString() => '$ecosystem:$name $version';
}

/// The outcome of checking one dependency.
enum Verdict {
  /// On the allow list.
  allowed,

  /// MPL-2.0 (or similar) covered by a recorded exception.
  exempted,

  /// Denied, or unknown.
  denied,
}

/// Classifies [dep] against the policy and [exceptions].
Verdict classify(
  Dependency dep,
  List<LicenceException> exceptions, [
  List<VerifiedLicence> verified = const [],
]) {
  if (dep.licences.isEmpty &&
      verified.any(
        (v) =>
            v.package == dep.name &&
            v.version == dep.version &&
            allowedLicences.contains(v.licence),
      )) {
    return Verdict.allowed;
  }
  if (dep.licences.any(allowedLicences.contains)) return Verdict.allowed;
  for (final licence in dep.licences) {
    if (isDeniedFamily(licence)) continue;
    final covered = exceptions.any(
      (e) => e.package == dep.name && e.licence == licence,
    );
    if (covered && licence == mplLicence) return Verdict.exempted;
  }
  return Verdict.denied;
}

/// Loads `exceptions:` from [file] (missing file: none).
List<LicenceException> loadExceptions(File file) {
  if (!file.existsSync()) return const [];
  final doc = loadYaml(file.readAsStringSync());
  final list = doc is YamlMap ? doc['exceptions'] : null;
  if (list is! YamlList) return const [];
  return [
    for (final e in list)
      LicenceException(
        '${(e as YamlMap)['package']}',
        '${e['licence']}',
        '${e['reason']}',
      ),
  ];
}

/// Loads `verified:` from [file] (missing file: none).
List<VerifiedLicence> loadVerified(File file) {
  if (!file.existsSync()) return const [];
  final doc = loadYaml(file.readAsStringSync());
  final list = doc is YamlMap ? doc['verified'] : null;
  if (list is! YamlList) return const [];
  return [
    for (final e in list)
      VerifiedLicence(
        '${(e as YamlMap)['package']}',
        '${e['version']}',
        '${e['licence']}',
        '${e['reason']}',
      ),
  ];
}

/// Splits an npm SPDX expression into the alternatives that are acceptable on
/// their own: `MIT OR GPL-3.0` offers MIT, so it is allowed through MIT.
List<String> npmLicences(Object? license) {
  if (license is! String) return const [];
  final cleaned = license.replaceAll(RegExp('[()]'), '').trim();
  if (cleaned.isEmpty) return const [];
  if (cleaned.contains(' AND ')) {
    // All parts apply: only acceptable when every part is.
    final parts = cleaned.split(' AND ').map((s) => s.trim()).toList();
    return parts.every(allowedLicences.contains) ? [parts.first] : [cleaned];
  }
  return cleaned.split(' OR ').map((s) => s.trim()).toList();
}

/// Collects every hosted pub package and npm package of the repo at [root].
Future<List<Dependency>> collectDependencies(
  String root,
  PubLicenceLookup lookup,
) async {
  final deps = <Dependency>[];
  final pubLock = File(p.join(root, 'pubspec.lock'));
  if (pubLock.existsSync()) {
    final doc = loadYaml(pubLock.readAsStringSync()) as YamlMap;
    final packages = doc['packages'] as YamlMap? ?? YamlMap();
    for (final entry in packages.entries) {
      final pkg = entry.value as YamlMap;
      if (pkg['source'] != 'hosted') continue;
      final name = '${entry.key}';
      final tags = await lookup(name);
      final licences = [
        for (final t in tags)
          if (!pubDevNonLicenceTags.contains(t) && pubDevTagToSpdx[t] != null)
            pubDevTagToSpdx[t]!,
      ];
      deps.add(Dependency('pub', name, '${pkg['version']}', licences));
    }
  }
  final npmLock = File(p.join(root, 'package-lock.json'));
  if (npmLock.existsSync()) {
    final doc = jsonDecode(npmLock.readAsStringSync()) as Map<String, dynamic>;
    final packages = (doc['packages'] as Map<String, dynamic>?) ?? {};
    for (final entry in packages.entries) {
      if (entry.key.isEmpty) continue; // the root project itself
      final pkg = entry.value as Map<String, dynamic>;
      final name = entry.key.split('node_modules/').last;
      deps.add(
        Dependency(
          'npm',
          name,
          '${pkg['version']}',
          npmLicences(pkg['license']),
        ),
      );
    }
  }
  return deps;
}

/// Runs the gate over [root], printing a report; returns the exit code.
Future<int> runLicenceCheck({
  required String root,
  required PubLicenceLookup lookup,
  void Function(String) out = print,
}) async {
  final overrides = File(p.join(root, 'tool', 'licence-exceptions.yaml'));
  final exceptions = loadExceptions(overrides);
  final verified = loadVerified(overrides);
  final deps = await collectDependencies(root, lookup);
  final verdicts = {for (final d in deps) d: classify(d, exceptions, verified)};
  final denied = [
    for (final e in verdicts.entries)
      if (e.value == Verdict.denied) e.key,
  ];

  out(
    'licence_check: ${deps.length} package(s) checked, '
    '${verdicts.values.where((v) => v == Verdict.allowed).length} allowed, '
    '${verdicts.values.where((v) => v == Verdict.exempted).length} exempted, '
    '${denied.length} denied.',
  );
  out(
    exceptions.isEmpty
        ? 'Recorded exceptions: none.'
        : 'Recorded exceptions (${exceptions.length}):',
  );
  for (final e in exceptions) {
    out('  - $e');
  }
  out(
    verified.isEmpty
        ? 'Verified detection-gap overrides: none.'
        : 'Verified detection-gap overrides (${verified.length}):',
  );
  for (final v in verified) {
    out('  - $v');
  }
  for (final d in denied) {
    final licence = d.licences.isEmpty ? '<unknown>' : d.licences.join('/');
    out('DENIED: $d: $licence');
  }
  return denied.isEmpty ? 0 : 1;
}

/// The real lookup: pub.dev's score API `license:` tags.
Future<List<String>> pubDevLookup(String package) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('https://pub.dev/api/packages/$package/score'),
    );
    final response = await request.close();
    if (response.statusCode != 200) {
      throw StateError('pub.dev returned ${response.statusCode} for $package');
    }
    final body = await response.transform(utf8.decoder).join();
    final tags = (jsonDecode(body) as Map<String, dynamic>)['tags'] as List;
    return [
      for (final t in tags.cast<String>())
        if (t.startsWith('license:')) t.substring('license:'.length),
    ];
  } finally {
    client.close();
  }
}
