// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/brand_sync.dart';

/// A minimal zip writer for fixtures: stored, or raw-deflate when [deflate].
List<int> _zip(Map<String, String> files, {bool deflate = false}) {
  final out = BytesBuilder();
  final central = BytesBuilder();
  var count = 0;
  for (final e in files.entries) {
    final name = utf8.encode(e.key);
    final raw = utf8.encode(e.value);
    final data = deflate ? ZLibCodec(raw: true).encode(raw) : raw;
    final offset = out.length;
    final local = ByteData(30)
      ..setUint32(0, 0x04034b50, Endian.little)
      ..setUint16(8, deflate ? 8 : 0, Endian.little)
      ..setUint32(18, data.length, Endian.little)
      ..setUint32(22, raw.length, Endian.little)
      ..setUint16(26, name.length, Endian.little);
    out
      ..add(local.buffer.asUint8List())
      ..add(name)
      ..add(data);
    final c = ByteData(46)
      ..setUint32(0, 0x02014b50, Endian.little)
      ..setUint16(10, deflate ? 8 : 0, Endian.little)
      ..setUint32(20, data.length, Endian.little)
      ..setUint32(24, raw.length, Endian.little)
      ..setUint16(28, name.length, Endian.little)
      ..setUint32(42, offset, Endian.little);
    central
      ..add(c.buffer.asUint8List())
      ..add(name);
    count++;
  }
  final cdOffset = out.length;
  out.add(central.toBytes());
  final end = ByteData(22)
    ..setUint32(0, 0x06054b50, Endian.little)
    ..setUint16(8, count, Endian.little)
    ..setUint16(10, count, Endian.little)
    ..setUint32(12, central.length, Endian.little)
    ..setUint32(16, cdOffset, Endian.little);
  out.add(end.buffer.asUint8List());
  return out.toBytes();
}

/// A fake release of [tag]: asset name -> bytes, with a valid SHA256SUMS.
Map<String, List<int>> _release(String tag, {bool deflate = false}) {
  final assets = <String, List<int>>{
    'tokens.css': utf8.encode(':root{}'),
    'logo-$tag.zip': _zip({
      'logo-$tag/LICENSE.md': 'x',
      'logo-$tag/logo/mark.svg': '<svg/>',
      'logo-$tag/logo/clear-space.svg': '<svg/>',
      'logo-$tag/logo/png/mark-ink-128.png': 'png',
      'logo-$tag/favicon/favicon.svg': '<svg/>',
    }, deflate: deflate),
    'fish-$tag.zip': _zip({
      'fish-$tag/fish/idle.svg': '<svg/>',
      'fish-$tag/fish/fish.css': '.a{}',
      'fish-$tag/fish/animated/social/idle-ink.gif': 'gif',
    }, deflate: deflate),
    'sting-$tag.zip': _zip({
      'sting-$tag/sting/sting-paper.svg': '<svg/>',
      'sting-$tag/sting/sting-paper-still.png': 'png',
      'sting-$tag/sting/sting-paper.gif': 'gif',
      'sting-$tag/sting/sting-paper-16x9.mp4': 'mp4',
    }, deflate: deflate),
  };
  assets['SHA256SUMS'] = utf8.encode(
    [for (final e in assets.entries) '${sha256Hex(e.value)}  ${e.key}']
        .join('\n'),
  );
  return assets;
}

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('brand_sync_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<BrandLock> sync(Map<String, List<int>> release) => syncBrand(
    tag: 'v9.9.9',
    fetch: (a) async => release[a]!,
    brandDir: Directory(p.join(tmp.path, 'brand')),
    lockFile: File(p.join(tmp.path, lockFileName)),
  );

  test('readZip reads stored and deflated entries', () {
    for (final deflate in [false, true]) {
      final z = readZip(
        _zip({'a/b.txt': 'hello hello hello'}, deflate: deflate),
      );
      expect(utf8.decode(z['a/b.txt']!), 'hello hello hello');
    }
  });

  test('parseSums reads sha256sum lines', () {
    final h = 'a' * 64;
    expect(parseSums('$h  x.zip\n$h *y.css\n'), {'x.zip': h, 'y.css': h});
  });

  test('sync vendors only what the site uses and writes the lock', () async {
    final lock = await sync(_release('v9.9.9'));
    expect(lock.files.keys.toList(), [
      'favicon/favicon.svg',
      'fish/fish.css',
      'fish/idle.svg',
      'logo/mark.svg',
      'sting/sting-paper-still.png',
      'sting/sting-paper.svg',
      'tokens.css',
    ]);
    final written = File(p.join(tmp.path, lockFileName)).readAsStringSync();
    final parsed = parseLock(written);
    expect(parsed.tag, 'v9.9.9');
    expect(parsed.files, lock.files);
    expect(parsed.encode(), written);
    expect(parsed.files['tokens.css'], sha256Hex(utf8.encode(':root{}')));
  });

  test('a deflated release unpacks the same', () async {
    final stored = await sync(_release('v9.9.9'));
    final deflated = await sync(_release('v9.9.9', deflate: true));
    expect(deflated.files, stored.files);
  });

  test('a sha256 mismatch fails and writes nothing', () async {
    final release = _release('v9.9.9');
    release['fish-v9.9.9.zip'] = [...release['fish-v9.9.9.zip']!, 0];
    await expectLater(
      sync(release),
      throwsA(
        isA<BrandSyncException>().having(
          (e) => e.message,
          'message',
          contains('sha256 mismatch for fish-v9.9.9.zip'),
        ),
      ),
    );
    expect(Directory(p.join(tmp.path, 'brand')).existsSync(), isFalse);
    expect(File(p.join(tmp.path, lockFileName)).existsSync(), isFalse);
  });

  test(
    'check passes, then names modified, missing and unexpected files',
    () async {
      final lock = await sync(_release('v9.9.9'));
      final dir = Directory(p.join(tmp.path, 'brand'));
      File(p.join(dir.path, brandReadme)).writeAsStringSync('hand-written');
      expect(checkBrand(dir, lock), isEmpty);

      File(p.join(dir.path, 'tokens.css')).writeAsStringSync(':root{ }');
      File(p.join(dir.path, 'fish/idle.svg')).deleteSync();
      File(p.join(dir.path, 'extra.svg')).writeAsStringSync('x');
      expect(checkBrand(dir, lock), [
        'missing file: fish/idle.svg',
        'modified file: tokens.css',
        'unexpected file: extra.svg',
      ]);
    },
  );

  test('the committed web/brand/ matches brand.lock.json', () {
    final lock = parseLock(File(lockFileName).readAsStringSync());
    expect(checkBrand(Directory('web/brand'), lock), isEmpty);
  });

  test('tokens.css names the self-hosted font families', () {
    final tokens = File('web/brand/tokens.css').readAsStringSync();
    final fonts = File('web/fonts/fonts.css').readAsStringSync();
    expect(fonts, contains('font-family: "Onest"'));
    expect(fonts, contains('font-family: "DM Mono"'));
    expect(tokens, contains('--font-family-sans: Onest,'));
    expect(tokens, contains('--font-family-mono: "DM Mono",'));
  });
}
