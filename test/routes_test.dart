// SPDX-License-Identifier: Apache-2.0

import 'package:test/test.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

import 'support/fixtures.dart';

/// The pages that have a path of their own (not one per work or post).
final List<PageKey> _fixed = [
  for (final k in PageKey.values)
    if (k != PageKey.work && k != PageKey.post) k,
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
        '/ueber/',
        '/en/about/',
        '/kontakt/',
        '/en/contact/',
        '/arbeiten/',
        '/en/work/',
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

  test('a work and a post live under the path of their index', () {
    expect(routePath(PageKey.work, Lang.de, 'a-work'), '/arbeiten/a-work/');
    expect(routePath(PageKey.work, Lang.en, 'a-work'), '/en/work/a-work/');
    expect(routePath(PageKey.post, Lang.de, 'a-post'), '/blog/a-post/');
    expect(routePath(PageKey.post, Lang.en, 'a-post'), '/en/blog/a-post/');
  });

  test('with no content only the fixed pages without an index exist', () {
    final keys = {for (final r in routesFor(SiteContent())) r.key};
    expect(keys, {
      PageKey.home,
      PageKey.about,
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
    // 12 fixed + 2 work indexes + 8 works + 2 blog indexes + 3 posts.
    expect(routes, hasLength(12 + 2 + 8 + 2 + 3));
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
    expect(switchTarget(PageKey.about, Lang.en), '/ueber/');
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
    expect(switchPath(PageKey.about, Lang.de), '/ueber/');
    expect(
      const Route(PageKey.notFound, Lang.de).switchPath(Lang.en, SiteContent()),
      '/en/',
    );
  });

  test('resolve accepts paths with or without trailing slash', () {
    final content = fixtureContent();
    expect(resolve('/en/about')?.key, PageKey.about);
    expect(resolve('/ueber/')?.lang, Lang.de);
    expect(resolve('/nope'), isNull);
    expect(resolve('/arbeiten', content: content)?.key, PageKey.works);
    expect(
      resolve('/arbeiten'),
      isNull,
      reason: 'no works in the empty content',
    );
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

  test('a work and a post take their metadata from their data file', () {
    final content = fixtureContent();
    final work = metaFor(
      const Route(PageKey.work, Lang.en, 'fixture-price-oracle-contracts'),
      content,
    );
    expect(work.title, 'fixture-price-oracle-contracts | Cube Algos');
    expect(work.h1, 'fixture-price-oracle-contracts');
    expect(work.description, isNot(contains('`')));
    expect(work.description, contains('AggregatorV3Interface'));
    final post = metaFor(
      const Route(PageKey.post, Lang.en, 'fixture-post'),
      content,
    );
    expect(post.title, 'A fixture post | Cube Algos');
    expect(post.description, 'A post that exists only to test the template.');
  });
}
