// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/content/markdown.dart';
import 'package:website/src/content/post.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/copy/blog_copy.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

String _isoDate(DateTime d) => d.toIso8601String().substring(0, 10);

/// `{key}` placeholders of a copy line replaced by [values].
String _fill(String line, Map<String, String> values) => values.entries.fold(
  line,
  (text, e) => text.replaceAll('{${e.key}}', e.value),
);

/// [template] with its `{date}` as a `<time>` element and the other
/// placeholders of [values] replaced.
List<Component> _dated(
  String template,
  Post post,
  Lang lang, [
  Map<String, String> values = const {},
]) {
  final parts = _fill(template, values).split('{date}');
  return [
    if (parts.first.isNotEmpty) t(parts.first),
    el(
      'time',
      attrs: {'datetime': _isoDate(post.date)},
      [t(formatDate(post.date, lang))],
    ),
    if (parts.last.isNotEmpty) t(parts.last),
  ];
}

/// The index of the posts: one ruled row per post, newest first, of both
/// languages (a post of the other language is marked and linked as such).
/// Built only when there is a post.
class BlogIndexPage extends StatelessComponent {
  /// Creates the index in [lang] over [content].
  const new({required this.lang, required this.content, super.key});

  /// The page's language.
  final Lang lang;

  /// The posts of the site.
  final SiteContent content;

  @override
  Component build(BuildContext context) {
    final c = blogCopy[lang]!;
    final meta = pageMeta[PageKey.blog]![lang]!;
    return Component.fragment([
      el('section', classes: 'hero hero--page', [
        el('div', classes: 'wrap hero-grid gridlines', [
          el('div', classes: 'hero-text', [
            h1(classes: 'hero-h1 rise', [t(meta.h1)]),
            p(
              classes: 'hero-sub rise',
              attributes: const {'data-i': '1'},
              [t(c.lede)],
            ),
          ]),
        ]),
      ]),
      el(
        'section',
        classes: 'sec sec--first',
        attrs: {'aria-label': meta.h1},
        [
          div(classes: 'wrap', [
            ol(
              classes: 'posts',
              attributes: const {'role': 'list'},
              [for (final post in _listed()) _row(c, post)],
            ),
          ]),
        ],
      ),
    ]);
  }

  /// The posts to list: those of this language, and those that exist in the
  /// other language only (a post with a translation is listed once).
  Iterable<Post> _listed() => content.posts.where(
    (post) => post.lang == lang || content.translationOf(post) == null,
  );

  Component _row(BlogCopy c, Post post) {
    final foreign = post.lang != lang;
    return li(classes: 'post-row reveal', [
      p(classes: 'post-meta', [
        ..._dated(c.meta, post, lang, {'n': '${post.minutes}'}),
        if (foreign) t(' · ${c.otherLanguageOnly}'),
      ]),
      h2(classes: 'post-row-title', [
        a(
          [t(post.title)],
          href: routePath(PageKey.post, post.lang, post.slug),
          attributes: {
            'aria-label': _fill(c.readLink, {'title': post.title}),
            if (foreign) ...{
              'lang': post.lang.code,
              'hreflang': post.lang.code,
            },
          },
        ),
      ]),
      p(classes: 'post-row-desc', [t(post.description)]),
    ]);
  }
}

/// The page of one post: title and date, the contents list beside the text
/// (sticky from 64rem), the text in a column of about 66 characters.
class PostPage extends StatelessComponent {
  /// Creates the page of [post] over [content].
  const new({required this.post, required this.content, super.key});

  /// The post.
  final Post post;

  /// The posts of the site (to find the translation).
  final SiteContent content;

  @override
  Component build(BuildContext context) {
    final lang = post.lang;
    final c = blogCopy[lang]!;
    final other = content.translationOf(post);
    final headings = post.body.headings.toList();
    return Component.fragment([
      el('section', classes: 'hero hero--page post-hero', [
        div(classes: 'wrap post-grid', [
          div(classes: 'post-head-side', [
            BackLink(label: c.back, href: pathFor(PageKey.blog, lang)),
            p(classes: 'post-meta rise', [
              ..._dated(c.published, post, lang),
              t(' · ${_fill(c.readingTime, {'n': '${post.minutes}'})}'),
            ]),
          ]),
          h1(
            classes: 'post-h1 rise',
            attributes: const {'data-i': '1'},
            [t(post.title)],
          ),
        ]),
      ]),
      div(classes: 'post-wrap', [
        div(classes: 'wrap post-grid', [
          aside(classes: 'post-aside', [
            if (headings.isNotEmpty)
              nav(
                classes: 'toc',
                attributes: const {'aria-labelledby': 'toc-title'},
                [
                  p(id: 'toc-title', classes: 'eyebrow-muted', [
                    t(c.contentsTitle),
                  ]),
                  ol([
                    for (final h in headings)
                      li([
                        a([t(h.text)], href: '#${h.id}'),
                      ]),
                  ]),
                ],
              ),
            if (other != null)
              p(classes: 'post-other', [
                a(
                  [t(c.otherLanguage)],
                  href: routePath(PageKey.post, other.lang, other.slug),
                  attributes: {
                    'lang': other.lang.code,
                    'hreflang': other.lang.code,
                  },
                ),
              ]),
          ]),
          article(classes: 'prose', [
            for (final block in post.body.blocks) _block(c, block),
            p(classes: 'post-end', [
              a(
                [t(c.end)],
                href: pathFor(PageKey.blog, lang),
                classes: 'text-link',
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _block(BlogCopy c, MdBlock block) => switch (block) {
    Heading(:final text, :final id) => h2(id: id, [t(text)]),
    Paragraph(:final inlines) => p(inlineComponents(inlines)),
    BulletList(:final items) => ul(classes: 'prose-list', [
      for (final item in items) li(inlineComponents(item)),
    ]),
    // A scrollable region: focusable so the keyboard can scroll it.
    CodeBlock(:final code) => pre(
      classes: 'code',
      attributes: {'tabindex': '0', 'aria-label': c.codeLabel},
      [
        Component.element(tag: 'code', children: [t(code)]),
      ],
    ),
  };
}
