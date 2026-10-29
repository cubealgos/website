// SPDX-License-Identifier: Apache-2.0

import 'package:test/test.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

import 'support/fixtures.dart';

/// The pages that have a path of their own (not one per post).
final List<PageKey> _fixed = [
  for (final k in PageKey.values)
    if (k != PageKey.post) k,
];

void main() {
  test('every fixed page has a path and metadata in both languages', () {
    for (final key in _fixed) {
      for (final lang in Lang.values) {
        expect(paths[key]?[lang], isNotNull, reason: '$key/$lang path');
        expect(pageMeta[key]?[lang], isNotNull, reason: '$key/$lang meta');
      }
    }
  });

  test('the table holds exactly the specified paths', () {
    expect(
      [for (final m in paths.values) ...m.values]..sort(),
      ([
        '/',
        '/en/',
        '/kontakt/',
        '/en/contact/',
        '/blog/',
        '/en/blog/',
        '/impressum/',
        '/en/impressum/',
        '/datenschutz/',
        '/en/datenschutz/',
        '/404.html',
        '/en/404.html',
      ]..sort()),
    );
  });

  test('a post lives under the path of the index', () {
    expect(routePath(PageKey.post, Lang.de, 'a-post'), '/blog/a-post/');
    expect(routePath(PageKey.post, Lang.en, 'a-post'), '/en/blog/a-post/');
  });

  test('with no content only the fixed pages without an index exist', () {
    final keys = {for (final r in routesFor(SiteContent())) r.key};
    expect(keys, {
      PageKey.home,
      PageKey.contact,
      PageKey.impressum,
      PageKey.datenschutz,
      PageKey.notFound,
    });
  });

  test('every page of the fixture content resolves back to itself', () {
    final content = fixtureContent();
    final routes = routesFor(content);
    expect(routes, isNotEmpty);
    for (final r in routes) {
      final back = resolve(r.path, content: content);
      expect(back?.path, r.path);
      expect(back?.key, r.key);
      expect(back?.slug, r.slug);
    }
    // 10 fixed + 2 blog indexes + 3 posts.
    expect(routes, hasLength(10 + 2 + 3));
  });

  test('the language switch leads to the equivalent page, both ways', () {
    final content = fixtureContent();
    for (final r in routesFor(content)) {
      if (r.key == PageKey.notFound) continue;
      if (!r.alternates(content).contains(r.lang.other)) continue;
      final target = r.switchPath(r.lang.other, content);
      final resolved = resolve(target, content: content);
      expect(resolved, isNotNull, reason: '${r.path} -> $target');
      expect(resolved!.key, r.key, reason: 'switch from ${r.path}');
      expect(resolved.lang, r.lang.other);
      // And back again.
      expect(resolved.switchPath(r.lang, content), r.path);
    }
    expect(switchTarget(PageKey.contact, Lang.de), '/en/contact/');
    expect(switchTarget(PageKey.home, Lang.en), '/');
  });

  test(
    'a post with no translation switches to the index of the other language',
    () {
      final content = fixtureContent();
      const solo = Route(PageKey.post, Lang.en, 'only-english');
      expect(solo.switchPath(Lang.de, content), '/blog/');
    },
  );

  test('the 404 pages switch to the home page, not to each other', () {
    expect(switchPath(PageKey.notFound, Lang.en), '/en/');
    expect(switchPath(PageKey.notFound, Lang.de), '/');
    expect(
      const Route(PageKey.notFound, Lang.de).switchPath(Lang.en, SiteContent()),
      '/en/',
    );
  });

  test('resolve accepts paths with or without trailing slash', () {
    expect(resolve('/en/contact')?.key, PageKey.contact);
    expect(resolve('/kontakt/')?.lang, Lang.de);
    expect(resolve('/nope'), isNull);
  });

  test('About and Works are no routes any more', () {
    final content = fixtureContent();
    for (final gone in [
      '/ueber/',
      '/en/about/',
      '/arbeiten/',
      '/en/work/',
      '/arbeiten/an-old-work/',
    ]) {
      expect(resolve(gone, content: content), isNull, reason: gone);
    }
  });

  test('titles are unique per language', () {
    final content = fixtureContent();
    for (final lang in Lang.values) {
      final titles = [
        for (final r in routesFor(content))
          if (r.lang == lang) metaFor(r, content).title,
      ];
      expect(titles.toSet().length, titles.length, reason: lang.code);
    }
  });

  test('a post takes its metadata from its data file', () {
    final content = fixtureContent();
    final post = metaFor(
      const Route(PageKey.post, Lang.en, 'fixture-post'),
      content,
    );
    expect(post.title, 'A fixture post | Cube Algos');
    expect(post.description, 'A post that exists only to test the template.');
  });
}
