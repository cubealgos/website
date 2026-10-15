// SPDX-License-Identifier: Apache-2.0

// The compliance rules of a work's data file, the blog's Markdown and the
// post files, over inline data and the fixtures (outside the shipped data).
import 'package:test/test.dart';
import 'package:website/src/content/markdown.dart';
import 'package:website/src/content/post.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/content/work.dart';
import 'package:website/src/routes.dart';

import 'support/fixtures.dart';

Map<String, Object?> _work([Map<String, Object?> extra = const {}]) => {
  'number': 1,
  'name': 'Example',
  'slug': 'example',
  'line': {'de': 'Eine Zeile.', 'en': 'A line.'},
  'status': 'in-development',
  ...extra,
};

const _source = {'source': 'https://example.org/example'};

Work _parse(Map<String, Object?> json) =>
    Work.fromJson(json, file: 'example.json');

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
  group('a work data file', () {
    test('the smallest valid one parses', () {
      final w = _parse(_work());
      expect(w.status, WorkStatus.inDevelopment);
      expect(w.kind, WorkKind.contract);
      expect(w.nameIn(Lang.en), 'Example');
    });

    test('nameEn replaces the name in English only', () {
      final w = _parse(_work({'nameEn': 'Sample'}));
      expect(w.nameIn(Lang.de), 'Example');
      expect(w.nameIn(Lang.en), 'Sample');
    });

    test('an unknown field, slug or status is refused', () {
      expect(() => _parse(_work({'colour': 'red'})), _fails('colour'));
      expect(() => _parse(_work({'slug': 'Not A Slug'})), _fails('slug'));
      expect(() => _parse(_work({'status': 'soon'})), _fails('status'));
      expect(() => _parse(_work({'number': 0})), _fails('number'));
    });

    test('both languages of a text are required', () {
      expect(
        () => _parse(
          _work({
            'line': {'de': 'nur deutsch'},
          }),
        ),
        _fails('line.en'),
      );
      expect(
        () => _parse(
          _work({
            'about': {'de': 'a', 'en': ''},
          }),
        ),
        _fails('about.en'),
      );
    });

    test('a link must be an https URL', () {
      for (final bad in ['#', 'http://example.org/x', 'example.org', '']) {
        expect(
          () => _parse(
            _work({
              'links': {'source': bad},
            }),
          ),
          _fails('links.source'),
          reason: bad,
        );
      }
      expect(
        () => _parse(
          _work({
            'links': {'mirror': 'https://example.org/x'},
          }),
        ),
        _fails('links.mirror'),
      );
    });

    group('a contract work that is public', () {
      test('needs its source link', () {
        expect(
          () => _parse(_work({'status': 'public', 'licence': 'apache-2.0'})),
          _fails('links.source'),
        );
      });
      test('needs a licence', () {
        expect(
          () => _parse(_work({'status': 'public', 'links': _source})),
          _fails('licence'),
        );
      });
      test('parses with both', () {
        final w = _parse(
          _work({
            'status': 'public',
            'licence': 'apache-2.0',
            'links': _source,
          }),
        );
        expect(w.links[WorkLink.source], 'https://example.org/example');
      });
      test('an app needs neither', () {
        expect(
          () => _parse(_work({'kind': 'app', 'status': 'public'})),
          returnsNormally,
        );
      });
    });

    group('a deployed work', () {
      final deployed = {
        'status': 'deployed',
        'licence': 'apache-2.0',
        'links': _source,
        'chains': ['Chain A'],
      };
      test('a contract needs its chains', () {
        expect(
          () => _parse(_work({...deployed, 'chains': <String>[]})),
          _fails('chains'),
        );
      });
      test('an app needs its app link', () {
        expect(
          () => _parse(_work({'kind': 'app', 'status': 'deployed'})),
          _fails('links.app'),
        );
        expect(
          () => _parse(
            _work({
              'kind': 'app',
              'status': 'deployed',
              'links': {'app': 'https://example.org/app'},
            }),
          ),
          returnsNormally,
        );
      });
      test('that charges needs a fee, without placeholders', () {
        expect(
          () => _parse(_work({...deployed, 'charges': true})),
          _fails('fee'),
        );
        expect(
          () => _parse(
            _work({
              ...deployed,
              'charges': true,
              'fee': {'de': '{Satz}', 'en': '{rate}'},
            }),
          ),
          _fails('placeholders'),
        );
        expect(
          () => _parse(
            _work({
              ...deployed,
              'charges': true,
              'fee': {'de': '0,1 %', 'en': '0.1%'},
            }),
          ),
          returnsNormally,
        );
      });
      test('a work that is only public may still carry placeholders', () {
        expect(
          () => _parse(
            _work({
              'status': 'public',
              'licence': 'apache-2.0',
              'links': _source,
              'charges': true,
              'fee': {'de': '{Satz}', 'en': '{rate}'},
            }),
          ),
          returnsNormally,
        );
      });
    });

    test('a fee needs "charges" and a licence', () {
      const fee = {'de': 'x', 'en': 'y'};
      expect(() => _parse(_work({'fee': fee})), _fails('charges'));
      expect(
        () => _parse(_work({'fee': fee, 'charges': true})),
        _fails('licence'),
      );
    });

    group('BUSL 1.1', () {
      final busl = {
        'status': 'public',
        'licence': 'busl-1.1',
        'links': _source,
        'changeDate': {'de': '1. Januar 2030', 'en': '1 January 2030'},
      };
      test('needs a change date, and only BUSL has one', () {
        expect(
          () => _parse(_work({...busl}..remove('changeDate'))),
          _fails('changeDate'),
        );
        expect(
          () => _parse(_work({...busl, 'licence': 'apache-2.0'})),
          _fails('changeDate'),
        );
        expect(() => _parse(_work(busl)), returnsNormally);
      });

      test('a notice that names Chainlink or RedStone keeps all of MF-8', () {
        const full = {
          'de':
              'Das Orakel ist unveränderlich, die Feeds, die es liest, sind es '
              'nicht. Wer es nutzt, wählt die Konfiguration, prüft `updatedAt` '
              'und trägt das Preisrisiko. Nicht mit Chainlink oder RedStone '
              'verbunden und von ihnen nicht unterstützt.',
          'en':
              'The oracle is immutable; the feeds it reads are not. A consumer '
              'chooses the configuration, checks `updatedAt` and bears the '
              'price risk. Not affiliated with or endorsed by Chainlink or '
              'RedStone.',
        };
        expect(_parse(_work({'notice': full})).notice, {
          Lang.de: full['de'],
          Lang.en: full['en'],
        });
        // The last sentence alone is refused, in either language.
        expect(
          () => _parse(
            _work({
              'notice': {
                'de': 'Nicht mit Chainlink oder RedStone verbunden.',
                'en': full['en'],
              },
            }),
          ),
          _fails('all three sentences'),
        );
        expect(
          () => _parse(
            _work({
              'notice': {
                'de': full['de'],
                'en': 'Not affiliated with or endorsed by Chainlink.',
              },
            }),
          ),
          _fails('all three sentences'),
        );
      });

      test('is never "open source" (source-available, open use)', () {
        for (final text in [
          'This is open source.',
          'Open-Source',
          'quelloffen',
        ]) {
          expect(
            () => _parse(
              _work({
                ...busl,
                'about': {'de': text, 'en': text},
              }),
            ),
            _fails('open source'),
            reason: text,
          );
        }
      });
    });

    test('an image is self-hosted and has alt text in both languages', () {
      Map<String, Object?> image({String src = '/img/a.png', Object? alt}) => {
        'src': src,
        'width': 10,
        'height': 10,
        'alt': alt ?? {'de': 'Ein Bild', 'en': 'An image'},
      };
      expect(
        () => _parse(
          _work({
            'images': [image(src: 'https://example.org/a.png')],
          }),
        ),
        _fails('images[0].src'),
      );
      expect(
        () => _parse(
          _work({
            'images': [image(src: '/img/../a.png')],
          }),
        ),
        _fails('images[0].src'),
      );
      expect(
        () => _parse(
          _work({
            'images': [
              image(alt: {'de': 'nur'}),
            ],
          }),
        ),
        _fails('images[0].alt.en'),
      );
      expect(
        () => _parse(
          _work({
            'images': [image()],
          }),
        ),
        returnsNormally,
      );
    });

    test('a funder needs a programme and a funder', () {
      expect(
        () => _parse(
          _work({
            'funder': {'programme': 'P'},
          }),
        ),
        _fails('funder'),
      );
      final w = _parse(
        _work({
          'funder': {'programme': 'P', 'funder': 'F'},
        }),
      );
      expect(w.funder, (programme: 'P', funder: 'F'));
    });
  });

  group('SiteContent', () {
    test('works are kept newest first, posts by date', () {
      final c = fixtureContent();
      expect([for (final w in c.works) w.number], [4, 3, 2, 1]);
      expect(
        [for (final p in c.posts) p.slug],
        ['only-english', 'fixture-beitrag', 'fixture-post'],
      );
    });

    test('two works may not share a slug or a number', () {
      final a = _parse(_work());
      expect(
        () => SiteContent(
          works: [
            a,
            _parse(_work({'number': 2})),
          ],
        ),
        _fails('work slug'),
      );
      expect(
        () => SiteContent(
          works: [
            a,
            _parse(_work({'slug': 'other'})),
          ],
        ),
        _fails('work number'),
      );
    });

    test('only a work with a source link says the source is public', () {
      final c = fixtureContent();
      expect(c.hasPublicSource, isTrue);
      expect(fixtureContent(works: 0).hasPublicSource, isFalse);
      expect(
        SiteContent(works: [c.workBySlug('fixture-app')!]).hasPublicSource,
        isFalse,
      );
    });

    test('with nothing there is nothing to show', () {
      final c = SiteContent();
      expect(c.hasWorks, isFalse);
      expect(c.hasPosts, isFalse);
      expect(c.newestPostFor(Lang.de), isNull);
    });

    test('the shipped data is valid; no work ships yet', () {
      final shipped = shippedContent;
      expect(shipped.works, isEmpty);
      expect(shipped.posts.map((p) => '${p.lang.code}:${p.id}').toSet(), {
        'de:ai-agents',
        'en:ai-agents',
      });
    });

    test('the allowed outbound links include those of the works and posts', () {
      final c = fixtureContent();
      expect(c.outboundAllowed, contains('https://example.org/fixture'));
      expect(
        c.outboundAllowed,
        contains('https://example.org/fixtures/fixture-sweep'),
      );
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
