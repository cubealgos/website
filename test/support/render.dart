// SPDX-License-Identifier: Apache-2.0

/// Renders a component to HTML in a unit test, without a build.
library;

import 'dart:convert';

import 'package:jaspr/server.dart';
import 'package:website/main.server.options.dart';

var _initialised = false;

/// [component] as the HTML it renders to (no document around it).
Future<String> renderHtml(Component component) async {
  if (!_initialised) {
    Jaspr.initializeApp(options: defaultServerOptions);
    _initialised = true;
  }
  final response = await renderComponent(component, standalone: true);
  return utf8.decode(response.body);
}
