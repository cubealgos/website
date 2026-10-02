// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/server.dart';
import 'package:website/src/page.dart';
import 'package:website/src/routes.dart';

/// The app's root: reports every route of the route table to the static
/// build, then renders the shell matching the request path.
class App extends StatefulComponent {
  /// Creates the root component.
  const new({super.key});

  @override
  State<App> createState() => AppState();
}

/// State of [App].
class AppState extends State<App> with PreloadStateMixin {
  @override
  Future<void> preloadState() async {
    for (final byLang in paths.values) {
      for (final path in byLang.values) {
        await ServerApp.requestRouteGeneration(path);
      }
    }
  }

  @override
  Component build(BuildContext context) {
    final route =
        resolve(context.url) ?? (key: PageKey.notFound, lang: Lang.de);
    return PageShell(pageKey: route.key, lang: route.lang);
  }
}
