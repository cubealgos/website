// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/server.dart';
import 'package:website/src/content/site_content.dart';
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
    for (final route in routesFor(shippedContent)) {
      await ServerApp.requestRouteGeneration(route.path);
    }
  }

  @override
  Component build(BuildContext context) {
    final content = shippedContent;
    final route =
        resolve(context.url, content: content) ??
        const Route(PageKey.notFound, Lang.de);
    return PageShell(route: route, content: content);
  }
}
