// SPDX-License-Identifier: Apache-2.0

// The one switch of brand decision 58, `namesProduct`: with it off, no page
// that can name wearenotabank does, and nothing links its organisation. Both
// states are rendered here (no build is needed), so the site can be flipped
// by changing the constant alone.
import 'dart:convert';

import 'package:test/test.dart';
import 'package:website/src/copy/contact_copy.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/page.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/pages/contact_page.dart';
import 'package:website/src/pages/home_page.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';

import 'support/fixtures.dart';
import 'support/render.dart';

final _brand = RegExp('notabank', caseSensitive: false);

/// The whole page of [key] in [lang], with the product named or not.
Future<String> _shell(PageKey key, Lang lang, {required bool named}) =>
    renderHtml(
      PageShell(
        route: Route(key, lang),
        content: fixtureContent(),
        productNamed: named,
      ),
    );

void main() {
  test('the site ships the named state, and the constants agree', () {
    expect(namesProduct, isTrue);
    expect(outboundUrls, contains(wearenotabankOrgUrl));
    expect(wearenotabankOrgUrl, 'https://github.com/wearenotabank');
  });

  for (final lang in Lang.values) {
    group('named, ${lang.code}', () {
      late String html;
      setUp(() async => html = await _shell(PageKey.home, lang, named: true));

      test('the H1, the button and the Produkt row name the product', () {
        final c = homeCopy[lang]!;
        expect(html, contains(headlineText(c.h1).split('wearenotabank').first));
        expect(html, contains('<span class="mark">wearenotabank</span>'));
        expect(html, contains('href="$wearenotabankOrgUrl"'));
        expect('class="btn"'.allMatches(html), hasLength(1));
        expect('<dt>'.allMatches(html), hasLength(5));
        expect(html, contains('<dt>${c.productLabel}</dt>'));
      });

      test('the head carries the name with its object', () {
        final meta = pageMeta[PageKey.home]![lang]!;
        expect(meta.description, contains('wearenotabank'));
        expect(
          meta.description,
          matches(RegExp('Smart Contracts|smart contracts')),
        );
        expect(html, contains('content="${meta.description}"'));
      });
    });

    group('unnamed, ${lang.code}', () {
      test(
        'Home: the fallback H1, the button to Contact, no Produkt row',
        () async {
          final c = homeCopy[lang]!;
          final home = await renderHtml(
            HomePage(
              lang: lang,
              content: fixtureContent(),
              productNamed: false,
            ),
          );
          expect(
            home,
            contains(
              '${c.h1Unnamed.pre}<span class="mark">${c.h1Unnamed.mark}</span>'
              '${c.h1Unnamed.post}',
            ),
          );
          expect(
            home,
            contains(
              '<span class="btn-wrap"><a class="btn" '
              'href="${pathFor(PageKey.contact, lang)}">${c.contactLink}</a>'
              '</span>',
            ),
          );
          expect('class="btn"'.allMatches(home), hasLength(1));
          expect(home, isNot(contains('class="text-link"')));
          expect(home, isNot(contains('<dt>${c.productLabel}</dt>')));
          expect('<dt>'.allMatches(home), hasLength(4));
          expect(home, isNot(contains('class="ext"')));
          expect(home, isNot(matches(_brand)));
          expect(home, isNot(contains(wearenotabankOrgUrl)));
          // The paragraph does not name it and stays as it is.
          expect(home, contains(c.lede));
        },
      );

      test(
        'Home and Contact, whole pages: neither the name nor the link',
        () async {
          for (final key in [PageKey.home, PageKey.contact]) {
            final html = await _shell(key, lang, named: false);
            expect(html, isNot(matches(_brand)), reason: '${key.name} text');
            expect(html, isNot(contains(wearenotabankOrgUrl)));
            expect(html, isNot(contains('"@type":"Brand"')));
          }
        },
      );

      test('the head says what the studio builds, with no name', () {
        final meta = fixedMeta(PageKey.home, lang, named: false);
        expect(meta.h1, headlineText(homeCopy[lang]!.h1Unnamed));
        expect(meta.description, isNot(matches(_brand)));
        expect(
          meta.description,
          matches(RegExp('Smart Contracts|smart contracts')),
        );
        final contact = fixedMeta(PageKey.contact, lang, named: false);
        expect(contact.description, isNot(matches(_brand)));
        expect(contact.h1, contactCopy[lang]!.h1);
        // The pages that never name it are the same in both states.
        for (final key in [PageKey.blog, PageKey.impressum, PageKey.notFound]) {
          expect(
            fixedMeta(key, lang, named: false),
            fixedMeta(key, lang),
            reason: key.name,
          );
        }
      });

      test('Contact: the topics are the live wording, no name', () async {
        final topics = contactTopics(lang, named: false);
        expect(topics, hasLength(4));
        expect(
          topics.map((t) => t.lead),
          contactTopics(lang).map((t) => t.lead),
        );
        final html = await renderHtml(
          ContactPage(lang: lang, productNamed: false),
        );
        for (final t in topics) {
          expect(html, contains(t.lead));
        }
        expect(html, isNot(matches(_brand)));
        // And named, they are the other list.
        final named = await renderHtml(ContactPage(lang: lang));
        expect(named, contains('wearenotabank'));
      });

      test('the structured data has no brand', () {
        expect(
          jsonEncode(organizationJsonLd(productNamed: false)),
          isNot(matches(_brand)),
        );
      });
    });
  }

  test('both states of the contact topics differ only where they name it', () {
    for (final lang in Lang.values) {
      final named = contactTopics(lang);
      final unnamed = contactTopics(lang, named: false);
      final changed = [
        for (var i = 0; i < named.length; i++)
          if (named[i].text != unnamed[i].text) named[i].lead,
      ];
      for (final i in [for (var i = 0; i < named.length; i++) i]) {
        expect(
          named[i].text.contains('wearenotabank'),
          named[i].text != unnamed[i].text,
          reason: '${lang.code} ${named[i].lead}',
        );
        expect(unnamed[i].text, isNot(matches(_brand)));
      }
      expect(changed, isNotEmpty);
    }
  });
}
