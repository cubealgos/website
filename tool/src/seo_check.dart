// SPDX-License-Identifier: Apache-2.0

/// Offline checks of the search and sharing data of a built site, derived from
/// the route table: Open Graph and Twitter tags, the share images, the
/// sitemap's alternates, `robots.txt` and the `Organization` JSON-LD.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:website/src/outbound.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';

import 'html_check.dart' show Finding;
import 'og_images.dart' show pngSize;

final _metaTag = RegExp(r'<meta\b([^>]*)>');
final _attr = RegExp(r'([a-zA-Z_:][-a-zA-Z0-9_:.]*)\s*=\s*"([^"]*)"');
final _ldJson = RegExp(
  r'<script[^>]*type="application/ld\+json"[^>]*>(.*?)</script>',
  dotAll: true,
);
final _canonical = RegExp('<link[^>]*rel="canonical"[^>]*>');

Map<String, String> _attrs(String s) => {
  for (final a in _attr.allMatches(s)) a[1]!.toLowerCase(): a[2]!,
};

String _unescape(String s) => s
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'");

/// The required fields of an `Organization` for rich results, as problems.
List<String> organizationProblems(Object? data) {
  if (data is! Map) return ['not a JSON object'];
  final out = <String>[];
  if (data['@context'] != 'https://schema.org') out.add('wrong @context');
  if (data['@type'] != 'Organization') out.add('@type is not Organization');
  for (final key in ['name', 'url', 'logo', 'email']) {
    final v = data[key];
    if (v is! String || v.isEmpty) out.add('missing $key');
  }
  for (final key in ['url', 'logo']) {
    final v = data[key];
    if (v is String && Uri.tryParse(v)?.host != Uri.parse(siteOrigin).host) {
      out.add('$key is not on $siteOrigin');
    }
  }
  final sameAs = data['sameAs'];
  if (sameAs is List) {
    for (final v in sameAs) {
      if (v is! String || !outboundUrls.contains(v)) {
        out.add('sameAs $v is not on the outbound allow-list');
      }
    }
  }
  return out;
}

/// Runs every SEO and sharing check over the built site in [buildDir].
List<Finding> checkSeo(Directory buildDir) {
  final root = buildDir.path;
  final out = <Finding>[];
  for (final entry in paths.entries) {
    if (entry.key == PageKey.notFound) continue;
    for (final lang in Lang.values) {
      final path = pathFor(entry.key, lang);
      final file = File(
        p.join(
          root,
          '${path.substring(1)}${path.endsWith('/') ? 'index.html' : ''}',
        ),
      );
      if (!file.existsSync()) continue; // html_check reports missing pages
      _checkPage(file.readAsStringSync(), entry.key, lang, root, path, out);
    }
  }
  _checkSitemap(root, out);
  _checkRobots(root, out);
  return out;
}

void _checkPage(
  String html,
  PageKey key,
  Lang lang,
  String root,
  String page,
  List<Finding> out,
) {
  void add(String rule, String msg) => out.add(Finding(rule, page, msg));
  final meta = pageMeta[key]![lang]!;
  final tags = <String, String>{};
  for (final m in _metaTag.allMatches(html)) {
    final a = _attrs(m[1]!);
    final name = a['property'] ?? a['name'];
    if (name != null && a['content'] != null) {
      tags[name] = _unescape(a['content']!);
    }
  }
  final canonical = urlFor(key, lang);
  final expected = <String, String>{
    'og:type': 'website',
    'og:title': meta.title,
    'og:description': meta.description,
    'og:url': canonical,
    'og:locale': ogLocale(lang),
    'og:locale:alternate': ogLocale(lang.other),
    'og:image': shareImageUrl(lang),
    'og:image:width': '$shareImageWidth',
    'og:image:height': '$shareImageHeight',
    'twitter:card': 'summary_large_image',
    'twitter:title': meta.title,
    'twitter:description': meta.description,
    'twitter:image': shareImageUrl(lang),
  };
  for (final e in expected.entries) {
    if (tags[e.key] != e.value) {
      add('share', '${e.key} is "${tags[e.key]}", expected "${e.value}"');
    }
  }
  for (final k in ['og:image:alt', 'twitter:image:alt']) {
    if ((tags[k] ?? '').isEmpty) add('share', 'missing $k');
  }
  if (!_canonical.hasMatch(html) ||
      !html.contains('href="$canonical" rel="canonical"')) {
    add('canonical', 'canonical is not $canonical');
  }
  final image = File(p.join(root, shareImagePath(lang).substring(1)));
  if (!image.existsSync()) {
    add('share', '${shareImagePath(lang)} is not in the build');
  } else {
    final size = pngSize(image.readAsBytesSync());
    if (size?.width != shareImageWidth || size?.height != shareImageHeight) {
      add(
        'share',
        '${shareImagePath(lang)} is not a ${shareImageWidth}x'
            '$shareImageHeight PNG',
      );
    }
  }
  final lds = [
    for (final m in _ldJson.allMatches(html))
      jsonDecode(m[1]!) as Map<String, dynamic>,
  ];
  final orgs = [
    for (final d in lds)
      if (d['@type'] == 'Organization') d,
  ];
  if (key == PageKey.home) {
    if (orgs.length != 1) {
      add('json-ld', 'expected one Organization block, found ${orgs.length}');
    }
    for (final problem in organizationProblems(orgs.firstOrNull)) {
      add('json-ld', 'Organization: $problem');
    }
    if (!lds.any((d) => d['@type'] == 'FAQPage')) {
      add('json-ld', 'FAQPage block is missing');
    }
  } else if (orgs.isNotEmpty) {
    add('json-ld', 'Organization belongs on the home pages only');
  }
}

void _checkSitemap(String root, List<Finding> out) {
  void add(String msg) => out.add(Finding('sitemap', 'sitemap.xml', msg));
  final file = File(p.join(root, 'sitemap.xml'));
  if (!file.existsSync()) return; // html_check reports it
  final xml = file.readAsStringSync();
  if (xml.contains('404')) add('lists a 404 page');
  final blocks = RegExp('<url>(.*?)</url>', dotAll: true).allMatches(xml);
  final indexable = paths.keys.where((k) => k != PageKey.notFound).length;
  if (blocks.length != indexable * Lang.values.length) {
    add(
      'has ${blocks.length} URLs, expected ${indexable * Lang.values.length}',
    );
  }
  for (final b in blocks) {
    final loc = RegExp('<loc>(.*?)</loc>').firstMatch(b[1]!)?[1];
    final alts = {
      for (final m in RegExp(r'<xhtml:link\b([^>]*)/>').allMatches(b[1]!))
        _attrs(m[1]!)['hreflang']: _attrs(m[1]!)['href'],
    };
    final r = resolve(Uri.parse(loc ?? '').path);
    if (r == null) {
      add('$loc is no page of the route table');
      continue;
    }
    final want = {
      'de': urlFor(r.key, Lang.de),
      'en': urlFor(r.key, Lang.en),
      'x-default': urlFor(r.key, Lang.de),
    };
    for (final e in want.entries) {
      if (alts[e.key] != e.value) {
        add('$loc: alternate ${e.key} is ${alts[e.key]}, expected ${e.value}');
      }
    }
  }
}

void _checkRobots(String root, List<Finding> out) {
  final file = File(p.join(root, 'robots.txt'));
  if (!file.existsSync()) {
    out.add(const Finding('robots', 'robots.txt', 'missing robots.txt'));
    return;
  }
  final text = file.readAsStringSync();
  if (!text.contains('Sitemap: $siteOrigin/sitemap.xml')) {
    out.add(
      const Finding('robots', 'robots.txt', 'does not point at the sitemap'),
    );
  }
  if (RegExp(r'^\s*Disallow:\s*/\s*$', multiLine: true).hasMatch(text)) {
    out.add(const Finding('robots', 'robots.txt', 'disallows the whole site'));
  }
}
