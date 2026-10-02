// SPDX-License-Identifier: Apache-2.0

// Vendors a pinned `cubealgos/branding` release into web/brand/ and records it
// in brand.lock.json. Never edit web/brand/ by hand.
//
//   fvm dart run tool/brand_sync.dart [--version vX.Y.Z]   download + verify + write
//   fvm dart run tool/brand_sync.dart --check              offline: hash web/brand/ against the lock
import 'dart:io';

import 'src/brand_sync.dart';

Future<void> main(List<String> args) async {
  final brandDir = Directory('web/brand');
  final lockFile = File(lockFileName);
  final lock = lockFile.existsSync()
      ? parseLock(lockFile.readAsStringSync())
      : null;

  if (args.contains('--check')) {
    if (lock == null) {
      stderr.writeln('brand_sync: $lockFileName is missing.');
      exit(1);
    }
    final findings = checkBrand(brandDir, lock);
    if (findings.isNotEmpty) {
      findings.forEach(stderr.writeln);
      stderr.writeln('brand_sync: web/brand/ differs from $lockFileName.');
      exit(1);
    }
    stdout.writeln('brand_sync: web/brand/ matches ${lock.tag}.');
    return;
  }

  final i = args.indexOf('--version');
  final tag = i >= 0 && i + 1 < args.length ? args[i + 1] : lock?.tag;
  if (tag == null || !RegExp(r'^v\d+\.\d+\.\d+$').hasMatch(tag)) {
    stderr.writeln('usage: brand_sync [--version vX.Y.Z] | --check');
    exit(2);
  }
  try {
    final result = await syncBrand(
      tag: tag,
      fetch: (asset) => fetchReleaseAsset(tag, asset),
      brandDir: brandDir,
      lockFile: lockFile,
    );
    stdout.writeln(
      'brand_sync: vendored ${result.files.length} files of $tag.',
    );
  } on BrandSyncException catch (e) {
    stderr.writeln('brand_sync: $e (nothing written).');
    exit(1);
  }
}
