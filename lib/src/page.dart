// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/pages/home_page.dart';
import 'package:website/src/routes.dart';

/// The page shell: `<html lang>`, title, description, canonical and hreflang
/// links derived from the route table, the skip link, header and footer, and
/// an H1 placeholder in `<main>`.
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
          // Only the display face is preloaded; the others load on first use.
          const link(
            href: '/fonts/onest-800.woff2',
            rel: 'preload',
            attributes: {'as': 'font', 'type': 'font/woff2', 'crossorigin': ''},
          ),
          const link(href: '/fonts/fonts.css', rel: 'stylesheet'),
          const link(href: '/brand/tokens.css', rel: 'stylesheet'),
          const link(href: '/site.css', rel: 'stylesheet'),
          // The sting plays once per session, on the home page only.
          if (pageKey == PageKey.home) const script(src: '/sting.js'),
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
      SkipLink(lang: lang),
      SiteHeader(pageKey: pageKey, lang: lang),
      main_(
        id: mainId,
        attributes: const {'tabindex': '-1'},
        [
          if (pageKey == PageKey.home)
            HomePage(lang: lang)
          else
            div(classes: 'wrap', [
              h1(classes: 'rise', [Component.text(meta.h1)]),
            ]),
        ],
      ),
      SiteFooter(pageKey: pageKey, lang: lang),
    ]);
  }
}
