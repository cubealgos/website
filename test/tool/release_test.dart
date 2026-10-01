// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:test/test.dart';

import '../../tool/src/release.dart';

const _changelog = '''
# Changelog

## Unreleased

- next.

## 1.2.3 - 2026-10-01

- shipped.
- also.

## 1.2.2

- old.
''';

void main() {
  test('versionOfTag accepts vX.Y.Z and pre-releases only', () {
    expect(versionOfTag('v1.2.3'), '1.2.3');
    expect(versionOfTag('v0.0.1-rc1'), '0.0.1-rc1');
    expect(() => versionOfTag('1.2.3'), throwsFormatException);
    expect(() => versionOfTag('v1.2'), throwsFormatException);
  });

  test('changelogSection returns the body of that version only', () {
    expect(changelogSection(_changelog, '1.2.3'), '- shipped.\n- also.');
    expect(changelogSection(_changelog, '1.2.2'), '- old.');
    expect(changelogSection(_changelog, '9.9.9'), isNull);
    expect(changelogSection(_changelog, '1.2'), isNull);
  });

  test('validateRelease refuses a mismatch or a missing section', () {
    const pubspec = 'name: x\nversion: 1.2.3\n';
    expect(
      validateRelease(tag: 'v1.2.3', pubspec: pubspec, changelog: _changelog),
      contains('shipped'),
    );
    expect(
      () => validateRelease(
        tag: 'v1.2.4',
        pubspec: pubspec,
        changelog: _changelog,
      ),
      throwsA(
        isA<FormatException>().having((e) => e.message, 'm', contains('match')),
      ),
    );
    expect(
      () => validateRelease(
        tag: 'v1.2.3',
        pubspec: pubspec,
        changelog: '## Unreleased\n- x\n',
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'm',
          contains('CHANGELOG'),
        ),
      ),
    );
  });

  group('archive', () {
    late Directory dir;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('rel');
      File('${dir.path}/b.txt').writeAsStringSync('b');
      Directory('${dir.path}/de').createSync();
      File('${dir.path}/de/index.html').writeAsStringSync('hallo');
      File('${dir.path}/index.html').writeAsStringSync('hi');
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('is byte-identical across builds and mtime-dependent', () {
      final a = gzipDeterministic(buildTar(dir, mtime: 1000));
      File('${dir.path}/b.txt').setLastModifiedSync(DateTime(2001));
      final b = gzipDeterministic(buildTar(dir, mtime: 1000));
      final c = gzipDeterministic(buildTar(dir, mtime: 2000));
      expect(b, a);
      expect(c, isNot(a));
    });

    test('round-trips through the system tar/gzip with sorted entries', () {
      final file = File('${dir.parent.path}/rel_${dir.hashCode}.tar.gz')
        ..writeAsBytesSync(gzipDeterministic(buildTar(dir, mtime: 1000)));
      addTearDown(file.deleteSync);
      final listing = Process.runSync('tar', ['-tzf', file.path]);
      expect(listing.exitCode, 0, reason: '${listing.stderr}');
      expect((listing.stdout as String).trim().split('\n'), [
        'b.txt',
        'de/',
        'de/index.html',
        'index.html',
      ]);
      expect(Process.runSync('gzip', ['-t', file.path]).exitCode, 0);
    }, skip: Platform.isWindows);

    test('checksumLine matches the shasum format', () {
      expect(
        checksumLine([0x61], 'a.tar.gz'),
        'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb'
        '  a.tar.gz\n',
      );
    });
  });
}
