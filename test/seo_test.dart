// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';

import '../tool/src/og_images.dart';
import '../tool/src/seo_check.dart';

void main() {
  test('the Organization JSON-LD has the required fields', () {
    final org = organizationJsonLd();
    expect(organizationProblems(org), isEmpty);
    expect(org['@type'], 'Organization');
    expect(org['name'], 'Cube Algos UG (haftungsbeschränkt)');
    expect(org['url'], 'https://cubealgos.de/');
    expect(org['email'], 'hello@cubealgos.de');
    expect(org['logo'], 'https://cubealgos.de/brand/logo/mark.svg');
    expect(org['sameAs'], ['https://www.linkedin.com/company/cubealgos/']);
    expect(
      File('web/brand/logo/mark.svg').existsSync(),
      isTrue,
      reason: 'the logo URL points at a vendored file',
    );
  });

  test('an Organization without name or on another host is rejected', () {
    final bad = {...organizationJsonLd()}
      ..remove('name')
      ..['logo'] = 'https://example.com/l.svg';
    expect(
      organizationProblems(bad),
      containsAll(['missing name', 'logo is not on https://cubealgos.de']),
    );
  });

  test(
    'an Organization sameAs outside the outbound allow-list is rejected',
    () {
      const other = 'https://www.linkedin.com/in/someone';
      final bad = {
        ...organizationJsonLd(),
        'sameAs': [linkedinCompanyUrl, other],
      };
      expect(organizationProblems(bad), [
        'sameAs $other is not on the outbound allow-list',
      ]);
    },
  );

  test('the sitemap lists 10 URLs with alternates and no 404', () {
    final xml = sitemapXml();
    expect('<url>'.allMatches(xml).length, 10);
    expect(xml, isNot(contains('404')));
    expect(
      xml,
      contains(
        '<xhtml:link rel="alternate" hreflang="x-default" '
        'href="https://cubealgos.de/"/>',
      ),
    );
    for (final key in PageKey.values.where((k) => k != PageKey.notFound)) {
      for (final lang in Lang.values) {
        expect(xml, contains('<loc>${urlFor(key, lang)}</loc>'));
      }
    }
  });

  test('one share image per language, at the shared size', () {
    expect(shareImagePath(Lang.de), '/og/og-de.png');
    expect(shareImagePath(Lang.en), '/og/og-en.png');
    expect(checkImages(), isEmpty);
  });

  test('pngSize reads the header and rejects other bytes', () {
    final bytes = File('web/og/og-en.png').readAsBytesSync();
    expect(pngSize(bytes), (width: 1200, height: 630));
    expect(pngSize([1, 2, 3]), isNull);
  });

  test('the image inputs digest is stable', () {
    expect(inputsDigest(), inputsDigest());
  });
}
