// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/licence_check.dart';

String _lock(Map<String, String> versions) {
  final entries = [
    for (final e in versions.entries)
      [
        '  ${e.key}:',
        '    dependency: transitive',
        '    description:',
        '      name: ${e.key}',
        '    source: hosted',
        '    version: "${e.value}"',
      ].join('\n'),
  ];
  return 'packages:\n${entries.join('\n')}\n';
}

Directory _repo({
  required Map<String, String> pub,
  String? exceptions,
  Map<String, String>? npm,
}) {
  final dir = Directory.systemTemp.createTempSync('licence_check_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File(p.join(dir.path, 'pubspec.lock')).writeAsStringSync(_lock(pub));
  if (exceptions != null) {
    Directory(p.join(dir.path, 'tool')).createSync();
    File(p.join(dir.path, 'tool', 'licence-exceptions.yaml'))
        .writeAsStringSync(exceptions);
  }
  if (npm != null) {
    File(p.join(dir.path, 'package-lock.json')).writeAsStringSync(
      jsonEncode({
        'packages': {
          '': {'name': 'root'},
          for (final e in npm.entries)
            'node_modules/${e.key}': {'version': '1.0.0', 'license': e.value},
        },
      }),
    );
  }
  return dir;
}

Future<int> _run(
  Directory dir,
  Map<String, List<String>> tags,
  List<String> log,
) => runLicenceCheck(
  root: dir.path,
  lookup: (name) async => tags[name] ?? const [],
  out: log.add,
);

void main() {
  test('an MIT fixture passes', () async {
    final log = <String>[];
    final dir = _repo(pub: {'good': '1.0.0'});
    expect(
      await _run(dir, {
        'good': ['mit', 'osi-approved'],
      }, log),
      0,
    );
  });

  test('a GPL fixture fails', () async {
    final log = <String>[];
    final dir = _repo(pub: {'bad': '1.0.0'});
    expect(
      await _run(dir, {
        'bad': ['gpl-3.0-only'],
      }, log),
      1,
    );
    expect(log.join('\n'), contains('DENIED: pub:bad 1.0.0'));
  });

  test('an unknown licence fails', () async {
    final dir = _repo(pub: {'mystery': '1.0.0'});
    expect(
      await _run(dir, {
        'mystery': ['unknown'],
      }, []),
      1,
    );
    expect(await _run(dir, {}, []), 1);
  });

  test('MPL-2.0 fails without an exception and passes with one', () async {
    final tags = {
      'mpl': ['mpl-2.0'],
    };
    expect(await _run(_repo(pub: {'mpl': '1.0.0'}), tags, []), 1);
    final log = <String>[];
    final dir = _repo(
      pub: {'mpl': '1.0.0'},
      exceptions: '''
exceptions:
  - package: mpl
    licence: MPL-2.0
    reason: dev tool only
''',
    );
    expect(await _run(dir, tags, log), 0);
    expect(log.join('\n'), contains('mpl (MPL-2.0): dev tool only'));
  });

  test('an exception cannot rescue a GPL package', () async {
    final dir = _repo(
      pub: {'bad': '1.0.0'},
      exceptions: '''
exceptions:
  - package: bad
    licence: GPL-3.0-only
    reason: no
''',
    );
    expect(
      await _run(dir, {
        'bad': ['gpl-3.0-only'],
      }, []),
      1,
    );
  });

  test(
    'a verified entry covers a detection gap at the exact version',
    () async {
      const yaml = '''
exceptions: []
verified:
  - package: gap
    version: 1.0.0
    licence: MIT
    reason: read the LICENSE
''';
      expect(
        await _run(_repo(pub: {'gap': '1.0.0'}, exceptions: yaml), {}, []),
        0,
      );
      expect(
        await _run(_repo(pub: {'gap': '1.0.1'}, exceptions: yaml), {}, []),
        1,
      );
      // Never overrides a licence pub.dev did detect.
      expect(
        await _run(_repo(pub: {'gap': '1.0.0'}, exceptions: yaml), {
          'gap': ['gpl-3.0-only'],
        }, []),
        1,
      );
    },
  );

  test('npm lockfile licences are checked too', () async {
    expect(await _run(_repo(pub: {}, npm: {'a': 'MIT'}), {}, []), 0);
    expect(
      await _run(_repo(pub: {}, npm: {'a': '(MIT OR GPL-3.0-only)'}), {}, []),
      0,
    );
    expect(await _run(_repo(pub: {}, npm: {'a': 'GPL-3.0-only'}), {}, []), 1);
    expect(
      await _run(_repo(pub: {}, npm: {'a': 'MIT AND GPL-3.0-only'}), {}, []),
      1,
    );
  });
}
