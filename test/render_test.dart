// SPDX-License-Identifier: Apache-2.0

// The blog templates and the page shell, rendered at test time from fixtures
// (outside the shipped data): posts in one or both languages, and the frame
// (header, footer) around them. No build is needed.
import 'package:test/test.dart';
import 'package:website/src/chrome.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/page.dart';
import 'package:website/src/pages/blog_pages.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';

import 'support/fixtures.dart';
import 'support/render.dart';

int _count(String html, Pattern what) => what.allMatches(html).length;

/// The hrefs of the `<a>` elements of [html].
List<String> _hrefs(String html) => [
  for (final m in RegExp('<a [^>]*href="([^"]*)"').allMatches(html)) m[1]!,
];

/// The link labels of the navigation landmark named [landmark].
List<String> _navLabels(String html, String landmark) {
  final nav = RegExp(
    '<nav[^>]*aria-label="$landmark"[^>]*>(.*?)</nav>',
    dotAll: true,
  ).firstMatch(html)![1]!;
  return [for (final m in RegExp('<a [^>]*>(.*?)</a>').allMatches(nav)) m[1]!];
}

Future<String> _header(Route route, SiteContent content) =>
    renderHtml(SiteHeader(route: route, content: content));

Future<String> _footer(Route route) => renderHtml(SiteFooter(route: route));

void main() {
  group('the frame', () {
    final content = fixtureContent();

    for (final lang in Lang.values) {
      final main = lang == Lang.de ? 'Hauptnavigation' : 'Main';

      test(
        '${lang.code}: the header lists Blog and Contact, no Home',
        () async {
          final header = await _header(Route(PageKey.home, lang), content);
          expect(
            _navLabels(header, main),
            lang == Lang.de ? ['Blog', 'Kontakt'] : ['Blog', 'Contact'],
          );
          // The logo is the way home.
          expect(
            header,
            contains(
              lang == Lang.de
                  ? 'aria-label="Cube Algos, Startseite"'
                  : 'aria-label="Cube Algos, Home"',
            ),
          );
          for (final gone in [
            '/ueber/',
            '/en/about/',
            '/arbeiten/',
            '/en/work/',
          ]) {
            expect(header, isNot(contains('href="$gone"')), reason: gone);
          }
        },
      );

      test('${lang.code}: no Blog item without a post', () async {
        final header = await _header(Route(PageKey.home, lang), SiteContent());
        expect(
          _navLabels(header, main),
          lang == Lang.de ? ['Kontakt'] : ['Contact'],
        );
      });

      test(
        '${lang.code}: the footer has no tagline and no navigation',
        () async {
          final footer = await _footer(Route(PageKey.home, lang));
          expect(footer, isNot(contains('tagline')));
          expect(footer, isNot(contains('Softwarestudio seit')));
          expect(footer, isNot(contains('Software studio since')));
          // One navigation landmark: the legal links.
          expect(_count(footer, '<nav'), 1);
          expect(
            _navLabels(footer, lang == Lang.de ? 'Rechtliches' : 'Legal'),
            ['Impressum', 'Datenschutz'],
          );
          // No second language switch either: the header has it.
          expect(footer, isNot(contains('lang-switch')));
          expect(footer, contains('mailto:hello@cubealgos.de'));
          expect(
            footer,
            contains('https://www.linkedin.com/company/cubealgos/'),
          );
          expect(footer, contains('© 2026 Cube Algos UG (haftungsbeschränkt)'));
        },
      );
    }

    test('a post belongs to the Blog item of the header', () async {
      final header = await _header(
        const Route(PageKey.post, Lang.en, 'fixture-post'),
        content,
      );
      expect(header, contains('aria-current="true"'));
    });
  });

  group('the blog', () {
    final content = fixtureContent();

    test('the nav carries the blog only with a post', () async {
      for (final lang in Lang.values) {
        final with_ = await _header(Route(PageKey.home, lang), content);
        final without = await _header(Route(PageKey.home, lang), SiteContent());
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
        expect(de, contains('Auf Englisch'));
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
        expect(en, isNot(contains('In German')));
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

  group('the page shell', () {
    test(
      'a post in one language has one alternate and no og:locale:alternate',
      () async {
        final content = fixtureContent();
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
        final content = fixtureContent();
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
