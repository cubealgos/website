// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/copy/about_copy.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

/// The about page body: hero with the portrait slot, the founder, one person,
/// how the studio works, where, closing call to action.
class AboutPage extends StatelessComponent {
  /// Creates the about page in [lang].
  const new({required this.lang, super.key});

  /// The page's language.
  final Lang lang;

  @override
  Component build(BuildContext context) {
    final c = aboutCopy[lang]!;
    return Component.fragment([
      el('section', classes: 'hero hero--page', [
        el('div', classes: 'wrap hero-grid gridlines', [
          el('div', classes: 'hero-text', [
            h1(classes: 'hero-h1 rise', [t(c.h1)]),
            p(
              classes: 'hero-sub rise',
              attributes: const {'data-i': '1'},
              [t(c.lede)],
            ),
          ]),
          // The portrait slot: a fixed-ratio frame. Until a photo exists the
          // idle fish stands in; a photo replaces the `img` inside the figure
          // (object-fit: cover) without any layout change.
          el(
            'figure',
            classes: 'portrait rise',
            attrs: const {'data-i': '2'},
            [const Fish(pose: 'idle')],
          ),
        ]),
      ]),
      el(
        'section',
        classes: 'sec sec--first',
        attrs: const {'aria-labelledby': 'who-title'},
        [
          el('div', classes: 'wrap split', [
            h2(id: 'who-title', classes: 'split-h2 reveal', [t(c.whoTitle)]),
            el('div', classes: 'split-body reveal', [
              for (var i = 0; i < c.who.length; i++)
                p(classes: i == 0 ? 'split-lede' : null, [t(c.who[i])]),
            ]),
          ]),
        ],
      ),
      el(
        'section',
        classes: 'band',
        attrs: const {'aria-labelledby': 'one-title'},
        [
          el('div', classes: 'wrap band-grid', [
            h2(id: 'one-title', classes: 'band-title reveal', [t(c.oneTitle)]),
            p(
              classes: 'band-text reveal',
              attributes: const {'data-i': '1'},
              [t(c.one)],
            ),
          ]),
        ],
      ),
      el(
        'section',
        classes: 'sec',
        attrs: const {'aria-labelledby': 'how-title'},
        [
          el('div', classes: 'wrap', [
            h2(id: 'how-title', classes: 'sec-h2 reveal', [t(c.howTitle)]),
            ul(classes: 'ticks reveal', [
              for (final item in c.how) li([t(item)]),
            ]),
          ]),
        ],
      ),
      el(
        'section',
        classes: 'sheet',
        attrs: const {'aria-labelledby': 'where-title'},
        [
          el('div', classes: 'wrap sheet-grid', [
            h2(id: 'where-title', classes: 'sheet-title reveal', [
              t(c.whereTitle),
            ]),
            el('div', classes: 'sheet-body reveal', [
              p(classes: 'sheet-lede', [t(c.where)]),
            ]),
          ]),
        ],
      ),
      el(
        'section',
        classes: 'cta-sec cta-sec--gap',
        attrs: const {'aria-labelledby': 'cta-title'},
        [
          el('div', classes: 'wrap', [
            el('div', classes: 'cta cta--slim reveal', [
              el('div', classes: 'cta-text', [
                h2(id: 'cta-title', [t(c.ctaTitle)]),
                MailButton(label: writeToKevin[lang]!, inverse: true),
              ]),
            ]),
          ]),
        ],
      ),
    ]);
  }
}
