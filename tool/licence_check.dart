// SPDX-License-Identifier: Apache-2.0

// Licence gate over pub dependencies (and npm dev tools, once a
// package-lock.json exists). Needs network access to pub.dev.
// Run: `fvm dart run tool/licence_check.dart`.
import 'dart:io';

import 'src/licence_check.dart';

Future<void> main() async {
  exit(
    await runLicenceCheck(root: Directory.current.path, lookup: pubDevLookup),
  );
}
