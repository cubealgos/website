// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/content/post.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/copy/blog_copy.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/pages/work_widgets.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';
import 'package:website/src/sting.dart';
import 'package:website/src/widgets.dart';

/// Rooms the home page shows before it links to the rest.
const homeRooms = 2;

/// The home page body: hero with the stack card, the works (only with a
/// work), the studio in the ink band, one post (only with a post), the closing
/// panel.
class HomePage extends StatelessComponent {
  /// Creates the home page in [lang] showing [content].
  const new({required this.lang, required this.content, super.key});

  /// The page's language.
  final Lang lang;

  /// The works and posts of the site.
  final SiteContent content;

  @override
  Component build(BuildContext context) {
    final c = homeCopy[lang]!;
    return Component.fragment([
      _hero(c),
      if (content.hasWorks) _works(c),
      _studio(c),
      if (content.newestPostFor(lang) case final post?) _teaser(c, post),
      _cta(c),
    ]);
  }

  Component _hero(HomeCopy c) {
    final at = c.h1.indexOf(c.h1Mark);
    assert(at >= 0, 'h1Mark must be part of h1');
    return el('section', classes: 'hero', [
      el('div', classes: 'wrap hero-grid gridlines', [
        el('div', classes: 'hero-text', [
          p(classes: 'eyebrow rise', [t(c.eyebrow)]),
          h1(
            classes: 'rise hero-h1',
            attributes: const {'data-i': '1'},
            [
              t(c.h1.substring(0, at)),
              span(classes: 'mark', [t(c.h1Mark)]),
              t(c.h1.substring(at + c.h1Mark.length)),
            ],
          ),
          // Two sublines; CSS shows the short one below 30rem and hides the
          // other with `display: none`, so only one is exposed to assistive
          // tech at a time.
          div(
            classes: 'hero-sublines rise',
            attributes: const {'data-i': '2'},
            [
              p(classes: 'hero-sub hero-sub--full', [t(c.subline)]),
              p(classes: 'hero-sub hero-sub--short', [t(c.sublineShort)]),
            ],
          ),
          el(
            'div',
            classes: 'actions rise',
            attrs: const {'data-i': '3'},
            [
              // With a work the button leads to the work; with none, to the
              // studio.
              LinkButton(
                label: content.hasWorks ? c.buttonWork : c.buttonStudio,
                href: '#${content.hasWorks ? c.workAnchor : c.studioAnchor}',
              ),
              a(
                [t(c.secondaryCta)],
                href: pathFor(PageKey.contact, lang),
                classes: 'text-link',
              ),
            ],
          ),
        ]),
        _stack(c),
      ]),
    ]);
  }

  /// The tech stack beside the headline: label and value rows on a route
  /// line. The mark sting plays in the card head.
  Component _stack(HomeCopy c) => el('div', classes: 'stack-col', [
    el(
      'aside',
      classes: 'ledger stack-card rise',
      attrs: const {'data-i': '2', 'aria-labelledby': 'stack-label'},
      [
        div(classes: 'ledger-head', [
          p(id: 'stack-label', classes: 'eyebrow-muted', [t(c.stackTitle)]),
          div(classes: 'ledger-mark', [RawText(stingSvg())]),
        ]),
        dl(classes: 'stack', [
          for (final row in c.stack)
            div([
              dt([t(row.label)]),
              dd([t(row.value)]),
            ]),
        ]),
      ],
    ),
  ]);

  /// The works as rooms: the newest [homeRooms], then the link to all.
  Component _works(HomeCopy c) => el(
    'section',
    classes: 'works works--c',
    id: c.workAnchor,
    attrs: const {'aria-labelledby': 'works-title'},
    [
      div(classes: 'wrap works-head', [
        el('div', classes: 'sec-head reveal', [
          h2(id: 'works-title', [t(c.workTitle)]),
          p(classes: 'measure', [t(c.workIntro)]),
        ]),
      ]),
      for (final (i, work) in content.works.take(homeRooms).indexed)
        Room(work: work, lang: lang, odd: i.isEven, level: 3),
      if (content.works.length > homeRooms)
        div(classes: 'wrap rooms-more', [
          a(
            [t(c.allWorks.replaceAll('{n}', '${content.works.length}'))],
            href: pathFor(PageKey.works, lang),
            classes: 'text-link',
          ),
        ]),
    ],
  );

  /// The studio in the ink band: six items in two columns.
  Component _studio(HomeCopy c) => el(
    'section',
    classes: 'band studio-band',
    id: c.studioAnchor,
    attrs: const {'aria-labelledby': 'studio-title'},
    [
      div(classes: 'wrap band-grid', [
        h2(id: 'studio-title', classes: 'band-title reveal', [
          t(c.studioTitle),
        ]),
        ul(classes: 'studio-list', [
          for (final (i, item) in c.studio.indexed)
            li(
              classes: 'reveal',
              attributes: {'data-i': '${i < 5 ? i : 5}'},
              [
                strong([t(item.lead)]),
                t(' '),
                ...inlineLinks(item.text),
                if (item.postId case final id?)
                  if (content.postById(lang, id) case final post?) ...[
                    t(' '),
                    a(
                      [t(post.title)],
                      href: routePath(PageKey.post, lang, post.slug),
                      classes: 'item-link',
                    ),
                  ],
              ],
            ),
        ]),
      ]),
    ],
  );

  /// One post: the newest one for this language.
  Component _teaser(HomeCopy c, Post post) {
    final b = blogCopy[lang]!;
    final foreign = post.lang != lang;
    return el(
      'section',
      classes: 'sec teaser',
      attrs: const {'aria-labelledby': 'teaser-title'},
      [
        div(classes: 'wrap teaser-grid', [
          h2(id: 'teaser-title', classes: 'teaser-h2 reveal', [t(c.blogTitle)]),
          el(
            'div',
            classes: 'teaser-body reveal',
            attrs: const {'data-i': '1'},
            [
              p(classes: 'post-meta', [
                el(
                  'time',
                  attrs: {'datetime': _isoDate(post.date)},
                  [t(formatDate(post.date, lang))],
                ),
                if (foreign) t(' · ${b.otherLanguageOnly}'),
              ]),
              h3(classes: 'teaser-title', [
                a(
                  [t(post.title)],
                  href: routePath(PageKey.post, post.lang, post.slug),
                  attributes: {
                    if (foreign) ...{
                      'lang': post.lang.code,
                      'hreflang': post.lang.code,
                    },
                  },
                ),
              ]),
              p(classes: 'teaser-desc', [t(post.description)]),
              a(
                [t(c.allPosts)],
                href: pathFor(PageKey.blog, lang),
                classes: 'text-link',
              ),
            ],
          ),
        ]),
      ],
    );
  }

  Component _cta(HomeCopy c) => el(
    'section',
    classes: 'cta-sec',
    attrs: const {'aria-labelledby': 'cta-title'},
    [
      div(classes: 'wrap', [
        el('div', classes: 'cta reveal', [
          el('div', classes: 'cta-text', [
            h2(id: 'cta-title', [t(c.ctaTitle)]),
            p([t(c.ctaText)]),
            MailButton(label: c.ctaButton, inverse: true),
          ]),
          const div(classes: 'cta-fish', [Fish(pose: 'happy', onAmber: true)]),
        ]),
        el(
          'script',
          attrs: const {'type': 'application/ld+json'},
          [
            // `<` is escaped so the JSON can never close the script element.
            RawText(
              jsonEncode(organizationJsonLd()).replaceAll('<', r'\u003c'),
            ),
          ],
        ),
      ]),
    ],
  );
}

String _isoDate(DateTime d) => d.toIso8601String().substring(0, 10);
