// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';
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

/// The mark-only sting, read from the vendored brand files at build time (so
/// `brand_sync --check` covers it) and inlined: its mark is `currentColor` and
/// its echo `var(--color-accent-fill)`, so it follows the theme. It sits in
/// the offer card, which labels itself, so the SVG is decorative.
final String _stingMark = File('web/brand/sting/sting-mark.svg')
    .readAsStringSync()
    .replaceFirst(RegExp(r'\s*<title>.*?</title>'), '')
    .replaceFirst(
      'role="img" aria-label="Cube Algos logo"',
      'aria-hidden="true" focusable="false"',
    );

/// The heading of an offer: `name, price`.
String offerHeading(Offer o) => '${o.name}, ${o.price}';

/// `name, price` as separate spans joined by a visually hidden `", "`, so the
/// text still reads `name, price` while the price can be styled on its own.
List<Component> offerSpans(
  Offer o, {
  required String nameClass,
  required String priceClass,
}) => [
  span(classes: nameClass, [t(o.name)]),
  span(classes: 'vh', [t(', ')]),
  span(classes: '$priceClass num', [t(o.price)]),
];

/// The home page body: hero with the price ledger, studio band, lanes, offers,
/// workflow, FAQ, final call to action.
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
      _studio(c),
      _lanes(c),
      _offers(c),
      _workflow(c),
      _faq(c),
      _cta(c),
    ]);
  }

  Offer _offer(HomeCopy c, String id) => c.offers.firstWhere((o) => o.id == id);

  Component _hero(HomeCopy c) {
    final at = c.h1.indexOf(c.h1Mark);
    assert(at >= 0, 'h1Mark must be part of h1');
    return el('section', classes: 'hero', [
      el('div', classes: 'wrap hero-grid gridlines', [
        el('div', classes: 'hero-text', [
          p(classes: 'eyebrow rise', [t(c.eyebrow)]),
          h1(
            classes: 'rise hero-h1',
            attributes: const {'style': '--i:1'},
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
            attributes: const {'style': '--i:2'},
            [
              p(classes: 'hero-sub hero-sub--full', [t(c.subline)]),
              p(classes: 'hero-sub hero-sub--short', [t(c.sublineShort)]),
            ],
          ),
          el(
            'div',
            classes: 'actions rise',
            attrs: const {'style': '--i:3'},
            [
              MailButton(label: startProject[lang]!),
              a([t(c.secondaryCta)], href: '#offers', classes: 'text-link'),
            ],
          ),
        ]),
        _ledger(c),
      ]),
    ]);
  }

  /// The price ledger beside the headline: the offer as a route (free call,
  /// one of two builds, after launch), every row linking to its detail.
  Component _ledger(HomeCopy c) {
    Component row(String id, {bool leader = true}) {
      final o = _offer(c, id);
      return a(href: '#offer-$id', [
        span(classes: 'r-name', [t(o.name)]),
        span(classes: 'vh', [t(', ')]),
        if (leader)
          const span(
            classes: 'r-dots',
            attributes: {'aria-hidden': 'true'},
            [],
          ),
        span(classes: 'r-price num', [t(o.price)]),
      ]);
    }

    return el(
      'aside',
      classes: 'ledger rise',
      attrs: const {'style': '--i:2', 'aria-labelledby': 'ledger-label'},
      [
        div(classes: 'ledger-head', [
          p(id: 'ledger-label', classes: 'eyebrow-muted', [t(c.offersTitle)]),
          div(classes: 'ledger-mark', [RawText(_stingMark)]),
        ]),
        ol(classes: 'route', [
          li(classes: 'route-step is-call', [row('call')]),
          li(classes: 'route-step route-fork', [
            ul([
              li([row('apps', leader: false)]),
              li([row('automation', leader: false)]),
            ]),
          ]),
          li(classes: 'route-step', [row('after')]),
        ]),
        p(classes: 'note', [t(c.vatNote)]),
      ],
    );
  }

  Component _studio(HomeCopy c) => el(
    'section',
    classes: 'band',
    attrs: const {'aria-labelledby': 'studio-title'},
    [
      el('div', classes: 'wrap band-grid', [
        h2(id: 'studio-title', classes: 'band-title reveal', [
          t(c.studioTitle),
        ]),
        p(
          classes: 'band-text reveal',
          attributes: const {'style': '--i:1'},
          [t(c.studioText)],
        ),
      ]),
    ],
  );

  Component _lanes(HomeCopy c) => el(
    'section',
    classes: 'sec',
    attrs: const {'aria-labelledby': 'lanes-title'},
    [
      el('div', classes: 'wrap', [
        h2(id: 'lanes-title', classes: 'sec-h2 reveal', [t(c.lanesTitle)]),
        el('div', classes: 'lanes', [
          for (final lane in c.lanes)
            el('div', classes: 'lane reveal', [
              h3([t(lane.title)]),
              p([t(lane.text)]),
              p([
                a(
                  [t(lane.link)],
                  href: '#offer-${lane.offerId}',
                  classes: 'lane-link',
                ),
              ]),
            ]),
        ]),
      ]),
    ],
  );

  Component _offers(HomeCopy c) {
    final call = _offer(c, 'call');
    Component row(Offer o) => li(id: 'offer-${o.id}', classes: 'pc-row', [
      h3(classes: 'pc-head', [
        ...offerSpans(o, nameClass: 'pc-name', priceClass: 'pc-price'),
      ]),
      p([t(o.text)]),
      if (o.examples.isNotEmpty)
        ul(classes: 'pc-eg', [
          for (final e in o.examples)
            li([
              span([t(e.label)]),
              // The dot travels with the price, never dangling at a line end.
              t(' '),
              span(classes: 'num', [t('· ${e.price}')]),
            ]),
        ]),
    ]);

    return el(
      'section',
      classes: 'sec',
      id: 'offers',
      attrs: const {'aria-labelledby': 'offers-title'},
      [
        el('div', classes: 'wrap', [
          el('div', classes: 'sec-head reveal', [
            h2(id: 'offers-title', [t(c.offersTitle)]),
            p(classes: 'measure', [t(c.offersIntro)]),
          ]),
          el('div', classes: 'pc-grid reveal', [
            el('article', id: 'offer-call', classes: 'pc-card', [
              h3(classes: 'pc-head', [
                span(classes: 'pc-name pc-node', [t(call.name)]),
                span(classes: 'vh', [t(', ')]),
                span(classes: 'pc-free num', [t(call.price)]),
              ]),
              p([t(call.text)]),
            ]),
            div([
              ul(classes: 'pc-list', [
                row(_offer(c, 'apps')),
                row(_offer(c, 'automation')),
                row(_offer(c, 'after')),
              ]),
              p(classes: 'note', [t('${c.vatNote} · ${c.accessibleNote}')]),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _workflow(HomeCopy c) => el(
    'section',
    classes: 'sec',
    attrs: const {'aria-labelledby': 'workflow-title'},
    [
      el('div', classes: 'wrap', [
        h2(id: 'workflow-title', classes: 'sec-h2 reveal', [
          t(c.workflowTitle),
        ]),
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
