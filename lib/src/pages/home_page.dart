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

/// The heading of an offer card: `name, price`.
String offerHeading(Offer o) => '${o.name}, ${o.price}';

/// The home page body: hero, two lanes, offers, workflow, care, FAQ, final
/// call to action.
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
      _lanes(c),
      _offers(c),
      _workflow(c),
      _care(c),
      _faq(c),
      _cta(c),
    ]);
  }

  Component _hero(HomeCopy c) {
    final at = c.h1.indexOf(c.h1Mark);
    assert(at >= 0, 'h1Mark must be part of h1');
    return el('section', classes: 'wrap hero', [
      el('div', classes: 'hero-text', [
        // The still, per theme (paper in light, ink in dark). `sting.js` hides
        // it and inserts the animated SVG on arrival (no same-origin referrer).
        const div(
          classes: 'sting',
          attributes: {'data-sting': ''},
          [
            img(
              src: '/brand/sting/sting-paper-still.svg',
              alt: '',
              classes: 'sting-still for-light',
              width: 325,
              height: 120,
            ),
            img(
              src: '/brand/sting/sting-ink-still.svg',
              alt: '',
              classes: 'sting-still for-dark',
              width: 325,
              height: 120,
            ),
          ],
        ),
        p(classes: 'eyebrow rise', [t(c.eyebrow)]),
        h1(
          classes: 'rise',
          attributes: const {'style': '--i:1'},
          [
            t(c.h1.substring(0, at)),
            span(classes: 'mark', [t(c.h1Mark)]),
            t(c.h1.substring(at + c.h1Mark.length)),
          ],
        ),
        p(
          classes: 'subline rise',
          attributes: const {'style': '--i:2'},
          [t(c.subline)],
        ),
        el(
          'div',
          classes: 'actions rise',
          attrs: const {'style': '--i:3'},
          [
            MailButton(label: writeEmail[lang]!),
            a([t(c.secondaryCta)], href: '#offers', classes: 'text-link'),
          ],
        ),
      ]),
      const div(classes: 'hero-fish', [Fish(pose: 'idle')]),
    ]);
  }

  Component _lanes(HomeCopy c) => el(
    'section',
    classes: 'section',
    attrs: const {'aria-labelledby': 'lanes-title'},
    [
      el('div', classes: 'wrap', [
        h2(id: 'lanes-title', classes: 'reveal', [t(c.lanesTitle)]),
        el('div', classes: 'lanes', [
          for (final lane in c.lanes)
            el('div', classes: 'card lane reveal', [
              h3([t(lane.title)]),
              p([t(lane.text)]),
              ul(classes: 'lane-links', [
                for (final id in lane.offerIds)
                  li([
                    a([
                      t(offerHeading(c.offers.firstWhere((o) => o.id == id))),
                    ], href: '#offer-$id'),
                  ]),
              ]),
            ]),
        ]),
      ]),
    ],
  );

  Component _offers(HomeCopy c) => el(
    'section',
    classes: 'section',
    id: 'offers',
    attrs: const {'aria-labelledby': 'offers-title'},
    [
      el('div', classes: 'wrap', [
        h2(id: 'offers-title', classes: 'reveal', [t(c.offersTitle)]),
        p(classes: 'intro reveal', [t(c.offersIntro)]),
        ul(classes: 'offers', [
          for (final o in c.offers)
            li(id: 'offer-${o.id}', classes: 'card offer reveal', [
              h3([
                span(classes: 'offer-name', [t('${o.name},')]),
                t(' '),
                span(classes: 'offer-price', [t(o.price)]),
              ]),
              p([t(o.text)]),
            ]),
        ]),
        p(classes: 'note', [t(c.vatNote)]),
        p(classes: 'note', [t(c.accessibleNote)]),
      ]),
    ],
  );

  Component _workflow(HomeCopy c) => el(
    'section',
    classes: 'section',
    attrs: const {'aria-labelledby': 'workflow-title'},
    [
      el('div', classes: 'wrap split', [
        el('div', [
          h2(id: 'workflow-title', classes: 'reveal', [t(c.workflowTitle)]),
          ol(classes: 'steps', [
            for (final s in c.steps)
              li(classes: 'reveal', [
                strong([t(s.title)]),
                t(' ${s.text}'),
              ]),
          ]),
        ]),
        const div(classes: 'split-fish', [Fish(pose: 'swimming')]),
      ]),
    ],
  );

  Component _care(HomeCopy c) => el(
    'section',
    classes: 'section',
    attrs: const {'aria-labelledby': 'care-title'},
    [
      el('div', classes: 'wrap', [
        h2(id: 'care-title', classes: 'reveal', [t(c.careTitle)]),
        p([t(c.careText)]),
        ul(classes: 'plans', [
          for (final plan in c.carePlans)
            li(classes: 'card reveal', [
              strong([t(plan)]),
            ]),
        ]),
        p([t(c.carePlansNote)]),
        p(classes: 'note', [t(c.vatNote)]),
      ]),
    ],
  );

  Component _faq(HomeCopy c) => el(
    'section',
    classes: 'section',
    attrs: const {'aria-labelledby': 'faq-title'},
    [
      el('div', classes: 'wrap', [
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
    classes: 'wrap section-cta',
    attrs: const {'aria-labelledby': 'cta-title'},
    [
      el('div', classes: 'cta-panel reveal', [
        el('div', classes: 'cta-text', [
          h2(id: 'cta-title', [t(c.ctaTitle)]),
          p([t(c.ctaText)]),
          MailButton(label: c.ctaButton, inverse: true),
        ]),
        const div(classes: 'cta-fish', [Fish(pose: 'happy', onAmber: true)]),
      ]),
    ],
  );
}
