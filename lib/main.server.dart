// SPDX-License-Identifier: Apache-2.0

/// Server entrypoint: `mode: static` pre-renders every route at build time.
library;

import 'package:jaspr/server.dart';
import 'package:website/app.dart';
import 'package:website/main.server.options.dart';

/// Runs the app in the server (pre-rendering) environment.
void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(const Document(title: 'Cube Algos', body: App()));
}
