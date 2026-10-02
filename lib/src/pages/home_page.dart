// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';
import 'package:website/src/sting.dart';
import 'package:website/src/widgets.dart';

/// The `FAQPage` JSON-LD of [lang], generated from the same data as the
/// visible FAQ.
Map<String, Object> faqJsonLd(Lang lang) => {
  '@context': 'https://schema.org',
  '@type': 'FAQPage',
  'mainEntity': [
    for (final q in homeCopy[lang]!.faq)
      {
        '@type': 'Question',
        'name': q.question,
        'acceptedAnswer': {'@type': 'Answer', 'text': q.answer},
      },
  ],
};

/// The home page body: hero with the stack card, the studio's own software,
/// client projects, the studio facts, FAQ, final call to action.
class HomePage extends StatelessComponent {
  /// Creates the home page in [lang].
  const new({required this.lang, super.key});

  /// The page's language.
  final Lang lang;

  @override
  Component build(BuildContext context) {
    final c = homeCopy[lang]!;
    return Component.fragment([
      _hero(c),
      _own(c),
      _projects(c),
      _studio(c),
      _faq(c),
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
              MailButton(label: startProject[lang]!),
              a(
                [t(c.secondaryCta)],
                href: '#${c.ownAnchor}',
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
  /// line, the free first call last, the note on client projects beneath. The
  /// mark sting plays in the card head.
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
          for (var i = 0; i < c.stack.length; i++)
            div(classes: i == c.stack.length - 1 ? 'is-call' : null, [
              dt([t(c.stack[i].label)]),
              dd([t(c.stack[i].value)]),
            ]),
        ]),
      ],
    ),
    el(
      'p',
      classes: 'note stack-note rise',
      attrs: const {'data-i': '3'},
      [t(c.stackNote)],
    ),
  ]);

  Component _own(HomeCopy c) => el(
    'section',
    classes: 'band',
    id: c.ownAnchor,
    attrs: const {'aria-labelledby': 'own-title'},
    [
      el('div', classes: 'wrap band-grid', [
        h2(id: 'own-title', classes: 'band-title reveal', [t(c.ownTitle)]),
        p(
          classes: 'band-text reveal',
          attributes: const {'data-i': '1'},
          [t(c.ownText)],
        ),
      ]),
    ],
  );

  Component _projects(HomeCopy c) => el(
    'section',
    classes: 'sec projects',
    id: c.projectsAnchor,
    attrs: const {'aria-labelledby': 'projects-title'},
    [
      el('div', classes: 'wrap', [
        el('div', classes: 'sec-head reveal', [
          h2(id: 'projects-title', [t(c.projectsTitle)]),
          p(classes: 'measure', [t(c.projectsIntro)]),
        ]),
        el('div', classes: 'lanes lanes--eg', [
          for (var i = 0; i < c.lanes.length; i++)
            el(
              'div',
              classes: 'lane reveal',
              attrs: {'data-i': '$i'},
              [
                h3([t(c.lanes[i].title)]),
                p([t(c.lanes[i].text)]),
                div(classes: 'lane-eg', [
                  p(classes: 'eyebrow-muted', [t(c.examplesLabel)]),
                  ul(classes: 'eg-list', [
                    for (final e in c.lanes[i].examples) li([t(e)]),
                  ]),
                ]),
              ],
            ),
        ]),
        el('div', classes: 'route-block', [
          h3(classes: 'reveal', [t(c.routeTitle)]),
          el('div', classes: 'rail-wrap', [
            ol(classes: 'rail reveal', [
              for (var i = 0; i < c.steps.length; i++)
                li(classes: i == 0 ? 'is-call' : null, [
                  strong([t(c.steps[i].title)]),
                  t(' ${c.steps[i].text}'),
                ]),
            ]),
            const div(classes: 'rail-fish', [Fish(pose: 'swimming')]),
          ]),
          el('div', classes: 'route-close reveal', [
            MailButton(label: startProject[lang]!),
            p(classes: 'note', [t(c.routeNote)]),
          ]),
        ]),
      ]),
    ],
  );

  Component _studio(HomeCopy c) => el(
    'section',
    classes: 'sheet studio-sheet',
    attrs: const {'aria-labelledby': 'studio-title'},
    [
      el('div', classes: 'wrap sheet-grid', [
        h2(id: 'studio-title', classes: 'sheet-title reveal', [
          t(c.studioTitle),
        ]),
        ul(classes: 'studio-items', [
          for (var i = 0; i < c.studio.length; i++)
            li(
              classes: 'reveal',
              attributes: {'data-i': '${i < 5 ? i : 5}'},
              [
                strong([t(c.studio[i].lead)]),
                t(' '),
                ...inlineLinks(c.studio[i].text),
                if (c.studio[i].aside case final aside?) ...[
                  t(' '),
                  ...inlineLinks(aside, linkClass: 'item-link'),
                ],
              ],
            ),
        ]),
      ]),
    ],
  );

  Component _faq(HomeCopy c) => el(
    'section',
    classes: 'sec',
    attrs: const {'aria-labelledby': 'faq-title'},
    [
      el('div', classes: 'wrap faq-grid', [
        h2(id: 'faq-title', classes: 'reveal', [t(c.faqTitle)]),
        el('div', classes: 'faq', [
          for (final q in c.faq)
            details(classes: 'reveal', [
              summary([t(q.question)]),
              p([t(q.answer)]),
            ]),
        ]),
        for (final data in [faqJsonLd(lang), organizationJsonLd()])
          el(
            'script',
            attrs: const {'type': 'application/ld+json'},
            [
              // `<` is escaped so the JSON can never close the script element.
              RawText(jsonEncode(data).replaceAll('<', r'\u003c')),
            ],
          ),
      ]),
    ],
  );

  Component _cta(HomeCopy c) => el(
    'section',
    classes: 'cta-sec',
    attrs: const {'aria-labelledby': 'cta-title'},
    [
      el('div', classes: 'wrap', [
        el('div', classes: 'cta reveal', [
          el('div', classes: 'cta-text', [
            h2(id: 'cta-title', [t(c.ctaTitle)]),
            p([t(c.ctaText)]),
            MailButton(label: c.ctaButton, inverse: true),
          ]),
          const div(classes: 'cta-fish', [Fish(pose: 'happy', onAmber: true)]),
        ]),
      ]),
    ],
  );
}
