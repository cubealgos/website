// SPDX-License-Identifier: Apache-2.0

import 'package:test/test.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

void main() {
  test('every page has a path and metadata in both languages', () {
    for (final key in PageKey.values) {
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
        '/de/',
        '/about/',
        '/de/ueber-mich/',
        '/contact/',
        '/de/kontakt/',
        '/impressum/',
        '/de/impressum/',
        '/datenschutz/',
        '/de/datenschutz/',
        '/404.html',
        '/de/404.html',
      ]..sort()),
    );
  });

  test('the language switch leads to the equivalent page, both ways', () {
    for (final key in PageKey.values.where((k) => k != PageKey.notFound)) {
      for (final lang in Lang.values) {
        final target = switchTarget(key, lang);
        final resolved = resolve(target);
        expect(resolved, isNotNull);
        expect(resolved!.key, key, reason: 'switch from $key/$lang');
        expect(resolved.lang, lang.other);
      }
    }
    expect(switchTarget(PageKey.about, Lang.en), '/de/ueber-mich/');
    expect(switchTarget(PageKey.contact, Lang.de), '/contact/');
    expect(switchTarget(PageKey.home, Lang.en), '/de/');
  });

  test('the 404 pages switch to the home page, not to each other', () {
    expect(switchPath(PageKey.notFound, Lang.en), '/');
    expect(switchPath(PageKey.notFound, Lang.de), '/de/');
    expect(switchPath(PageKey.about, Lang.de), '/de/ueber-mich/');
  });

  test('resolve accepts paths with or without trailing slash', () {
    expect(resolve('/about')?.key, PageKey.about);
    expect(resolve('/de/ueber-mich/')?.lang, Lang.de);
    expect(resolve('/nope'), isNull);
  });

  test('titles are unique per language', () {
    for (final lang in Lang.values) {
      final titles = [
        for (final k in PageKey.values) pageMeta[k]![lang]!.title,
      ];
      expect(titles.toSet().length, titles.length);
    }
  });
}
