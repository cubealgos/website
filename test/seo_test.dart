// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';

import '../tool/src/og_images.dart';
import '../tool/src/seo_check.dart';
import 'support/fixtures.dart';

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
    // wearenotabank is a product of the studio, not the same entity: a brand,
    // with its object (regulatory edit E-C-4), and never in sameAs.
    expect(org['brand'], {
      '@type': 'Brand',
      'name': 'wearenotabank',
      'url': 'https://github.com/wearenotabank',
      'description': 'Developer tools for EVM chains',
    });
    expect(
      File('web/brand/logo/mark.svg').existsSync(),
      isTrue,
      reason: 'the logo URL points at a vendored file',
    );
  });

  test('without the product named, the Organization has no brand', () {
    final org = organizationJsonLd(productNamed: false);
    expect(org, isNot(contains('brand')));
    expect(jsonEncode(org), isNot(contains('notabank')));
    expect(jsonEncode(org), isNot(contains(wearenotabankOrgUrl)));
  });

  test('a brand that is not wearenotabank with its object is rejected', () {
    final bad = {
      ...organizationJsonLd(),
      'brand': {
        '@type': 'Brand',
        'name': 'Wearenotabank',
        'url': wearenotabankOrgUrl,
      },
    };
    expect(organizationProblems(bad), [
      'brand is not the wearenotabank Brand with its description',
    ]);
    final missing = {...organizationJsonLd()}..remove('brand');
    expect(organizationProblems(missing), ['missing brand']);
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

  test('the sitemap lists the shipped pages with alternates and no 404', () {
    final xml = sitemapXml(shippedContent);
    // Home, Contact, the blog index, Impressum and Datenschutz in two
    // languages, and the first post in each.
    expect('<url>'.allMatches(xml).length, 12);
    expect(xml, isNot(contains('404')));
    // About folded into Home and Works is gone: their old URLs are redirect
    // pages, no destinations.
    for (final retired in [
      '/ueber/',
      '/en/about/',
      '/arbeiten/',
      '/en/work/',
    ]) {
      expect(xml, isNot(contains(retired)), reason: retired);
    }
    expect(
      xml,
      contains(
        '<xhtml:link rel="alternate" hreflang="x-default" '
        'href="https://cubealgos.de/"/>',
      ),
    );
    for (final key in [
      PageKey.home,
      PageKey.contact,
      PageKey.blog,
      PageKey.impressum,
      PageKey.datenschutz,
    ]) {
      for (final lang in Lang.values) {
        expect(xml, contains('<loc>${urlFor(key, lang)}</loc>'));
      }
    }
  });

  test('the sitemap of a site with several posts lists them all', () {
    final content = fixtureContent();
    final xml = sitemapXml(content);
    // 4 fixed pages x 2, 2 blog indexes, 3 posts.
    expect('<url>'.allMatches(xml).length, 8 + 2 + 3);
    for (final r in routesFor(content)) {
      if (r.key == PageKey.notFound) continue;
      expect(xml, contains('<loc>${r.url}</loc>'));
    }
  });

  test('the share image carries the eyebrow and the H1 of the home page', () {
    for (final lang in Lang.values) {
      final html = imageHtml(lang);
      expect(html, contains(homeCopy[lang]!.eyebrow));
      expect(html, contains(fixedMeta(PageKey.home, lang).h1));
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
