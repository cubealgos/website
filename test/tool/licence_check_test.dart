// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/licence_check.dart';
import '../../tool/src/licence_file.dart';

const _mit = '''
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''';

const _bsd2Head = '''
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
''';

const _bsdEndorse = '''
    * Neither the name of Google LLC nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
''';

const _bsdDisclaimer = '''

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
''';

const _bsd3 = '$_bsd2Head$_bsdEndorse$_bsdDisclaimer';
const _bsd2 = '$_bsd2Head$_bsdDisclaimer';

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

/// A repo fixture. [cache] fakes the pub cache: `name-version` to the text of
/// that package's LICENSE (null: the package is cached without a LICENSE file).
/// [cacheRelative] writes the `package_config.json` URIs relative to
/// `.dart_tool/`, as `dart pub get` does for path packages.
Directory _repo({
  required Map<String, String> pub,
  String? exceptions,
  Map<String, String>? npm,
  Map<String, String?>? cache,
  bool cacheRelative = false,
}) {
  final dir = Directory.systemTemp.createTempSync('licence_check_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File(p.join(dir.path, 'pubspec.lock')).writeAsStringSync(_lock(pub));
  if (cache != null) {
    final cacheDir = Directory(p.join(dir.path, 'pub-cache'));
    final config = Directory(p.join(dir.path, '.dart_tool'))..createSync();
    final packages = <Map<String, String>>[];
    for (final e in cache.entries) {
      final pkgDir = Directory(p.join(cacheDir.path, e.key))
        ..createSync(recursive: true);
      final text = e.value;
      if (text != null) {
        File(p.join(pkgDir.path, 'LICENSE')).writeAsStringSync(text);
      }
      packages.add({
        'name': e.key.substring(0, e.key.lastIndexOf('-')),
        'rootUri': cacheRelative
            ? '../pub-cache/${e.key}'
            : pkgDir.uri.toString(),
      });
    }
    File(
      p.join(config.path, 'package_config.json'),
    ).writeAsStringSync(jsonEncode({'configVersion': 2, 'packages': packages}));
  }
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
  lookup: (name, _) async => tags[name] ?? const [],
  out: log.add,
);

void main() {
  test('a lockfile under tool/<name>/ is checked too', () async {
    final dir = _repo(pub: {'good': '1.0.0'});
    final sub = Directory(p.join(dir.path, 'tool', 'a11y'))
      ..createSync(recursive: true);
    File(p.join(sub.path, 'package-lock.json')).writeAsStringSync(
      jsonEncode({
        'packages': {
          '': {'name': 'a11y'},
          'node_modules/axe-core': {'version': '4.0.0', 'license': 'MPL-2.0'},
        },
      }),
    );
    final log = <String>[];
    expect(
      await _run(dir, {
        'good': ['mit'],
      }, log),
      1,
    );
    expect(log.join('\n'), contains('DENIED: npm:axe-core'));
  });

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

  test('the committed overrides need no entry for what the reader knows', () {
    final yaml = File('tool/licence-exceptions.yaml').readAsStringSync();
    final dir = _repo(pub: {}, exceptions: yaml);
    final overrides = File(p.join(dir.path, 'tool', 'licence-exceptions.yaml'));
    expect(loadVerified(overrides), isEmpty);
  });

  group('a package pub.dev has no licence tag for', () {
    test(
      'is classified from its LICENSE in the pub cache, and says so',
      () async {
        final log = <String>[];
        final dir = _repo(pub: {'gap': '1.0.0'}, cache: {'gap-1.0.0': _mit});
        expect(await _run(dir, {}, log), 0);
        expect(
          log.join('\n'),
          contains(
            'gap 1.0.0: no licence tag on pub.dev; LICENSE in the pub '
            'cache is MIT.',
          ),
        );
      },
    );

    test('also when pub.dev only reports a badge or license:unknown', () async {
      final dir = _repo(pub: {'gap': '1.0.0'}, cache: {'gap-1.0.0': _mit});
      expect(
        await _run(dir, {
          'gap': ['osi-approved', 'unknown'],
        }, []),
        0,
      );
    });

    test('resolves a package_config rootUri relative to .dart_tool', () async {
      final dir = _repo(
        pub: {'gap': '1.0.0'},
        cache: {'gap-1.0.0': _mit},
        cacheRelative: true,
      );
      expect(await _run(dir, {}, []), 0);
    });

    test('with no LICENSE file is denied', () async {
      final log = <String>[];
      final dir = _repo(pub: {'gap': '1.0.0'}, cache: {'gap-1.0.0': null});
      expect(await _run(dir, {}, log), 1);
      expect(log.join('\n'), contains('gap 1.0.0: the package has no LICENSE'));
      expect(log.join('\n'), contains('DENIED: pub:gap 1.0.0: <unknown>'));
    });

    test('that is not in the pub cache is denied', () async {
      final log = <String>[];
      // No package_config.json at all.
      expect(await _run(_repo(pub: {'gap': '1.0.0'}), {}, log), 1);
      expect(log.join('\n'), contains('run `dart pub get` first'));
      // A stale resolution: the cache holds another version.
      expect(
        await _run(
          _repo(pub: {'gap': '1.0.0'}, cache: {'gap-0.9.0': _mit}),
          {},
          [],
        ),
        1,
      );
    });

    test('with an unrecognised LICENSE is denied', () async {
      final log = <String>[];
      final dir = _repo(
        pub: {'gap': '1.0.0'},
        cache: {'gap-1.0.0': 'Do what you like, but buy me a beer.'},
      );
      expect(await _run(dir, {}, log), 1);
      expect(log.join('\n'), contains('is not a standard MIT, BSD or Apache'));
    });

    test('with a GPL LICENSE is denied', () async {
      final dir = _repo(
        pub: {'gap': '1.0.0'},
        cache: {
          'gap-1.0.0': 'GNU GENERAL PUBLIC LICENSE\nVersion 3, 29 June 2007',
        },
      );
      expect(await _run(dir, {}, []), 1);
    });
  });

  test(
    'a package pub.dev tags GPL is denied whatever its LICENSE says',
    () async {
      final log = <String>[];
      final dir = _repo(pub: {'bad': '1.0.0'}, cache: {'bad-1.0.0': _mit});
      expect(
        await _run(dir, {
          'bad': ['gpl-3.0-only'],
        }, log),
        1,
      );
      expect(log.join('\n'), contains('DENIED: pub:bad 1.0.0: GPL-3.0-only'));
      expect(log.join('\n'), isNot(contains('LICENSE in the pub cache')));
    },
  );

  group('classifyLicenceText', () {
    test('reads the standard texts', () {
      expect(classifyLicenceText(_mit), 'MIT');
      expect(classifyLicenceText(_bsd3), 'BSD-3-Clause');
      expect(classifyLicenceText(_bsd2), 'BSD-2-Clause');
      expect(
        classifyLicenceText(File('LICENSE').readAsStringSync()),
        'Apache-2.0',
      );
    });

    test('tolerates a copyright line or contributor list before the text', () {
      expect(
        classifyLicenceText(
          'MIT License\n\nCopyright (c) 2020 A. Person\n\n$_mit',
        ),
        'MIT',
      );
      expect(
        classifyLicenceText(
          'Copyright (c) 2006-2012 The Authors\n\nContributors:\n'
          'James Graham - jg307@cam.ac.uk\nGoogle LLC - misc@dartlang.org\n\n'
          '$_mit',
        ),
        'MIT',
      );
      expect(
        classifyLicenceText(
          'Copyright 2019, the Dart project authors.\n\n$_bsd3',
        ),
        'BSD-3-Clause',
      );
    });

    test('ignores wrapping, case and punctuation', () {
      expect(
        classifyLicenceText(_mit.replaceAll('\n', ' ').toUpperCase()),
        'MIT',
      );
    });

    test('accepts any holder name in the BSD clauses', () {
      expect(
        classifyLicenceText(
          _bsd3
              .replaceAll('Google LLC', 'the copyright holder')
              .replaceAll(
                'THE COPYRIGHT HOLDERS AND CONTRIBUTORS',
                'THE AUTHOR',
              )
              .replaceAll('THE COPYRIGHT OWNER OR CONTRIBUTORS', 'THE AUTHOR'),
        ),
        'BSD-3-Clause',
      );
    });

    test('does not recognise a changed or extended text', () {
      expect(classifyLicenceText(''), isNull);
      expect(classifyLicenceText('MIT'), isNull);
      // A restriction inserted into the MIT grant.
      expect(
        classifyLicenceText(
          _mit.replaceFirst(
            'to use, copy',
            'to use for non-commercial purposes, copy',
          ),
        ),
        isNull,
      );
      // A second licence or clause after the standard text.
      expect(
        classifyLicenceText('$_mit\n\nCommercial use needs a fee.'),
        isNull,
      );
      expect(classifyLicenceText('$_bsd3\n\n$_mit'), isNull);
      // Terms of its own before the standard text.
      expect(
        classifyLicenceText('Free for non-commercial use only.\n\n$_mit'),
        isNull,
      );
      // The BSD-3 text without its non-endorsement clause is BSD-2, not BSD-3.
      expect(classifyLicenceText(_bsd2), isNot('BSD-3-Clause'));
      // Dual-licensed with a copyleft licence.
      expect(
        classifyLicenceText(
          'Dual licensed: MIT or the GNU General Public License v2.\n\n$_mit',
        ),
        isNull,
      );
      // Apache text that lost a section.
      expect(
        classifyLicenceText(
          File('LICENSE').readAsStringSync().replaceFirst('Trademarks.', ''),
        ),
        isNull,
      );
    });
  });

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

  group('pubDevLookup', () {
    test('uses the locked version when it has licence tags', () async {
      final asked = <String>[];
      final got = await pubDevLookup(
        'pkg',
        '4.0.0',
        fetch: (path) async {
          asked.add(path);
          return path == 'pkg/versions/4.0.0/score'
              ? ['license:bsd-3-clause', 'is:dart3-compatible']
              : const [];
        },
      );
      expect(got, ['bsd-3-clause']);
      expect(asked, ['pkg/versions/4.0.0/score']);
    });

    test("does not borrow the latest version's tags", () async {
      final asked = <String>[];
      final got = await pubDevLookup(
        'pkg',
        '4.0.0',
        fetch: (path) async {
          asked.add(path);
          return path == 'pkg/score' ? ['license:mit'] : const [];
        },
      );
      expect(got, isEmpty);
      expect(asked, ['pkg/versions/4.0.0/score']);
    });
  });
}
