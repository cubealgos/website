// SPDX-License-Identifier: Apache-2.0

/// Server entrypoint: `mode: static` pre-renders every route at build time.
library;

import 'package:jaspr/server.dart';
import 'package:website/app.dart';
import 'package:website/main.server.options.dart';

/// Runs the app in the server (pre-rendering) environment.
void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  // No <base>: it would turn every in-page link such as `#main` or `#offers`
  // into a link to the home page. All other URLs are root-absolute.
  runApp(const Document(title: 'Cube Algos', base: null, body: App()));
}
