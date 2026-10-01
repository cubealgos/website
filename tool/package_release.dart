// SPDX-License-Identifier: Apache-2.0

// Packages `build/jaspr/` as the reproducible release archive.
//
// Run (after `fvm dart run tool/build.dart`):
//   fvm dart run tool/package_release.dart --tag v0.1.0 [--mtime <epoch>]
//     [--src build/jaspr] [--out dist]
// Checks the tag against pubspec.yaml and CHANGELOG.md first, then writes
// `site-<tag>.tar.gz`, `site-<tag>.tar.gz.sha256` and `release-notes.md`
// (the CHANGELOG section) into the output directory. `--mtime` defaults to
// the HEAD commit time (`git log -1 --format=%ct`).
import 'dart:io';

import 'src/release.dart';

Future<void> main(List<String> args) async {
  final opts = <String, String>{};
  for (var i = 0; i + 1 < args.length; i += 2) {
    opts[args[i].replaceFirst('--', '')] = args[i + 1];
  }
  final tag = opts['tag'];
  if (tag == null) {
    stderr.writeln('usage: package_release.dart --tag vX.Y.Z [--mtime N]');
    exit(64);
  }
  final src = Directory(opts['src'] ?? 'build/jaspr');
  final out = Directory(opts['out'] ?? 'dist');
  try {
    final notes = validateRelease(
      tag: tag,
      pubspec: File('pubspec.yaml').readAsStringSync(),
      changelog: File('CHANGELOG.md').readAsStringSync(),
    );
    if (!src.existsSync() || src.listSync().isEmpty) {
      throw FormatException('${src.path} is missing or empty: build first');
    }
    final mtime = int.parse(
      opts['mtime'] ??
          (await Process.run('git', [
            'log',
            '-1',
            '--format=%ct',
          ])).stdout.toString().trim(),
    );
    final name = 'site-$tag.tar.gz';
    final archive = gzipDeterministic(buildTar(src, mtime: mtime));
    out.createSync(recursive: true);
    File('${out.path}/$name').writeAsBytesSync(archive);
    File('${out.path}/$name.sha256')
        .writeAsStringSync(checksumLine(archive, name));
    File('${out.path}/release-notes.md').writeAsStringSync('$notes\n');
    stdout.write(
      'package_release: ${out.path}/$name\n'
      '${checksumLine(archive, name)}',
    );
  } on FormatException catch (e) {
    stderr.writeln('package_release: ${e.message}');
    exit(1);
  }
}
