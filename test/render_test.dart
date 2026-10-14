// SPDX-License-Identifier: Apache-2.0

// The works and blog templates, rendered at test time from fixtures (outside
// the shipped data): with no work, with one, two and four, and with posts in
// one or both languages. No build is needed.
import 'package:test/test.dart';
import 'package:website/src/chrome.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/content/work.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/page.dart';
import 'package:website/src/pages/about_page.dart';
import 'package:website/src/pages/blog_pages.dart';
import 'package:website/src/pages/home_page.dart';
import 'package:website/src/pages/work_widgets.dart';
import 'package:website/src/pages/works_pages.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';

import 'support/fixtures.dart';
import 'support/render.dart';

int _count(String html, Pattern what) => what.allMatches(html).length;

/// The hrefs of the `<a>` elements of [html].
List<String> _hrefs(String html) => [
  for (final m in RegExp('<a [^>]*href="([^"]*)"').allMatches(html)) m[1]!,
];

/// The nav labels of the header and the footer.
List<String> _navLabels(String html, String landmark) {
  final nav = RegExp(
    '<nav[^>]*aria-label="$landmark"[^>]*>(.*?)</nav>',
    dotAll: true,
  ).firstMatch(html)![1]!;
  return [for (final m in RegExp('<a [^>]*>(.*?)</a>').allMatches(nav)) m[1]!];
}

Future<String> _chrome(Route route, SiteContent content) async =>
    '${await renderHtml(SiteHeader(route: route, content: content))}'
    '${await renderHtml(SiteFooter(route: route, content: content))}';

void main() {
  group('with no work (as shipped)', () {
    final content = fixtureContent(works: 0);

    for (final lang in Lang.values) {
      test('${lang.code}: no section, no nav item, no index page', () async {
        final c = homeCopy[lang]!;
        final home = await renderHtml(HomePage(lang: lang, content: content));
        expect(home, isNot(contains('id="${c.workAnchor}"')));
        expect(home, isNot(contains('works-title')));
        expect(home, isNot(contains('class="room')));
        expect(home, isNot(contains('href="${pathFor(PageKey.works, lang)}"')));
        final chrome = await _chrome(Route(PageKey.home, lang), content);
        expect(
          chrome,
          isNot(contains('href="${pathFor(PageKey.works, lang)}"')),
        );
        expect(
          _navLabels(chrome, lang == Lang.de ? 'Hauptnavigation' : 'Main'),
          lang == Lang.de
              ? ['Start', 'Blog', 'Über', 'Kontakt']
              : ['Home', 'Blog', 'About', 'Contact'],
        );
      });

      test('${lang.code}: the hero button leads to the studio', () async {
        final c = homeCopy[lang]!;
        final home = await renderHtml(HomePage(lang: lang, content: content));
        expect(
          home,
          contains('<a class="btn" href="#studio">${c.buttonStudio}</a>'),
        );
        expect(
          c.buttonStudio,
          lang == Lang.de ? 'Mehr erfahren' : 'Learn more',
        );
        expect(home, isNot(contains(c.buttonWork)));
      });
    }

    test('the route table has no works page and answers them with the 404', () {
      expect(
        routesFor(content)
            .where((r) => r.key == PageKey.works || r.key == PageKey.work),
        isEmpty,
      );
      expect(resolve('/arbeiten/', content: content), isNull);
      expect(resolve('/en/work/', content: content), isNull);
      expect(sitemapXml(content), isNot(contains('arbeiten')));
      expect(sitemapXml(content), isNot(contains('/work/')));
    });
  });

  for (final n in [1, 2, 4]) {
    group('with $n work${n == 1 ? '' : 's'}', () {
      final content = fixtureContent(works: n);
      final newestFirst = [for (final w in content.works) w.slug];

      for (final lang in Lang.values) {
        test('${lang.code}: hero button, rooms, link to all', () async {
          final c = homeCopy[lang]!;
          final home = await renderHtml(HomePage(lang: lang, content: content));
          expect(
            home,
            contains(
              '<a class="btn" href="#${c.workAnchor}">${c.buttonWork}</a>',
            ),
          );
          expect('id="${c.workAnchor}"'.allMatches(home), hasLength(1));
          // At most two rooms on the home page, the newest first.
          final rooms = RegExp('aria-labelledby="room-([^"]*)"')
              .allMatches(home)
              .map((m) => m[1]!)
              .toList();
          expect(rooms, newestFirst.take(2));
          final all = c.allWorks.replaceAll('{n}', '$n');
          if (n > 2) {
            expect(
              home,
              contains(
                '<a class="text-link" href="${pathFor(PageKey.works, lang)}">$all</a>',
              ),
            );
          } else {
            expect(
              home,
              isNot(contains('href="${pathFor(PageKey.works, lang)}"')),
            );
          }
          // Rooms alternate: the first is odd (card grey), the second even.
          expect(
            RegExp('class="room room--(odd|even)"')
                .allMatches(home)
                .map((m) => m[1]!)
                .toList(),
            ['odd', 'even'].take(n < 2 ? 1 : 2),
          );
        });

        test(
          '${lang.code}: the works index shows every work as a room',
          () async {
            final html = await renderHtml(
              WorksIndexPage(lang: lang, content: content),
            );
            expect(
              RegExp('aria-labelledby="room-([^"]*)"')
                  .allMatches(html)
                  .map((m) => m[1]!)
                  .toList(),
              newestFirst,
            );
            expect('<h1'.allMatches(html), hasLength(1));
            expect(
              _count(html, '<h2 '),
              n,
              reason: 'the rooms are h2 on the index',
            );
          },
        );

        test('${lang.code}: the nav and footer carry the works page', () async {
          final chrome = await _chrome(Route(PageKey.about, lang), content);
          final label = lang == Lang.de ? 'Arbeiten' : 'Work';
          expect(
            _navLabels(chrome, lang == Lang.de ? 'Hauptnavigation' : 'Main'),
            contains(label),
          );
          expect(
            _navLabels(chrome, lang == Lang.de ? 'Fußbereich' : 'Footer'),
            contains(label),
          );
        });
      }

      test('the route table lists the index and every work page', () {
        final routes = routesFor(content);
        expect(routes.where((r) => r.key == PageKey.works), hasLength(2));
        expect(routes.where((r) => r.key == PageKey.work), hasLength(2 * n));
        expect(
          resolve('/en/work/${newestFirst.first}', content: content)?.key,
          PageKey.work,
        );
        final xml = sitemapXml(content);
        for (final slug in newestFirst) {
          expect(xml, contains('<loc>$siteOrigin/arbeiten/$slug/</loc>'));
          expect(xml, contains('<loc>$siteOrigin/en/work/$slug/</loc>'));
        }
      });
    });
  }

  group('a work page', () {
    final content = fixtureContent();
    Work work(String slug) => content.workBySlug(slug)!;
    Future<String> page(String slug, [Lang lang = Lang.de]) =>
        renderHtml(WorkPage(lang: lang, work: work(slug)));

    test(
      "source and other links are the work's own URLs, nothing else",
      () async {
        final w = work('fixture-price-oracle-contracts');
        final html = await page(w.slug);
        expect(
          _hrefs(html).where((h) => h.startsWith('https://')),
          w.links.values.toList(),
        );
        expect(html, contains('href="${w.links[WorkLink.source]}"'));
        expect(html, contains('>Quelltext auf GitHub</a>'));
        expect(html, isNot(contains('github.com')));
        // Every link of the page leaves the site only through the data file.
        expect(_hrefs(html).where((h) => !h.startsWith('https://')), [
          '/arbeiten/',
        ]);
      },
    );

    test('the chains row exists for a deployed work only', () async {
      expect(
        await page('fixture-price-oracle-contracts'),
        contains('Bereitgestellt auf'),
      );
      expect(
        await page('fixture-price-oracle-contracts'),
        contains('<li>Chain B</li>'),
      );
      for (final slug in ['fixture-hook-sdk', 'fixture-sweep', 'fixture-app']) {
        expect(
          await page(slug),
          isNot(contains('Bereitgestellt auf')),
          reason: slug,
        );
      }
    });

    test(
      'the fee row renders only for a work with a fee, under the licence',
      () async {
        final sweep = await page('fixture-sweep');
        expect(
          sweep,
          contains(
            'Gebühr · {Satz und Grundlage}, als Partnergebühr in jeder Order, '
            'an Cube Algos',
          ),
        );
        expect(
          sweep.indexOf('Gebühr ·'),
          greaterThan(sweep.indexOf('BUSL 1.1:')),
        );
        final en = await page('fixture-sweep', Lang.en);
        expect(en, contains('Fee · {rate and base}, as a partner fee'));
        for (final slug in [
          'fixture-price-oracle-contracts',
          'fixture-hook-sdk',
          'fixture-app',
        ]) {
          for (final lang in Lang.values) {
            final html = await page(slug, lang);
            expect(html, isNot(contains('Gebühr ·')), reason: slug);
            expect(html, isNot(contains('Fee ·')), reason: slug);
          }
        }
      },
    );

    test(
      'the licensor line renders only once the grant of rights is signed',
      () async {
        expect(
          await page('fixture-sweep'),
          contains('Lizenzgeberin: Cube Algos UG (haftungsbeschränkt)'),
        );
        expect(
          await page('fixture-sweep', Lang.en),
          contains('Licensor: Cube Algos UG (haftungsbeschränkt)'),
        );
        for (final slug in [
          'fixture-price-oracle-contracts',
          'fixture-hook-sdk',
          'fixture-app',
        ]) {
          final html = await page(slug);
          expect(html, isNot(contains('Lizenzgeberin')), reason: slug);
          expect(html, isNot(contains('Rechteinhaberin')), reason: slug);
        }
      },
    );

    test(
      'the funder line renders for a funded work only, funder first in German',
      () async {
        expect(
          await page('fixture-hook-sdk'),
          contains(
            'Gefördert von Fixture Foundation im Programm Fixture Programme.',
          ),
        );
        expect(
          await page('fixture-hook-sdk', Lang.en),
          contains(
            'Funded by a grant from Fixture Foundation (Fixture Programme).',
          ),
        );
        expect(await page('fixture-sweep'), isNot(contains('Gefördert')));
      },
    );

    test(
      'BUSL: source-available with a change date; Apache: open source',
      () async {
        final sweep = await page('fixture-sweep');
        expect(sweep, contains('BUSL 1.1: Quelltext einsehbar, Nutzung offen'));
        expect(sweep, contains('Änderungsdatum'));
        expect(sweep, contains('1. Januar 2030'));
        expect(sweep, isNot(contains('Open Source')));
        final en = await page('fixture-sweep', Lang.en);
        expect(en, contains('BUSL 1.1: source-available, open use'));
        expect(en, isNot(contains('open source')));
        final oracle = await page('fixture-price-oracle-contracts');
        expect(oracle, contains('Apache-2.0, Open Source'));
        expect(oracle, isNot(contains('Änderungsdatum')));
      },
    );

    test('status, name note, notice and the closing question', () async {
      final sweep = await page('fixture-sweep');
      expect(sweep, contains('status status--public'));
      expect(sweep, contains('Quelltext öffentlich'));
      expect(sweep, contains('<span class="name-note">(Arbeitstitel)</span>'));
      expect(
        await page('fixture-price-oracle-contracts'),
        allOf(
          contains('status status--deployed'),
          contains('class="work-notice"'),
          contains(
            'Stellen Sie sie öffentlich, in den Issues ihres Repositorys.',
          ),
        ),
      );
      final app = await page('fixture-app');
      expect(app, contains('status--in-development'));
      expect(app, isNot(contains('Lizenz')));
      expect(app, isNot(contains('Links</dt>')));
      expect(
        await page('fixture-app', Lang.en),
        allOf(contains('Fixture app'), isNot(contains('Fixture-App'))),
      );
    });

    test('one line with `code` renders as code', () async {
      expect(
        await page('fixture-price-oracle-contracts'),
        contains('<code>AggregatorV3Interface</code>'),
      );
    });

    test('a work without an image has a decorative generated cover', () async {
      final html = await page('fixture-sweep');
      expect(_count(html, '<img'), 0);
      final svg = RegExp('<svg class="plate-svg"[^>]*>').firstMatch(html)![0]!;
      expect(svg, contains('aria-hidden="true"'));
      expect(svg, contains('focusable="false"'));
      expect(html, isNot(contains('<title>')));
      expect(html, isNot(contains('role="img"')));
    });

    test('images: the first is the plate, the rest a gallery', () async {
      final html = await page('fixture-hook-sdk');
      expect(html, isNot(contains('plate-svg')));
      expect(
        html,
        contains(
          'alt="Schema: eine Order, ihr Hook und die Auszahlung an die Wallet"',
        ),
      );
      expect(html, contains('alt="Schema: der Weg über einen Bundler'));
      expect(_count(html, '<img'), 2);
      expect(html, contains('<h2 id="images-title" class="vh">Bilder</h2>'));
      // Every image is self-hosted.
      expect(
        RegExp('<img [^>]*src="([^"]*)"').allMatches(html).map((m) => m[1]!),
        everyElement(startsWith('/img/')),
      );
    });
  });

  group('the back link', () {
    test(
      'draws its arrow (no glyph the fonts lack) and names the index',
      () async {
        final content = fixtureContent();
        final work = content.workBySlug('fixture-sweep')!;
        for (final lang in Lang.values) {
          final html = await renderHtml(WorkPage(lang: lang, work: work));
          final back = RegExp(
            '<p class="back">(.*?)</p>',
            dotAll: true,
          ).firstMatch(html)![1]!;
          expect(back, contains('<svg class="back-arrow"'));
          expect(back, contains('aria-hidden="true"'));
          expect(back, isNot(contains('←')));
          expect(
            back,
            contains(lang == Lang.de ? 'Alle Arbeiten' : 'All works'),
          );
          expect(back, contains('href="${pathFor(PageKey.works, lang)}"'));
        }
      },
    );
  });

  group('the generated cover', () {
    test('is the same on every build and differs per slug', () {
      expect(coverSvg('a-work'), coverSvg('a-work'));
      final covers = {
        for (final s in ['a', 'b', 'c', 'd', 'e', 'f']) coverSvg(s),
      };
      expect(covers.length, greaterThan(3));
    });

    test('takes its colours from the tokens (classes), none of its own', () {
      for (final slug in ['a', 'b', 'multi-feed-oracle', 'x-y-z']) {
        final svg = coverSvg(slug);
        expect(svg, isNot(contains('#')));
        expect(svg, isNot(contains('style=')));
        expect(svg, isNot(contains('fill="')));
        expect(svg, isNot(contains('stroke="')));
        expect(svg, contains('pl-grid'));
        expect(svg, contains('pl-amber'));
        expect(svg, contains('pl-outline'));
      }
    });
  });

  group('a room', () {
    test(
      'the link reads "Mehr erfahren: {Name}", visible and as its name',
      () async {
        final content = fixtureContent();
        final w = content.workBySlug('fixture-sweep')!;
        for (final lang in Lang.values) {
          final html = await renderHtml(
            Room(work: w, lang: lang, odd: true, level: 3),
          );
          final name = w.nameIn(lang);
          final label = lang == Lang.de ? 'Mehr erfahren' : 'Read more';
          expect(
            html,
            contains(
              '<a class="more" href="${routePath(PageKey.work, lang, w.slug)}">'
              '$label: $name</a>',
            ),
          );
          expect(html, isNot(contains('aria-label="')));
        }
      },
    );

    test('shows the number, the status and the short licence', () async {
      final w = fixtureContent().workBySlug('fixture-sweep')!;
      final html = await renderHtml(
        Room(work: w, lang: Lang.en, odd: false, level: 2),
      );
      expect(
        html,
        contains('<span class="placard-no" aria-hidden="true">03</span>'),
      );
      expect(html, contains('<p class="placard-lic">BUSL 1.1</p>'));
      expect(html, contains('room--even'));
      expect(html, contains('<h2 id="room-fixture-sweep" class="room-name">'));
    });
  });

  group('the blog', () {
    final content = fixtureContent(works: 0);

    test('the nav and footer carry the blog only with a post', () async {
      for (final lang in Lang.values) {
        final with_ = await _chrome(Route(PageKey.home, lang), content);
        final without = await _chrome(Route(PageKey.home, lang), SiteContent());
        expect(with_, contains(pathFor(PageKey.blog, lang)));
        expect(without, isNot(contains(pathFor(PageKey.blog, lang))));
      }
      expect(
        routesFor(SiteContent())
            .where((r) => r.key == PageKey.blog || r.key == PageKey.post),
        isEmpty,
      );
    });

    test(
      'the index lists the posts of its language and untranslated ones',
      () async {
        final de = await renderHtml(
          BlogIndexPage(lang: Lang.de, content: content),
        );
        expect(_hrefs(de), [
          '/en/blog/only-english/',
          '/blog/fixture-beitrag/',
        ]);
        expect(de, contains('Nur auf Englisch'));
        expect(
          de,
          contains(
            '<time datetime="2026-03-02">2. März 2026</time> · 1 Min. Lesezeit',
          ),
        );
        expect(
          de,
          contains(
            'aria-label="Ein Beispielbeitrag mit einem langen Titel, der über '
            'mehrere Zeilen läuft lesen"',
          ),
        );
        final en = await renderHtml(
          BlogIndexPage(lang: Lang.en, content: content),
        );
        expect(_hrefs(en), [
          '/en/blog/only-english/',
          '/en/blog/fixture-post/',
        ]);
        expect(en, isNot(contains('German only')));
        expect(en, contains('2 March 2026'));
      },
    );

    test(
      'a post: contents list, column, code block, links and the other language',
      () async {
        final post = content.postBySlug(Lang.en, 'fixture-post')!;
        final html = await renderHtml(PostPage(post: post, content: content));
        expect(
          html,
          contains('<h1 class="post-h1 rise" data-i="1">A fixture post'),
        );
        expect(html, contains('Contents</p>'));
        expect(
          RegExp(
            '<nav class="toc".*?</nav>',
            dotAll: true,
          ).firstMatch(html)![0],
          allOf(
            contains('href="#first-heading"'),
            contains('href="#second-heading"'),
          ),
        );
        expect(html, contains('<h2 id="first-heading">First heading</h2>'));
        expect(html, contains('<article class="prose">'));
        expect(html, contains('<code>inline code</code>'));
        expect(html, contains('<strong>bold text</strong>'));
        expect(
          html,
          contains(
            '<a rel="noreferrer" href="https://example.org/fixture">the fixture page</a>',
          ),
        );
        expect(html, contains('<ul class="prose-list">'));
        expect(
          html,
          contains(
            'Published <time datetime="2026-03-02">2 March 2026</time> · 1 min read',
          ),
        );
        // A code block is a focusable, named region that scrolls inside itself.
        expect(
          html,
          contains('<pre class="code" tabindex="0" aria-label="Code example">'),
        );
        expect(html, contains('git worktree add --relative-paths'));
        expect(html, contains('This post is also available in German.'));
        expect(html, contains('href="/blog/fixture-beitrag/"'));
        expect(html, contains('Back to the blog'));
      },
    );

    test('a post with no translation links no other language', () async {
      final post = content.postBySlug(Lang.en, 'only-english')!;
      final html = await renderHtml(PostPage(post: post, content: content));
      expect(html, isNot(contains('also available')));
      expect(html, isNot(contains('hreflang')));
      // No headings, so no contents list.
      expect(html, isNot(contains('class="toc"')));
    });

    test('routes, alternates and the language switch of a post', () {
      const route = Route(PageKey.post, Lang.en, 'fixture-post');
      expect(route.alternates(content), [Lang.de, Lang.en]);
      expect(route.switchPath(Lang.de, content), '/blog/fixture-beitrag/');
      expect(route.xDefault(content), Lang.de);
      const solo = Route(PageKey.post, Lang.en, 'only-english');
      expect(solo.alternates(content), [Lang.en]);
      expect(solo.xDefault(content), Lang.en);
      expect(solo.switchPath(Lang.de, content), '/blog/');
      expect(
        resolve('/blog/fixture-beitrag', content: content)?.slug,
        'fixture-beitrag',
      );
      expect(resolve('/blog/fixture-post/', content: content), isNull);
    });

    test('the sitemap lists a post with the alternates it has', () {
      final xml = sitemapXml(content);
      final single = RegExp(
        '<url>\\s*<loc>$siteOrigin/en/blog/only-english/</loc>(.*?)</url>',
        dotAll: true,
      ).firstMatch(xml)![1]!;
      expect(_count(single, 'hreflang='), 2);
      expect(single, contains('hreflang="en"'));
      expect(
        single,
        contains(
          'hreflang="x-default" href="$siteOrigin/en/blog/only-english/"',
        ),
      );
      final pair = RegExp(
        '<url>\\s*<loc>$siteOrigin/blog/fixture-beitrag/</loc>(.*?)</url>',
        dotAll: true,
      ).firstMatch(xml)![1]!;
      expect(
        pair,
        contains('hreflang="en" href="$siteOrigin/en/blog/fixture-post/"'),
      );
      expect(
        pair,
        contains(
          'hreflang="x-default" href="$siteOrigin/blog/fixture-beitrag/"',
        ),
      );
    });
  });

  group('the source claims (decision 54)', () {
    final all = fixtureContent();
    final inDevelopment = SiteContent(works: [all.workBySlug('fixture-app')!]);

    for (final lang in Lang.values) {
      final c = homeCopy[lang]!;
      final claim = c.sublineSource;
      final item = c.studio.singleWhere((i) => i.needsSource);

      test(
        '${lang.code}: with no work and with only an unpublished one',
        () async {
          for (final content in [fixtureContent(works: 0), inDevelopment]) {
            expect(content.hasPublicSource, isFalse);
            final home = await renderHtml(
              HomePage(lang: lang, content: content),
            );
            // The subline stops before the claim; the item is not shown.
            expect(home, contains('>${c.subline}<'));
            expect(home, isNot(contains(claim)));
            expect(home, isNot(contains(item.lead)));
            expect(home, isNot(contains(githubOrgUrl)));
            expect('<li class="reveal"'.allMatches(home), hasLength(5));
          }
        },
      );

      test('${lang.code}: with a work that links its source', () async {
        final content = fixtureContent(works: 1);
        expect(content.hasPublicSource, isTrue);
        final home = await renderHtml(HomePage(lang: lang, content: content));
        expect(home, contains('${c.subline} $claim'));
        expect(home, contains('<strong>${item.lead}</strong>'));
        expect(home, contains('href="$githubOrgUrl"'));
        expect('<li class="reveal"'.allMatches(home), hasLength(6));
      });
    }
  });

  group('the AI line', () {
    test('the studio item and About link the post when it exists', () async {
      final shipped = shippedContent;
      for (final lang in Lang.values) {
        final post = shipped.postById(lang, aiPostId)!;
        final path = routePath(PageKey.post, lang, post.slug);
        final home = await renderHtml(HomePage(lang: lang, content: shipped));
        expect(
          home,
          contains('<a class="item-link" href="$path">${post.title}</a>'),
        );
        final about = await renderHtml(AboutPage(lang: lang, content: shipped));
        expect(about, contains('class="item-link"'));
        expect(_hrefs(about), contains(path));
      }
    });

    test('without the post the line stays and the link goes', () async {
      final none = fixtureContent();
      final home = await renderHtml(HomePage(lang: Lang.en, content: none));
      expect(
        home,
        contains('We love working with modern technology, AI included.'),
      );
      expect(home, isNot(contains('item-link')));
    });
  });

  group('the page shell', () {
    test(
      'a post in one language has one alternate and no og:locale:alternate',
      () async {
        final content = fixtureContent(works: 0);
        final html = await renderHtml(
          PageShell(
            route: const Route(PageKey.post, Lang.en, 'only-english'),
            content: content,
          ),
        );
        expect(html, contains('<title>Only in English | Cube Algos</title>'));
        expect(
          RegExp('rel="alternate"').allMatches(html).length,
          2,
          reason: 'en and x-default',
        );
        expect(html, isNot(contains('og:locale:alternate')));
        expect(html, contains('<main id="main" class="flush"'));
      },
    );

    test(
      'a post with a translation has both and the locale alternate',
      () async {
        final content = fixtureContent(works: 0);
        final html = await renderHtml(
          PageShell(
            route: const Route(PageKey.post, Lang.en, 'fixture-post'),
            content: content,
          ),
        );
        expect(RegExp('rel="alternate"').allMatches(html).length, 3);
        expect(html, contains('og:locale:alternate'));
        expect(html, contains('href="$siteOrigin/blog/fixture-beitrag/"'));
      },
    );
  });
}
