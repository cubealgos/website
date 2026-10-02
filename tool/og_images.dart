// SPDX-License-Identifier: Apache-2.0

// Generates the share images in `web/og/` (1200 x 630 PNG, one per language)
// with the system Chrome, or with `--check` verifies them offline: the inputs
// digest in `tool/og_images.lock` is current and both PNGs are 1200 x 630.
//
// Run: `fvm dart run tool/og_images.dart [--check]`.
import 'dart:io';

import 'src/og_images.dart';

Future<void> main(List<String> args) async {
  if (args.contains('--check')) {
    final problems = checkImages();
    if (problems.isNotEmpty) {
      problems.forEach(stderr.writeln);
      exit(1);
    }
    stdout.writeln('og_images: share images are current.');
    return;
  }
  await generateImages();
  stdout.writeln('og_images: wrote $ogDir/ and $lockFile.');
}
