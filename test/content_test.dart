// SPDX-License-Identifier: Apache-2.0

// The blog's Markdown and the post files, over inline data and the fixtures
// (outside the shipped data).
import 'package:test/test.dart';
import 'package:website/src/content/markdown.dart';
import 'package:website/src/content/post.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

import 'support/fixtures.dart';

Matcher _fails(String about) => throwsA(
  isA<FormatException>().having((e) => e.message, 'message', contains(about)),
);

String _postSource({
  String slug = 'a-post',
  String lang = 'en',
  String date = '2026-01-02',
  String extra = '',
  String body = '# Title\n\nLede.\n\n## Heading\n\nText.\n',
}) =>
    '---\nid: a-post\nslug: $slug\nlang: $lang\ndate: $date\n'
    'seoTitle: SEO\ndescription: Desc\n$extra---\n\n$body';

void main() {
  group('SiteContent', () {
    test('posts are kept newest first, by date', () {
      final c = fixtureContent();
      expect(
        [for (final p in c.posts) p.slug],
        ['only-english', 'fixture-beitrag', 'fixture-post'],
      );
    });

    test('two posts may not share a slug or an id in a language', () {
      final c = fixtureContent();
      final a = c.postBySlug(Lang.en, 'fixture-post')!;
      expect(() => SiteContent(posts: [a, a]), _fails('post slug'));
    });

    test('with nothing there is nothing to show', () {
      final c = SiteContent();
      expect(c.hasPosts, isFalse);
      expect(c.newestPostFor(Lang.de), isNull);
    });

    test('the shipped data is valid: the one post in both languages', () {
      final shipped = shippedContent;
      expect(shipped.posts.map((p) => '${p.lang.code}:${p.id}').toSet(), {
        'de:ai-agents',
        'en:ai-agents',
      });
    });

    test('the allowed outbound links are the fixed ones and the posts', () {
      final c = fixtureContent();
      expect(c.outboundAllowed, containsAll(outboundUrls));
      expect(c.outboundAllowed, contains('https://example.org/fixture'));
      // A path link of a post is no outbound link.
      expect(c.outboundAllowed, isNot(contains('/en/blog/')));
    });

    test('a post is found by slug, id and as a translation', () {
      final c = fixtureContent();
      final en = c.postBySlug(Lang.en, 'fixture-post')!;
      expect(c.translationOf(en)!.slug, 'fixture-beitrag');
      expect(c.postById(Lang.de, 'fixture-post')!.lang, Lang.de);
      expect(c.translationOf(c.postBySlug(Lang.en, 'only-english')!), isNull);
      expect(c.postBySlug(Lang.de, 'fixture-post'), isNull);
    });

    test("the newest post is the visitor's language when there is one", () {
      final c = fixtureContent();
      expect(c.newestPostFor(Lang.en)!.slug, 'only-english');
      expect(c.newestPostFor(Lang.de)!.slug, 'fixture-beitrag');
      final onlyEnglish = SiteContent(
        posts: [c.postBySlug(Lang.en, 'only-english')!],
      );
      expect(onlyEnglish.newestPostFor(Lang.de)!.lang, Lang.en);
    });
  });

  group('the blog Markdown', () {
    Markdown md(String s) => Markdown.parse(s, file: 'x.md');

    test('headings, paragraphs, lists and code', () {
      final m = md(
        'Lede\nover two lines.\n\n## One\n\n- a\n- b\n  continued\n\n'
        '```\ncode  line\n  indented\n```\n\n## Two\n',
      );
      expect(m.blocks.map((b) => b.runtimeType.toString()), [
        'Paragraph',
        'Heading',
        'BulletList',
        'CodeBlock',
        'Heading',
      ]);
      expect(plain((m.blocks[0] as Paragraph).inlines), 'Lede over two lines.');
      final list = m.blocks[2] as BulletList;
      expect([for (final i in list.items) plain(i)], ['a', 'b continued']);
      expect((m.blocks[3] as CodeBlock).code, 'code  line\n  indented');
      expect([for (final h in m.headings) h.id], ['one', 'two']);
    });

    test('heading ids are plain, transliterated and unique', () {
      final m = md('## Größe und Übung\n\n## Größe und Übung\n');
      expect(
        [for (final h in m.headings) h.id],
        ['groesse-und-uebung', 'groesse-und-uebung-2'],
      );
      expect(slugify('Wo die Grenzen liegen?'), 'wo-die-grenzen-liegen');
    });

    test('inline code, bold and links', () {
      final i = parseInline('a `b` **c** [d](https://example.org/) e');
      expect(i.map((e) => e.runtimeType.toString()), [
        'TextRun',
        'CodeSpan',
        'TextRun',
        'Strong',
        'TextRun',
        'LinkRun',
        'TextRun',
      ]);
      expect(plain(i), 'a b c d e');
    });

    test('what the template does not style is refused, with the line', () {
      for (final (text, line) in [
        ('Text\n\n### Third level\n', 3),
        ('1. numbered\n', 1),
        ('> quote\n', 1),
        ('| a | b |\n', 1),
        ('![alt](x.png)\n', 1),
        ('<div>html</div>\n', 1),
        ('```\nnever closed\n', 1),
      ]) {
        expect(
          () => md(text),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              startsWith('x.md:$line:'),
            ),
          ),
          reason: text,
        );
      }
    });
  });

  group('a post file', () {
    Post parse(String s, {String file = 'a-post.en.md'}) =>
        Post.parse(s, file: file);

    test('parses its front matter, title, body and reading time', () {
      final p = parse(_postSource());
      expect(p.id, 'a-post');
      expect(p.lang, Lang.en);
      expect(p.date, DateTime.utc(2026, 1, 2));
      expect(p.title, 'Title');
      expect(p.seoTitle, 'SEO');
      expect(p.minutes, 1);
      expect(p.body.headings.single.text, 'Heading');
    });

    test('2000 words take ten minutes', () {
      final p = parse(_postSource(body: '# T\n\n${'word ' * 2000}\n'));
      expect(p.minutes, 10);
    });

    test('refuses a file that would render something wrong', () {
      expect(() => parse('# T\n'), _fails('front matter'));
      expect(
        () => parse(_postSource(extra: 'colour: red\n')),
        _fails('unknown key'),
      );
      expect(
        () => parse(_postSource().replaceFirst('seoTitle: SEO\n', '')),
        _fails('seoTitle'),
      );
      expect(() => parse(_postSource(lang: 'fr')), _fails('lang'));
      expect(() => parse(_postSource(date: '2026-13-45')), _fails('date'));
      expect(() => parse(_postSource(date: 'May 1')), _fails('date'));
      expect(
        () => parse(_postSource(), file: 'other-name.en.md'),
        _fails('must be named a-post.en.md'),
      );
      expect(
        () => parse(_postSource(body: 'No title.\n')),
        _fails('"# " title'),
      );
      expect(
        () => parse(_postSource(body: '# T\n\n## Heading first\n')),
        _fails('lede'),
      );
      expect(() => parse(_postSource(body: '# T\n')), _fails('no text'));
    });

    test('a link is a path, a mailto: or an https URL', () {
      for (final bad in [
        'javascript:alert(1)',
        'http://example.org',
        '//x.org',
      ]) {
        expect(
          () => parse(_postSource(body: '# T\n\nA [link]($bad).\n')),
          _fails('link'),
          reason: bad,
        );
      }
      for (final good in [
        '/blog/',
        'mailto:a@example.org',
        'https://example.org/',
      ]) {
        expect(
          () => parse(_postSource(body: '# T\n\nA [link]($good).\n')),
          returnsNormally,
          reason: good,
        );
      }
    });
  });
}
