// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/routes.dart';
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
/// workflow, after launch, FAQ, final call to action.
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
      _after(c),
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
          p(
            classes: 'hero-sub rise',
            attributes: const {'style': '--i:2'},
            [t(c.subline)],
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
          const div(classes: 'ledger-fish', [Fish(pose: 'idle')]),
        ]),
        ol(classes: 'route', [
          li(classes: 'route-step is-call', [row('call')]),
          li(classes: 'route-step route-fork', [
            ul([
              li([row('tool', leader: false)]),
              li([row('mvp', leader: false)]),
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
              for (final id in lane.offerIds)
                p([
                  a(
                    [t(offerHeading(_offer(c, id)))],
                    href: '#offer-$id',
                    classes: 'lane-link',
                  ),
                ]),
            ]),
        ]),
      ]),
    ],
  );

  Component _row(Offer o, {bool call = false}) => el(
    'article',
    id: 'offer-${o.id}',
    classes: call ? 'fk-row fk-row--call' : 'fk-row',
    [
      h3(classes: 'fk-head', [
        ...offerSpans(o, nameClass: 'fk-name', priceClass: 'fk-price'),
      ]),
      p(classes: 'fk-text', [t(o.text)]),
    ],
  );

  Component _build(Offer o) =>
      el('article', id: 'offer-${o.id}', classes: 'fk-build', [
        h3(classes: 'fk-head', [
          ...offerSpans(o, nameClass: 'fk-name', priceClass: 'fk-big'),
        ]),
        p(classes: 'fk-text', [t(o.text)]),
      ]);

  Component _offers(HomeCopy c) => el(
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
        el('div', classes: 'fork reveal', [
          _row(_offer(c, 'call'), call: true),
          el('div', classes: 'fk-builds', [
            _build(_offer(c, 'tool')),
            _build(_offer(c, 'mvp')),
          ]),
          _row(_offer(c, 'after')),
        ]),
        p(classes: 'note', [t(c.vatNote)]),
        p(classes: 'note', [t(c.accessibleNote)]),
      ]),
    ],
  );

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

  Component _after(HomeCopy c) => el(
    'section',
    classes: 'sheet',
    id: 'after-launch',
    attrs: const {'aria-labelledby': 'after-title'},
    [
      el('div', classes: 'wrap sheet-grid', [
        h2(id: 'after-title', classes: 'sheet-title reveal', [t(c.afterTitle)]),
        el('div', classes: 'sheet-body reveal', [
          p(classes: 'sheet-lede', [t(c.afterText)]),
          p(classes: 'sheet-note', [t(c.afterNote)]),
          p(classes: 'note', [t(c.vatNote)]),
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
        el(
          'script',
          attrs: const {'type': 'application/ld+json'},
          [
            // `<` is escaped so the JSON can never close the script element.
            RawText(jsonEncode(faqJsonLd(lang)).replaceAll('<', r'\u003c')),
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
