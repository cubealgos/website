// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

/// An empty page shell: `<html lang>`, title, description, canonical and
/// hreflang links derived from the route table, and an H1 placeholder.
class PageShell extends StatelessComponent {
  /// Creates the shell of [pageKey] in [lang].
  const new({required this.pageKey, required this.lang, super.key});

  /// Which page this is.
  final PageKey pageKey;

  /// The page's language.
  final Lang lang;

  @override
  Component build(BuildContext context) {
    final meta = pageMeta[pageKey]![lang]!;
    final canonical = urlFor(pageKey, lang);

    return Component.fragment([
      Document.html(attributes: {'lang': lang.code}),
      Document.head(
        title: meta.title,
        children: [
          Component.element(
            tag: 'meta',
            attributes: {'name': 'description', 'content': meta.description},
          ),
          link(href: canonical, rel: 'canonical'),
          for (final alt in Lang.values)
            link(
              href: urlFor(pageKey, alt),
              rel: 'alternate',
              attributes: {'hreflang': alt.code},
            ),
          link(
            href: urlFor(pageKey, Lang.en),
            rel: 'alternate',
            attributes: const {'hreflang': 'x-default'},
          ),
        ],
      ),
      main_([
        h1([Component.text(meta.h1)]),
      ]),
    ]);
  }
}
