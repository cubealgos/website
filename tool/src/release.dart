// SPDX-License-Identifier: Apache-2.0

// The release archive: tag/version/changelog validation and a byte-for-byte
// reproducible `.tar.gz` (sorted entries, fixed mtime, owner 0, no gzip
// filename or timestamp), so rebuilding the same tag gives the same sha256.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

final _tagPattern = RegExp(r'^v(\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?)$');

/// The version in [tag] (`v1.2.3` -> `1.2.3`); throws [FormatException] if
/// the tag is not `vX.Y.Z` (optionally with a pre-release suffix).
String versionOfTag(String tag) {
  final match = _tagPattern.firstMatch(tag);
  if (match == null) {
    throw FormatException('tag "$tag" is not of the form vX.Y.Z');
  }
  return match.group(1)!;
}

/// The `version:` of a pubspec's text, or null.
String? pubspecVersion(String pubspec) => RegExp(
  r'^version:\s*(\S+)\s*$',
  multiLine: true,
).firstMatch(pubspec)?.group(1);

/// The body of the `## <version>` section of [changelog] (heading may be
/// `## 1.2.3`, `## [1.2.3]` or `## 1.2.3 - date`), or null if absent.
String? changelogSection(String changelog, String version) {
  final lines = const LineSplitter().convert(changelog);
  final heading = RegExp('^## \\[?${RegExp.escape(version)}\\]?(\\s.*)?\$');
  final start = lines.indexWhere(heading.hasMatch);
  if (start < 0) return null;
  var end = lines.indexWhere((l) => l.startsWith('## '), start + 1);
  if (end < 0) end = lines.length;
  final body = lines.sublist(start + 1, end).join('\n').trim();
  return body.isEmpty ? null : body;
}

/// Checks [tag] against the pubspec and changelog texts; returns the release
/// notes. Throws [FormatException] with a clear message otherwise.
String validateRelease({
  required String tag,
  required String pubspec,
  required String changelog,
}) {
  final version = versionOfTag(tag);
  final declared = pubspecVersion(pubspec);
  if (declared != version) {
    throw FormatException(
      'tag $tag does not match pubspec.yaml version ${declared ?? "(none)"}',
    );
  }
  final notes = changelogSection(changelog, version);
  if (notes == null) {
    throw FormatException(
      'CHANGELOG.md has no non-empty "## $version" section',
    );
  }
  return notes;
}

void _octal(Uint8List header, int offset, int length, int value) {
  final text = value.toRadixString(8).padLeft(length - 1, '0');
  if (text.length > length - 1) throw RangeError('value too large: $value');
  header.setRange(offset, offset + length - 1, ascii.encode(text));
}

Uint8List _tarHeader({
  required String name,
  required int size,
  required int mtime,
  required bool isDir,
}) {
  final bytes = utf8.encode(name);
  var nameBytes = bytes;
  var prefixBytes = <int>[];
  if (bytes.length > 100) {
    // ustar: split at a "/" so that name <= 100 and prefix <= 155.
    final split = bytes.lastIndexOf(0x2f, 100 + 0);
    if (split < 0 || bytes.length - split - 1 > 100 || split > 155) {
      throw FormatException('path too long for ustar: $name');
    }
    prefixBytes = bytes.sublist(0, split);
    nameBytes = bytes.sublist(split + 1);
  }
  final h = Uint8List(512)..setRange(0, nameBytes.length, nameBytes);
  _octal(h, 100, 8, isDir ? 493 : 420); // 0755 / 0644
  _octal(h, 108, 8, 0); // uid
  _octal(h, 116, 8, 0); // gid
  _octal(h, 124, 12, size);
  _octal(h, 136, 12, mtime);
  h
    ..fillRange(148, 156, 0x20) // checksum placeholder
    ..[156] = isDir
        ? 0x35
        : 0x30 // typeflag
    ..setRange(257, 263, ascii.encode('ustar\x00'))
    ..setRange(263, 265, ascii.encode('00'))
    ..setRange(345, 345 + prefixBytes.length, prefixBytes);
  final sum = h.fold<int>(0, (a, b) => a + b);
  h.setRange(148, 154, ascii.encode(sum.toRadixString(8).padLeft(6, '0')));
  h[154] = 0;
  h[155] = 0x20;
  return h;
}

/// A deterministic ustar archive of the files under [root] (paths relative
/// to it, sorted bytewise, directories included), every mtime [mtime]
/// (seconds since the epoch), owner and group 0 with no names.
Uint8List buildTar(Directory root, {required int mtime}) {
  final rootPath = root.absolute.path;
  final entries = <String, FileSystemEntity>{};
  for (final e in root.listSync(recursive: true, followLinks: false)) {
    if (e is Link) throw FormatException('symlink not allowed: ${e.path}');
    var rel = e.absolute.path.substring(rootPath.length);
    rel = rel.replaceAll(r'\', '/').replaceFirst(RegExp('^/'), '');
    entries[e is Directory ? '$rel/' : rel] = e;
  }
  final names = entries.keys.toList()
    ..sort((a, b) {
      final x = utf8.encode(a);
      final y = utf8.encode(b);
      for (var i = 0; i < x.length && i < y.length; i++) {
        if (x[i] != y[i]) return x[i] - y[i];
      }
      return x.length - y.length;
    });
  final out = BytesBuilder(copy: false);
  for (final name in names) {
    final entity = entries[name]!;
    if (entity is Directory) {
      out.add(_tarHeader(name: name, size: 0, mtime: mtime, isDir: true));
    } else {
      final data = (entity as File).readAsBytesSync();
      out
        ..add(
          _tarHeader(name: name, size: data.length, mtime: mtime, isDir: false),
        )
        ..add(data);
      final pad = (512 - data.length % 512) % 512;
      if (pad > 0) out.add(Uint8List(pad));
    }
  }
  return (out..add(Uint8List(1024))).takeBytes();
}

final List<int> _crcTable = () {
  final table = List<int>.filled(256, 0);
  for (var n = 0; n < 256; n++) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? 0xedb88320 ^ (c >> 1) : c >> 1;
    }
    table[n] = c;
  }
  return table;
}();

int _crc32(List<int> data) {
  var c = 0xffffffff;
  for (final b in data) {
    c = _crcTable[(c ^ b) & 0xff] ^ (c >> 8);
  }
  return c ^ 0xffffffff;
}

/// gzip of [data] with a fixed header: no filename, mtime 0, OS "unknown"
/// (what `gzip -n` omits), so the output depends only on [data].
Uint8List gzipDeterministic(List<int> data) {
  final deflated = ZLibCodec(level: 9, raw: true).encode(data);
  final trailer = ByteData(8)
    ..setUint32(0, _crc32(data), Endian.little)
    ..setUint32(4, data.length & 0xffffffff, Endian.little);
  return (BytesBuilder(copy: false)
        ..add([0x1f, 0x8b, 8, 0, 0, 0, 0, 0, 2, 255])
        ..add(deflated)
        ..add(trailer.buffer.asUint8List()))
      .takeBytes();
}

/// The `.sha256` file content for [archive] named [fileName], in the format
/// `shasum -a 256 -c` verifies.
String checksumLine(List<int> archive, String fileName) =>
    '${sha256.convert(archive)}  $fileName\n';
