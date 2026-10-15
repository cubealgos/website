// SPDX-License-Identifier: Apache-2.0

/// Search and sharing data derived from the route table: the sitemap, the
/// share images' paths and the `Organization` structured data. Nothing here
/// spells a URL of its own.
library;

import 'package:website/src/content/site_content.dart';
import 'package:website/src/legal_facts.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// Width of a share image in pixels.
const shareImageWidth = 1200;

/// Height of a share image in pixels.
const shareImageHeight = 630;

/// The path of the share image of [lang] (one per language, built by
/// `tool/og_images.dart`).
String shareImagePath(Lang lang) => '/og/og-${lang.code}.png';

/// The absolute URL of the share image of [lang].
String shareImageUrl(Lang lang) => '$siteOrigin${shareImagePath(lang)}';

/// The `og:locale` value of [lang].
String ogLocale(Lang lang) => switch (lang) {
  Lang.de => 'de_DE',
  Lang.en => 'en_US',
};

/// The URL of the vendored mark, used as the organisation's logo.
const logoUrl = '$siteOrigin/brand/logo/mark.svg';

/// The `Organization` JSON-LD of the home pages.
Map<String, Object> organizationJsonLd() => {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  'name': companyName,
  'alternateName': 'Cube Algos',
  'url': '$siteOrigin/',
  'logo': logoUrl,
  'email': email,
  'address': {
    '@type': 'PostalAddress',
    'addressLocality': 'Heinsberg',
    'addressCountry': 'DE',
  },
  // The studio's own profiles, from the outbound allow-list.
  'sameAs': [linkedinCompanyUrl],
};

/// `sitemap.xml`: every indexable page, each with its `xhtml:link`
/// alternates (the languages the page exists in, and `x-default` = German
/// where it exists). The 404 pages stay out. The pages of the works and the
/// posts are listed only for content that exists.
String sitemapXml(SiteContent content) {
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" '
      'xmlns:xhtml="http://www.w3.org/1999/xhtml">',
    );
  for (final route in routesFor(content)) {
    if (route.key == PageKey.notFound) continue;
    buffer
      ..writeln('  <url>')
      ..writeln('    <loc>${route.url}</loc>');
    for (final alt in route.alternates(content)) {
      buffer.writeln(
        '    <xhtml:link rel="alternate" hreflang="${alt.code}" '
        'href="$siteOrigin${route.pathIn(alt, content)}"/>',
      );
    }
    buffer
      ..writeln(
        '    <xhtml:link rel="alternate" hreflang="x-default" '
        'href="$siteOrigin${route.pathIn(route.xDefault(content), content)}"/>',
      )
      ..writeln('  </url>');
  }
  buffer.writeln('</urlset>');
  return buffer.toString();
}
