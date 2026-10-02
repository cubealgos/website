// SPDX-License-Identifier: Apache-2.0

/// The one route table: every page key with its path in both languages.
///
/// The language switch, hreflang alternates, canonical URLs and (later) the
/// sitemap all derive from [paths] and [pathFor]; nothing else spells a URL.
library;

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
/// files.
const Map<PageKey, Map<Lang, String>> paths = {
  PageKey.home: {Lang.de: '/', Lang.en: '/en/'},
  PageKey.about: {Lang.de: '/ueber-cube-algos/', Lang.en: '/en/about/'},
  PageKey.contact: {Lang.de: '/kontakt/', Lang.en: '/en/contact/'},
  PageKey.impressum: {Lang.de: '/impressum/', Lang.en: '/en/impressum/'},
  PageKey.datenschutz: {Lang.de: '/datenschutz/', Lang.en: '/en/datenschutz/'},
  PageKey.notFound: {Lang.de: '/404.html', Lang.en: '/en/404.html'},
};

/// The path of [key] in [lang].
String pathFor(PageKey key, Lang lang) => paths[key]![lang]!;

/// The absolute URL of [key] in [lang] (canonical and hreflang).
String urlFor(PageKey key, Lang lang) => '$siteOrigin${pathFor(key, lang)}';

/// The target of the language link to [target] on [key]: the same page, except
/// on the 404 page, whose switch leads to the home page in that language (the
/// two 404 pages are no equivalents of each other).
String switchPath(PageKey key, Lang target) =>
    pathFor(key == PageKey.notFound ? PageKey.home : key, target);

/// Where the language switch on [key] in [from] leads: the same page in the
/// other language, never the other home page.
String switchTarget(PageKey key, Lang from) => pathFor(key, from.other);

/// Resolves a request path (with or without trailing slash) to its page and
/// language, or `null` for an unknown path.
({PageKey key, Lang lang})? resolve(String requestPath) {
  final normalised = _normalise(requestPath);
  for (final entry in paths.entries) {
    for (final lang in Lang.values) {
      if (_normalise(entry.value[lang]!) == normalised) {
        return (key: entry.key, lang: lang);
      }
    }
  }
  return null;
}

String _normalise(String path) {
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}
