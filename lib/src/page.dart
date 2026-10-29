// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/icons.dart';
import 'package:website/src/legal_content.dart';
import 'package:website/src/legal_view.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/pages/blog_pages.dart';
import 'package:website/src/pages/contact_page.dart';
import 'package:website/src/pages/home_page.dart';
import 'package:website/src/pages/not_found_page.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';
import 'package:website/src/sting.dart';

/// The pages whose sections rise in on scroll (`reveal.js`).
const Set<PageKey> revealPages = {PageKey.contact, PageKey.blog};

/// The pages whose sections run edge to edge (`main.flush`): the ledger pages.
/// The legal pages and the 404 pages keep the padded `<main>`; the home page
/// is the business card and sets its own padding (`main.bc-main`).
const Set<PageKey> flushPages = {PageKey.contact, PageKey.blog, PageKey.post};

/// The page shell: `<html lang>`, title, description, canonical and hreflang
/// links derived from the route table, the skip link, header and footer, and
/// the body of the page.
class PageShell extends StatelessComponent {
  /// Creates the shell of [route] over [content]. [productNamed] is whether
  /// the site names wearenotabank (its [namesProduct]).
  const new({
    required this.route,
    required this.content,
    this.productNamed = namesProduct,
    super.key,
  });

  /// Which page this is.
  final Route route;

  /// The posts of the site.
  final SiteContent content;

  /// Whether the pages that can name wearenotabank do.
  final bool productNamed;

  @override
  Component build(BuildContext context) {
    final key = route.key;
    final lang = route.lang;
    final meta = metaFor(route, content, named: productNamed);
    final canonical = route.url;
    final alternates = route.alternates(content);
    final xDefault =
        '$siteOrigin${route.pathIn(route.xDefault(content), content)}';

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
          // The sting's keyframes, extracted from the vendored SVG by the
          // build.
          if (key == PageKey.home)
            const link(href: stingCssPath, rel: 'stylesheet'),
          // The sting plays on arrival, not from a page of this site.
          if (key == PageKey.home) const script(src: '/sting.js'),
          // Sections rise in as they scroll into view; content pages only.
          if (revealPages.contains(key)) const script(src: '/reveal.js'),
          // The 404 pages are not indexed and are no equivalents of each other:
          // noindex, and neither a canonical nor hreflang alternates.
          if (key == PageKey.notFound)
            const Component.element(
              tag: 'meta',
              attributes: {'name': 'robots', 'content': 'noindex'},
            )
          else ...[
            link(href: canonical, rel: 'canonical'),
            // Only the languages the page exists in (a post may exist in one).
            for (final alt in alternates)
              link(
                href: '$siteOrigin${route.pathIn(alt, content)}',
                rel: 'alternate',
                attributes: {'hreflang': alt.code},
              ),
            link(
              href: xDefault,
              rel: 'alternate',
              attributes: const {'hreflang': 'x-default'},
            ),
            ..._shareTags(meta, canonical, alternates.length > 1),
          ],
        ],
      ),
      SkipLink(lang: lang),
      SiteHeader(route: route, content: content),
      main_(
        id: mainId,
        classes: switch (key) {
          PageKey.home => 'bc-main',
          _ when flushPages.contains(key) => 'flush',
          _ => null,
        },
        attributes: const {'tabindex': '-1'},
        [
          if (legalDocs[key]?[lang] case final doc?)
            LegalPage(heading: meta.h1, doc: doc)
          else
            switch (key) {
              PageKey.home => HomePage(
                lang: lang,
                content: content,
                productNamed: productNamed,
              ),
              PageKey.contact => ContactPage(
                lang: lang,
                productNamed: productNamed,
              ),
              PageKey.blog => BlogIndexPage(lang: lang, content: content),
              PageKey.post => PostPage(
                post: content.postBySlug(lang, route.slug!)!,
                content: content,
              ),
              PageKey.notFound => NotFoundPage(lang: lang),
              PageKey.impressum || PageKey.datenschutz => div(classes: 'wrap', [
                h1(classes: 'rise', [Component.text(meta.h1)]),
              ]),
            },
        ],
      ),
      SiteFooter(route: route),
    ]);
  }

  /// Open Graph and Twitter card tags: one share image per language.
  List<Component> _shareTags(
    PageMeta meta,
    String canonical,
    bool hasAlternate,
  ) {
    final lang = route.lang;
    final image = shareImageUrl(lang);
    // What the share image shows: the eyebrow, then the H1.
    final alt =
        '${homeCopy[lang]!.eyebrow}. '
        '${fixedMeta(PageKey.home, lang, named: productNamed).h1}';
    Component tag(String key, String value, {bool property = true}) =>
        Component.element(
          tag: 'meta',
          attributes: {(property ? 'property' : 'name'): key, 'content': value},
        );
    return [
      tag('og:type', 'website'),
      tag('og:site_name', 'Cube Algos'),
      tag('og:title', meta.title),
      tag('og:description', meta.description),
      tag('og:url', canonical),
      tag('og:locale', ogLocale(lang)),
      if (hasAlternate) tag('og:locale:alternate', ogLocale(lang.other)),
      tag('og:image', image),
      tag('og:image:type', 'image/png'),
      tag('og:image:width', '$shareImageWidth'),
      tag('og:image:height', '$shareImageHeight'),
      tag('og:image:alt', alt),
      tag('twitter:card', 'summary_large_image', property: false),
      tag('twitter:title', meta.title, property: false),
      tag('twitter:description', meta.description, property: false),
      tag('twitter:image', image, property: false),
      tag('twitter:image:alt', alt, property: false),
    ];
  }
}
