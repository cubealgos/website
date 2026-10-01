// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome.dart';
import 'package:website/src/icons.dart';
import 'package:website/src/legal_content.dart';
import 'package:website/src/legal_view.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/pages/about_page.dart';
import 'package:website/src/pages/contact_page.dart';
import 'package:website/src/pages/home_page.dart';
import 'package:website/src/pages/not_found_page.dart';
import 'package:website/src/routes.dart';

/// The pages whose sections rise in on scroll (`reveal.js`).
const Set<PageKey> revealPages = {PageKey.home, PageKey.about, PageKey.contact};

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
          const link(
            href: faviconSvg,
            rel: 'icon',
            attributes: {'type': 'image/svg+xml'},
          ),
          const link(
            href: faviconIco,
            rel: 'icon',
            attributes: {'sizes': 'any'},
          ),
          const link(href: appleTouchIcon, rel: 'apple-touch-icon'),
          const link(href: manifestPath, rel: 'manifest'),
          const link(href: '/fonts/fonts.css', rel: 'stylesheet'),
          const link(href: '/brand/tokens.css', rel: 'stylesheet'),
          const link(href: '/site.css', rel: 'stylesheet'),
          // The sting plays on arrival, not from a page of this site.
          if (pageKey == PageKey.home) const script(src: '/sting.js'),
          // Sections rise in as they scroll into view; content pages only.
          if (revealPages.contains(pageKey)) const script(src: '/reveal.js'),
          // The 404 pages are not indexed and are no equivalents of each other:
          // noindex, and neither a canonical nor hreflang alternates.
          if (pageKey == PageKey.notFound)
            const Component.element(
              tag: 'meta',
              attributes: {'name': 'robots', 'content': 'noindex'},
            )
          else ...[
            link(href: canonical, rel: 'canonical'),
            for (final alt in Lang.values)
              link(
                href: urlFor(pageKey, alt),
                rel: 'alternate',
                attributes: {'hreflang': alt.code},
              ),
            link(
              href: urlFor(pageKey, Lang.de),
              rel: 'alternate',
              attributes: const {'hreflang': 'x-default'},
            ),
          ],
        ],
      ),
      SkipLink(lang: lang),
      SiteHeader(pageKey: pageKey, lang: lang),
      main_(
        id: mainId,
        classes: revealPages.contains(pageKey) ? 'flush' : null,
        attributes: const {'tabindex': '-1'},
        [
          if (legalDocs[pageKey]?[lang] case final doc?)
            LegalPage(heading: meta.h1, doc: doc)
          else if (pageKey == PageKey.home)
            HomePage(lang: lang)
          else if (pageKey == PageKey.about)
            AboutPage(lang: lang)
          else if (pageKey == PageKey.contact)
            ContactPage(lang: lang)
          else if (pageKey == PageKey.notFound)
            NotFoundPage(lang: lang)
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
