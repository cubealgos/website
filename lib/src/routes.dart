// SPDX-License-Identifier: Apache-2.0

/// The one route table: every page key with its path in both languages.
///
/// The language switch, hreflang alternates, canonical URLs and the sitemap
/// all derive from [paths], [routePath] and [routesFor]; nothing else spells a
/// URL. The pages of the works and the posts exist only for content that
/// exists: [routesFor] lists exactly what is built.
library;

import 'package:website/src/content/site_content.dart';

/// A site language. German is the default and lives at the root.
enum Lang {
  /// German, at the root (`/`).
  de('de'),

  /// English, under `/en/`.
  en('en');

  new(this.code);

  /// The value of `<html lang>` and of `hreflang`.
  final String code;

  /// The other language.
  Lang get other => this == de ? en : de;
}

/// The pages of the site. Every page exists in both languages.
enum PageKey {
  /// The home page.
  home,

  /// The about page.
  about,

  /// The contact page.
  contact,

  /// The index of the works. Built only when there is a work.
  works,

  /// One work (`/arbeiten/<slug>/`).
  work,

  /// The index of the posts. Built only when there is a post.
  blog,

  /// One post (`/blog/<slug>/`).
  post,

  /// The legal notice (Impressum).
  impressum,

  /// The privacy notice (Datenschutz).
  datenschutz,

  /// The 404 page (a flat `404.html` per language).
  notFound,
}

/// The origin every canonical and hreflang URL is built on.
const siteOrigin = 'https://cubealgos.de';

/// The path of every page in every language, with a leading slash. Directory
/// pages end in `/` and build to `<path>index.html`; the 404 pages are flat
/// files. [PageKey.work] and [PageKey.post] are the pages under the paths of
/// [PageKey.works] and [PageKey.blog]; each adds its slug (see [routePath]).
const Map<PageKey, Map<Lang, String>> paths = {
  PageKey.home: {Lang.de: '/', Lang.en: '/en/'},
  PageKey.about: {Lang.de: '/ueber/', Lang.en: '/en/about/'},
  PageKey.contact: {Lang.de: '/kontakt/', Lang.en: '/en/contact/'},
  PageKey.works: {Lang.de: '/arbeiten/', Lang.en: '/en/work/'},
  PageKey.blog: {Lang.de: '/blog/', Lang.en: '/en/blog/'},
  PageKey.impressum: {Lang.de: '/impressum/', Lang.en: '/en/impressum/'},
  PageKey.datenschutz: {Lang.de: '/datenschutz/', Lang.en: '/en/datenschutz/'},
  PageKey.notFound: {Lang.de: '/404.html', Lang.en: '/en/404.html'},
};

/// The path of [key] in [lang]; [slug] is the work or post of a [PageKey.work]
/// or [PageKey.post] page.
String routePath(PageKey key, Lang lang, [String? slug]) => switch (key) {
  PageKey.work => '${paths[PageKey.works]![lang]!}${slug!}/',
  PageKey.post => '${paths[PageKey.blog]![lang]!}${slug!}/',
  PageKey.home ||
  PageKey.about ||
  PageKey.contact ||
  PageKey.works ||
  PageKey.blog ||
  PageKey.impressum ||
  PageKey.datenschutz ||
  PageKey.notFound => paths[key]![lang]!,
};

/// The path of [key] in [lang], for a page without a slug.
String pathFor(PageKey key, Lang lang) => routePath(key, lang);

/// The absolute URL of [key] in [lang] (canonical and hreflang).
String urlFor(PageKey key, Lang lang) => '$siteOrigin${pathFor(key, lang)}';

/// One built page: its key, language and, for a work or a post, its slug.
class Route {
  /// Creates the route of [key] in [lang].
  const new(this.key, this.lang, [this.slug]);

  /// The page.
  final PageKey key;

  /// The page's language.
  final Lang lang;

  /// The slug of a [PageKey.work] or [PageKey.post] page.
  final String? slug;

  /// The path, with a leading slash.
  String get path => routePath(key, lang, slug);

  /// The absolute URL.
  String get url => '$siteOrigin$path';

  /// The languages this page exists in, German first: both, except for a post
  /// written in one language only.
  List<Lang> alternates(SiteContent content) {
    if (key == PageKey.post) {
      final post = content.postBySlug(lang, slug!);
      final other = post == null ? null : content.translationOf(post);
      return [
        for (final l in Lang.values)
          if (l == lang || (other != null && l == other.lang)) l,
      ];
    }
    return Lang.values;
  }

  /// The path of this page in [lang] (it must be one of [alternates]).
  String pathIn(Lang target, SiteContent content) {
    if (target == lang) return path;
    return switch (key) {
      PageKey.post => routePath(
        key,
        target,
        content.translationOf(content.postBySlug(lang, slug!)!)!.slug,
      ),
      _ => routePath(key, target, slug),
    };
  }

  /// The `x-default` language: German where the page exists in it.
  Lang xDefault(SiteContent content) => alternates(content).first;

  /// Where the language switch to [target] leads: the same page, else (a post
  /// without a translation) the index of the posts in that language, and from
  /// the 404 page the home page of that language.
  String switchPath(Lang target, SiteContent content) {
    if (key == PageKey.notFound) return pathFor(PageKey.home, target);
    if (alternates(content).contains(target)) return pathIn(target, content);
    return pathFor(PageKey.blog, target);
  }

  @override
  String toString() => 'Route($key, ${lang.code}, $slug)';
}

/// Every page that is built for [content]: the fixed pages, the index and the
/// pages of the works if there is a work, the index and the pages of the posts
/// if there is a post. German pages first within a key.
List<Route> routesFor(SiteContent content) => [
  for (final key in PageKey.values)
    for (final lang in Lang.values)
      ...switch (key) {
        PageKey.work => [
          for (final w in content.works) Route(key, lang, w.slug),
        ],
        PageKey.post => [
          for (final p in content.posts)
            if (p.lang == lang) Route(key, lang, p.slug),
        ],
        PageKey.works => [if (content.hasWorks) Route(key, lang)],
        PageKey.blog => [if (content.hasPosts) Route(key, lang)],
        _ => [Route(key, lang)],
      },
];

/// The target of the language link to [target] on [key]: the same page, except
/// on the 404 page, whose switch leads to the home page in that language (the
/// two 404 pages are no equivalents of each other).
String switchPath(PageKey key, Lang target) =>
    pathFor(key == PageKey.notFound ? PageKey.home : key, target);

/// Where the language switch on [key] in [from] leads: the same page in the
/// other language, never the other home page.
String switchTarget(PageKey key, Lang from) => pathFor(key, from.other);

/// Resolves a request path (with or without trailing slash) to its page, or
/// `null` for an unknown path. The pages of works and posts resolve only when
/// [content] has them.
Route? resolve(String requestPath, {SiteContent? content}) {
  final normalised = _normalise(requestPath);
  for (final route in routesFor(content ?? SiteContent())) {
    if (_normalise(route.path) == normalised) return route;
  }
  return null;
}

String _normalise(String path) {
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}
