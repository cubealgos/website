// SPDX-License-Identifier: Apache-2.0

// Builds the static site into `build/jaspr/` and prunes it to the deployable
// files: `jaspr build` also leaves the build tooling's own bookkeeping
// (`packages/`, `.dart_tool/`, `.build.manifest`) next to the pages.
//
// Run: `fvm dart run tool/build.dart`.
import 'dart:io';

const _outDir = 'build/jaspr';
const _leftovers = ['packages', '.dart_tool', '.build.manifest'];

Future<void> main() async {
  final result = await Process.start(Platform.resolvedExecutable, [
    'run',
    'jaspr_cli:jaspr',
    'build',
  ], mode: ProcessStartMode.inheritStdio);
  final code = await result.exitCode;
  if (code != 0) {
    exit(code);
  }
  for (final name in _leftovers) {
    final dir = Directory('$_outDir/$name');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    final file = File('$_outDir/$name');
    if (file.existsSync()) file.deleteSync();
  }
  stdout.writeln('static site written to $_outDir');
}
