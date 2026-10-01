// SPDX-License-Identifier: Apache-2.0

/// Vendors a pinned `cubealgos/branding` release into `web/brand/`.
///
/// The release assets are verified against the release's `SHA256SUMS` before
/// anything is written; `brand.lock.json` records the tag and the sha256 of
/// every vendored file; [checkBrand] re-hashes the directory offline.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// The upstream repository.
const brandRepo = 'cubealgos/branding';

/// The lock file at the repo root.
const lockFileName = 'brand.lock.json';

/// The hand-written file in `web/brand/` that is not vendored.
const brandReadme = 'README.md';

/// Raised when a sync or check cannot proceed; the message names the cause.
class BrandSyncException implements Exception {
  /// Creates an exception with [message].
  const new(this.message);

  /// What went wrong.
  final String message;

  @override
  String toString() => message;
}

/// The lowercase hex sha256 of [bytes].
String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

/// Parses `sha256sum` output (`<hex>  <name>`) into name -> hex.
Map<String, String> parseSums(String text) {
  final out = <String, String>{};
  for (final line in const LineSplitter().convert(text)) {
    final m = RegExp(r'^([0-9a-fA-F]{64})\s+\*?(\S+)$').firstMatch(line.trim());
    if (m != null) out[m[2]!] = m[1]!.toLowerCase();
  }
  return out;
}

/// Reads a zip archive (stored or deflate, no zip64) into path -> bytes.
/// Directory entries are skipped.
Map<String, List<int>> readZip(List<int> data) {
  final bytes = Uint8List.fromList(data);
  final view = ByteData.sublistView(bytes);
  var eocd = -1;
  for (var i = bytes.length - 22; i >= 0; i--) {
    if (view.getUint32(i, Endian.little) == 0x06054b50) {
      eocd = i;
      break;
    }
  }
  if (eocd < 0) throw const BrandSyncException('not a zip archive');
  final count = view.getUint16(eocd + 10, Endian.little);
  var pos = view.getUint32(eocd + 16, Endian.little);
  final out = <String, List<int>>{};
  for (var n = 0; n < count; n++) {
    if (view.getUint32(pos, Endian.little) != 0x02014b50) {
      throw const BrandSyncException('corrupt zip central directory');
    }
    final method = view.getUint16(pos + 10, Endian.little);
    final compressed = view.getUint32(pos + 20, Endian.little);
    final nameLen = view.getUint16(pos + 28, Endian.little);
    final extraLen = view.getUint16(pos + 30, Endian.little);
    final commentLen = view.getUint16(pos + 32, Endian.little);
    final local = view.getUint32(pos + 42, Endian.little);
    final name = utf8.decode(bytes.sublist(pos + 46, pos + 46 + nameLen));
    pos += 46 + nameLen + extraLen + commentLen;
    if (name.endsWith('/')) continue;
    final lNameLen = view.getUint16(local + 26, Endian.little);
    final lExtraLen = view.getUint16(local + 28, Endian.little);
    final start = local + 30 + lNameLen + lExtraLen;
    final raw = bytes.sublist(start, start + compressed);
    out[name] = switch (method) {
      0 => raw,
      8 => ZLibCodec(raw: true).decode(raw),
      _ => throw BrandSyncException('zip method $method unsupported: $name'),
    };
  }
  return out;
}

/// What the site uses of each release zip: the relative path inside the zip's
/// top folder -> kept. Everything else (PNG exports, GIF, video, social
/// renders, licence pointers, diagrams) stays upstream.
final _keep = <RegExp>[
  RegExp(r'^logo/[^/]+\.svg$'),
  RegExp(r'^logo/svg/[^/]+\.svg$'),
  RegExp(r'^favicon/(?!.*-snippet\.)[^/]+$'),
  RegExp(r'^fish/(on-amber/|animated/|animated/on-amber/)?[^/]+\.svg$'),
  RegExp(r'^fish/fish\.css$'),
  RegExp(r'^sting/sting-(paper|ink|amber)(-still)?\.svg$'),
  RegExp(r'^sting/sting-(paper|ink|amber)-still\.png$'),
  RegExp(r'^sting/sting-mark(-still)?\.svg$'),
];

bool _wanted(String rel) =>
    !rel.endsWith('LICENSE.md') &&
    rel != 'logo/clear-space.svg' &&
    _keep.any((r) => r.hasMatch(rel));

/// The release assets the sync needs for [tag].
List<String> assetNames(String tag) => [
  'tokens.css',
  'logo-$tag.zip',
  'fish-$tag.zip',
  'sting-$tag.zip',
];

/// Picks the vendored files (path under `web/brand/` -> bytes) out of the
/// downloaded [assets] (asset name -> bytes) of release [tag].
Map<String, List<int>> selectFiles(String tag, Map<String, List<int>> assets) {
  final out = <String, List<int>>{'tokens.css': assets['tokens.css']!};
  for (final kind in ['logo', 'fish', 'sting']) {
    final zip = readZip(assets['$kind-$tag.zip']!);
    final prefix = '$kind-$tag/';
    for (final e in zip.entries) {
      if (!e.key.startsWith(prefix)) continue;
      final rel = e.key.substring(prefix.length);
      if (_wanted(rel)) out[rel] = e.value;
    }
  }
  return Map.fromEntries(
    out.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

/// The parsed `brand.lock.json`.
class BrandLock {
  /// Creates a lock of [tag] with [files] (path -> sha256).
  const new(this.tag, this.files);

  /// The release tag, e.g. `v1.0.0`.
  final String tag;

  /// Path under `web/brand/` -> sha256 hex.
  final Map<String, String> files;

  /// The committed text form (sorted keys, trailing newline).
  String encode() {
    final sorted = Map.fromEntries(
      files.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    const encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert({
      'repository': brandRepo,
      'tag': tag,
      'files': sorted,
    });
    return '$json\n';
  }
}

/// Re-hashes [brandDir] against [lock]; returns one finding per modified,
/// missing or unexpected file. Offline.
List<String> checkBrand(Directory brandDir, BrandLock lock) {
  final findings = <String>[];
  final seen = <String>{};
  if (brandDir.existsSync()) {
    for (final f in brandDir.listSync(recursive: true)) {
      if (f is! File) continue;
      final rel = p.posix.joinAll(
        p.split(p.relative(f.path, from: brandDir.path)),
      );
      if (rel == brandReadme) continue;
      seen.add(rel);
      final expected = lock.files[rel];
      if (expected == null) {
        findings.add('unexpected file: $rel');
      } else if (sha256Hex(f.readAsBytesSync()) != expected) {
        findings.add('modified file: $rel');
      }
    }
  }
  for (final rel in lock.files.keys) {
    if (!seen.contains(rel)) findings.add('missing file: $rel');
  }
  return findings..sort();
}

/// Downloads, verifies and vendors release [tag]. [fetch] returns the bytes
/// of one release asset by name. Nothing is written unless every asset
/// matches `SHA256SUMS`.
Future<BrandLock> syncBrand({
  required String tag,
  required Future<List<int>> Function(String asset) fetch,
  required Directory brandDir,
  required File lockFile,
}) async {
  final sums = parseSums(utf8.decode(await fetch('SHA256SUMS')));
  final assets = <String, List<int>>{};
  for (final name in assetNames(tag)) {
    final expected = sums[name];
    if (expected == null) {
      throw BrandSyncException('$name is not listed in SHA256SUMS of $tag');
    }
    final bytes = await fetch(name);
    final actual = sha256Hex(bytes);
    if (actual != expected) {
      throw BrandSyncException(
        'sha256 mismatch for $name: expected $expected, got $actual',
      );
    }
    assets[name] = bytes;
  }
  final files = selectFiles(tag, assets);
  if (brandDir.existsSync()) {
    for (final e in brandDir.listSync()) {
      if (p.basename(e.path) != brandReadme) e.deleteSync(recursive: true);
    }
  }
  for (final e in files.entries) {
    File(p.joinAll([brandDir.path, ...p.posix.split(e.key)]))
      ..createSync(recursive: true)
      ..writeAsBytesSync(e.value);
  }
  final lock = BrandLock(tag, {
    for (final e in files.entries) e.key: sha256Hex(e.value),
  });
  lockFile.writeAsStringSync(lock.encode());
  return lock;
}

/// Fetches a release asset over HTTPS from the public GitHub release.
Future<List<int>> fetchReleaseAsset(String tag, String asset) async {
  final client = HttpClient();
  try {
    final uri = Uri.https(
      'github.com',
      '/$brandRepo/releases/download/$tag/$asset',
    );
    final res = await (await client.getUrl(uri)).close();
    if (res.statusCode != 200) {
      throw BrandSyncException('GET $uri -> HTTP ${res.statusCode}');
    }
    return await res.fold<List<int>>(<int>[], (a, b) => a..addAll(b));
  } finally {
    client.close();
  }
}

/// Parses `brand.lock.json` [json] text.
BrandLock parseLock(String json) {
  final map = jsonDecode(json) as Map<String, dynamic>;
  return BrandLock(
    map['tag'] as String,
    (map['files'] as Map<String, dynamic>).cast<String, String>(),
  );
}
