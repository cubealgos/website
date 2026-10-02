// SPDX-License-Identifier: Apache-2.0

/// Offline checks over a built site (no network): head metadata, internal
/// links, fragments, foreign hosts (also in CSS) and the sitemap.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:website/src/outbound.dart';

import 'css_rules.dart';

/// The only host the built pages may point at, apart from the few links of
/// `outboundUrls` (Kevin's site, GitHub, LinkedIn), which may be the `href` of
/// an `<a>` and nothing else: no script, stylesheet, image, form action or
/// `url()` (a link is not a request).
const siteHost = 'cubealgos.de';

/// One rule violation.
class Finding {
  /// Creates a finding of [rule] on [page].
  const new(this.rule, this.page, this.message);

  /// The rule id, e.g. `broken-link`.
  final String rule;

  /// The page path (relative to the build dir) it was found on.
  final String page;

  /// What is wrong.
  final String message;

  @override
  String toString() => '[$rule] $page: $message';
}

final _comment = RegExp('<!--.*?-->', dotAll: true);
final _tag = RegExp(r'<([a-zA-Z][a-zA-Z0-9]*)\b([^>]*)>');
final _attr = RegExp(
  r'''([a-zA-Z_:][-a-zA-Z0-9_:.]*)\s*=\s*(?:"([^"]*)"|'([^']*)')''',
);
final _title = RegExp('<title>(.*?)</title>', dotAll: true);

class _Tag {
  new(this.name, this.attrs);
  final String name;
  final Map<String, String> attrs;
}

class _Page {
  new(this.path, String html) {
    final stripped = html.replaceAll(_comment, '');
    title = _title.firstMatch(stripped)?[1]?.trim() ?? '';
    for (final m in _tag.allMatches(stripped)) {
      tags.add(
        _Tag(m[1]!.toLowerCase(), {
          for (final a in _attr.allMatches(m[2]!))
            a[1]!.toLowerCase(): a[2] ?? a[3] ?? '',
        }),
      );
    }
  }

  final String path;
  final tags = <_Tag>[];
  late final String title;

  Iterable<_Tag> named(String name) => tags.where((t) => t.name == name);
  Set<String> get ids => {
    for (final t in tags) ...[
      ?t.attrs['id'],
      if (t.name == 'a') ?t.attrs['name'],
    ],
  };
}

/// Runs every rule over the built site in [buildDir].
List<Finding> checkSite(Directory buildDir) {
  final root = buildDir.path;
  final pages = <String, _Page>{};
  for (final f in buildDir.listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.html')) {
      final rel = p.relative(f.path, from: root);
      pages[rel] = _Page(rel, f.readAsStringSync());
    }
  }
  final findings = <Finding>[];
  for (final page in pages.values) {
    _checkHead(page, findings);
    _checkIcons(page, root, findings);
    _checkLinks(page, root, pages, findings);
  }
  _checkSitemap(root, pages, findings);
  _checkManifest(root, findings);
  _checkThirdParty(buildDir, findings);
  _checkSiteStyles(buildDir, findings);
  _checkNoInlineStyle(buildDir, findings);
  _checkNoStorage(buildDir, findings);
  return findings;
}

/// Whether [path] (relative to the build dir) is a 404 page.
bool _is404(String path) => p.basename(path) == '404.html';

void _checkHead(_Page page, List<Finding> out) {
  void add(String rule, String msg) => out.add(Finding(rule, page.path, msg));
  if (page.title.isEmpty) add('title', 'missing or empty <title>');
  final desc = page
      .named('meta')
      .where((t) => t.attrs['name']?.toLowerCase() == 'description');
  if (desc.isEmpty ||
      desc.every((t) => (t.attrs['content'] ?? '').trim().isEmpty)) {
    add('description', 'missing or empty meta description');
  }
  final lang = page.named('html').firstOrNull?.attrs['lang'] ?? '';
  if (lang.trim().isEmpty) add('lang', 'missing or empty <html lang>');
  final links = page.named('link').toList();
  if (_is404(page.path)) {
    // Explicit exemptions, not a skip: a 404 page is noindex and has neither a
    // canonical nor hreflang alternates (it is no equivalent of its sibling).
    final robots = page
        .named('meta')
        .where((t) => t.attrs['name']?.toLowerCase() == 'robots');
    if (!robots.any((t) => (t.attrs['content'] ?? '').contains('noindex'))) {
      add('noindex', '404 page lacks <meta name="robots" content="noindex">');
    }
    if (links.any((t) => t.attrs['rel'] == 'canonical')) {
      add('canonical', '404 page must not carry a canonical link');
    }
    if (links.any((t) => t.attrs['rel'] == 'alternate')) {
      add('hreflang', '404 page must not carry alternate links');
    }
    return;
  }
  for (final hreflang in ['en', 'de', 'x-default']) {
    final ok = links.any(
      (t) =>
          t.attrs['rel'] == 'alternate' &&
          t.attrs['hreflang'] == hreflang &&
          (t.attrs['href'] ?? '').isNotEmpty,
    );
    if (!ok) add('hreflang', 'missing alternate hreflang="$hreflang"');
  }
  final canonical = links.any(
    (t) => t.attrs['rel'] == 'canonical' && (t.attrs['href'] ?? '').isNotEmpty,
  );
  if (!canonical) add('canonical', 'missing or empty canonical link');
}

bool _exists(String root, String urlPath) {
  if (!urlPath.startsWith('/')) return false;
  return File(p.join(root, urlPath.substring(1))).existsSync();
}

/// Every page links the SVG icon, the `.ico` fallback, the apple-touch icon
/// and the manifest, and each linked file is in the build.
void _checkIcons(_Page page, String root, List<Finding> out) {
  void add(String msg) => out.add(Finding('icons', page.path, msg));
  final links = page.named('link').toList();
  Iterable<_Tag> rel(String r) => links.where(
    (t) => (t.attrs['rel'] ?? '').split(RegExp(r'\s+')).contains(r),
  );
  final wanted = <String, _Tag?>{
    'icon (image/svg+xml)': rel('icon')
        .where((t) => t.attrs['type'] == 'image/svg+xml')
        .firstOrNull,
    'icon (.ico fallback)': rel('icon')
        .where((t) => (t.attrs['href'] ?? '').endsWith('.ico'))
        .firstOrNull,
    'apple-touch-icon': rel('apple-touch-icon').firstOrNull,
    'manifest': rel('manifest').firstOrNull,
  };
  for (final e in wanted.entries) {
    final href = e.value?.attrs['href'] ?? '';
    if (href.isEmpty) {
      add('missing link ${e.key}');
    } else if (!_exists(root, href)) {
      add('link ${e.key} points at $href, not in the build');
    }
  }
}

/// `site.webmanifest` exists, names the site and lists icons that exist.
void _checkManifest(String root, List<Finding> out) {
  void add(String msg) => out.add(Finding('icons', 'site.webmanifest', msg));
  final file = File(p.join(root, 'site.webmanifest'));
  if (!file.existsSync()) {
    add('missing site.webmanifest');
    return;
  }
  try {
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    if ((json['name'] ?? '') == '') add('manifest has no name');
    final icons = (json['icons'] as List?) ?? const [];
    if (icons.isEmpty) add('manifest lists no icons');
    for (final icon in icons) {
      final src = (icon as Map)['src'] as String? ?? '';
      if (!_exists(root, src)) add('manifest icon $src not in the build');
    }
  } on Object catch (e) {
    add('unreadable manifest: $e');
  }
}

Iterable<String> _refs(_Tag tag) sync* {
  for (final name in ['href', 'src', 'poster', 'action']) {
    if (tag.attrs[name] case final v?) yield v;
  }
  if (tag.attrs['srcset'] case final set?) {
    for (final part in set.split(',')) {
      final url = part.trim().split(RegExp(r'\s+')).first;
      if (url.isNotEmpty) yield url;
    }
  }
}

String _pagePath(String rel) => '/${rel.replaceAll(r'\', '/')}';

void _checkLinks(
  _Page page,
  String root,
  Map<String, _Page> pages,
  List<Finding> out,
) {
  void add(String rule, String msg) => out.add(Finding(rule, page.path, msg));
  final pageUri = Uri.parse('https://$siteHost${_pagePath(page.path)}');
  final baseHref = page.named('base').firstOrNull?.attrs['href'];
  final base = baseHref == null ? pageUri : pageUri.resolve(baseHref);

  for (final tag in page.tags) {
    for (final ref in _refs(tag)) {
      final value = ref.trim();
      if (value.isEmpty) continue;
      final uri = Uri.tryParse(value);
      if (uri == null) {
        add('broken-link', 'unparseable URL "$value"');
        continue;
      }
      // Exactly these URLs, as a plain link, character for character.
      if (tag.name == 'a' &&
          tag.attrs['href'] == value &&
          outboundUrls.contains(value)) {
        continue;
      }
      if (uri.hasScheme && (uri.scheme == 'mailto' || uri.scheme == 'tel')) {
        continue;
      }
      // A 404 page is served from any depth: only root-absolute URLs (and
      // in-page fragments) keep working there.
      if (_is404(page.path) &&
          !value.startsWith('/') &&
          !value.startsWith('#') &&
          !uri.hasScheme) {
        add('relative-url', '404 page uses a relative URL "$value"');
        continue;
      }
      if (uri.hasScheme && uri.scheme != 'http' && uri.scheme != 'https') {
        add('foreign-host', 'unsupported scheme in "$value"');
        continue;
      }
      if ((uri.hasScheme || value.startsWith('//')) && uri.host != siteHost) {
        add('foreign-host', '"$value" points at ${uri.host}, not $siteHost');
        continue;
      }
      final target = base.resolve(value);
      final file = _fileFor(root, target.path);
      if (file == null) {
        add('broken-link', '"$value" does not resolve to a built file');
        continue;
      }
      if (target.fragment.isNotEmpty) {
        final rel = p.relative(file.path, from: root);
        final targetPage = pages[rel];
        if (targetPage == null || !targetPage.ids.contains(target.fragment)) {
          add('fragment', '"$value": no #${target.fragment} in $rel');
        }
      }
    }
  }
}

File? _fileFor(String root, String urlPath) {
  final decoded = Uri.decodeComponent(urlPath);
  final rel = decoded.startsWith('/') ? decoded.substring(1) : decoded;
  final direct = File(p.join(root, rel));
  if (!decoded.endsWith('/') && direct.existsSync()) return direct;
  final index = File(p.join(root, rel, 'index.html'));
  if (index.existsSync()) return index;
  return null;
}

void _checkSitemap(String root, Map<String, _Page> pages, List<Finding> out) {
  final sitemap = File(p.join(root, 'sitemap.xml'));
  if (!sitemap.existsSync()) {
    out.add(const Finding('sitemap', 'sitemap.xml', 'missing sitemap.xml'));
    return;
  }
  final listed = {
    for (final m in RegExp(
      '<loc>(.*?)</loc>',
    ).allMatches(sitemap.readAsStringSync()))
      m[1]!.trim(),
  };
  for (final page in pages.values) {
    // 404 pages are deliberately not indexed.
    if (p.basename(page.path) == '404.html') continue;
    final path = _pagePath(page.path).replaceFirst(RegExp(r'index\.html$'), '');
    final url = 'https://$siteHost$path';
    if (!listed.contains(url)) {
      out.add(
        Finding('sitemap', page.path, 'not listed in sitemap.xml ($url)'),
      );
    }
  }
}

final _googleFonts = RegExp(r'fonts\.(googleapis|gstatic)\.com');
final _cssUrl = RegExp(
  r'''(?:url\(\s*|@import\s+)(?:"([^"]*)"|'([^']*)'|([^\s)"']+))''',
);

/// No third-party host in built HTML or CSS (the privacy notice promises
/// self-hosted fonts): Google Fonts hosts anywhere in a page, and any
/// absolute or protocol-relative URL to another host in a stylesheet. Local
/// `url()` references in a stylesheet must resolve to a built file.
void _checkThirdParty(Directory buildDir, List<Finding> out) {
  final root = buildDir.path;
  for (final f in buildDir.listSync(recursive: true)) {
    if (f is! File) continue;
    final rel = p.relative(f.path, from: root);
    if (f.path.endsWith('.html') &&
        _googleFonts.hasMatch(f.readAsStringSync())) {
      out.add(Finding('third-party', rel, 'references Google Fonts'));
    }
    if (!f.path.endsWith('.css')) continue;
    final css = f.readAsStringSync().replaceAll(
      RegExp(r'/\*.*?\*/', dotAll: true),
      '',
    );
    final cssUri = Uri.parse('https://$siteHost/${rel.replaceAll(r'\', '/')}');
    for (final m in _cssUrl.allMatches(css)) {
      final value = (m[1] ?? m[2] ?? m[3] ?? '').trim();
      if (value.isEmpty || value.startsWith('data:')) continue;
      final uri = Uri.tryParse(value);
      if (uri == null) continue;
      if ((uri.hasScheme || value.startsWith('//')) && uri.host != siteHost) {
        out.add(Finding('third-party', rel, '"$value" points at ${uri.host}'));
        continue;
      }
      if (_fileFor(root, cssUri.resolve(value).path) == null) {
        out.add(
          Finding(
            'broken-link',
            rel,
            '"$value" does not resolve to a built file',
          ),
        );
      }
    }
  }
}

/// The site's own CSS (every built stylesheet outside the vendored `brand/`
/// directory; the sting's generated `brand/sting-mark.css` included) takes its
/// colours, durations and easings from the tokens (no hex, colour function,
/// named colour, `ms`/`s` or easing literal) and animates only `transform` and
/// `opacity`.
void _checkSiteStyles(Directory buildDir, List<Finding> out) {
  final root = buildDir.path;
  for (final f in buildDir.listSync(recursive: true)) {
    if (f is! File) continue;
    final rel = p.relative(f.path, from: root).replaceAll(r'\', '/');
    if (rel.startsWith('brand/')) continue;
    if (!f.path.endsWith('.css')) continue;
    final text = f.readAsStringSync();
    for (final hit in hardCodedColours(text)) {
      out.add(Finding('hard-coded-colour', rel, hit));
    }
    for (final hit in literalMotion(text)) {
      out.add(Finding('literal-motion', rel, hit));
    }
    for (final hit in layoutMotion(text)) {
      out.add(Finding('layout-motion', rel, hit));
    }
  }
}

final _scriptBlock = RegExp(
  r'<script\b[^>]*>.*?</script>',
  dotAll: true,
  caseSensitive: false,
);
final _styleElement = RegExp(r'<style\b', caseSensitive: false);
final _styleAttribute = RegExp(
  r'<[a-zA-Z][^>]*?\sstyle\s*=',
  caseSensitive: false,
);

/// No built page carries inline CSS (a `<style>` element or a `style`
/// attribute), so the server can send `style-src 'self'` with no hashes. Inline
/// SVG presentation attributes (`fill=`) and `<script>` contents (JSON-LD) are
/// no inline CSS and pass.
void _checkNoInlineStyle(Directory buildDir, List<Finding> out) {
  final root = buildDir.path;
  for (final f in buildDir.listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.html')) continue;
    final rel = p.relative(f.path, from: root).replaceAll(r'\', '/');
    final html = f.readAsStringSync().replaceAll(_scriptBlock, '');
    if (_styleElement.hasMatch(html)) {
      out.add(Finding('inline-style', rel, 'has a <style> element'));
    }
    if (_styleAttribute.hasMatch(html)) {
      out.add(Finding('inline-style', rel, 'has a style attribute'));
    }
  }
}

final _storageApi = RegExp(
  r'sessionStorage|localStorage|indexedDB|document\.cookie',
);

/// The site stores nothing on the visitor's device (decision 9, § 25 TDDDG):
/// no built page, script or stylesheet (the vendored `brand/` files and
/// fonts aside) references a storage API or `document.cookie`.
void _checkNoStorage(Directory buildDir, List<Finding> out) {
  final root = buildDir.path;
  for (final f in buildDir.listSync(recursive: true)) {
    if (f is! File || !RegExp(r'\.(html|js|css)$').hasMatch(f.path)) continue;
    final rel = p.relative(f.path, from: root).replaceAll(r'\', '/');
    if (rel.startsWith('brand/')) continue;
    for (final m in _storageApi.allMatches(f.readAsStringSync()).take(1)) {
      out.add(Finding('storage', rel, 'references ${m[0]}'));
    }
  }
}
