// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/copy/about_copy.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

/// The about page body: hero, the founder with the portrait, one person, the
/// studio's own software, how the studio works, where, closing call to
/// action.
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
        ]),
      ]),
      el(
        'section',
        classes: 'sec sec--first',
        attrs: const {'aria-labelledby': 'who-title'},
        [
          el('div', classes: 'wrap split', [
            el('div', classes: 'split-head', [
              h2(id: 'who-title', classes: 'split-h2 reveal', [t(c.whoTitle)]),
              _portrait(c),
            ]),
            el('div', classes: 'split-body reveal', [
              for (var i = 0; i < c.who.length; i++)
                p(classes: i == 0 ? 'split-lede' : null, [t(c.who[i])]),
              p(classes: 'links-line', [
                t('${c.linksIntro} '),
                for (var i = 0; i < c.links.length; i++) ...[
                  if (i > 0) t(' · '),
                  ...inlineLinks(c.links[i]),
                ],
              ]),
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
        classes: 'sheet sheet--after-band',
        attrs: const {'aria-labelledby': 'own-title'},
        [
          el('div', classes: 'wrap sheet-grid', [
            h2(id: 'own-title', classes: 'sheet-title reveal', [t(c.ownTitle)]),
            el('div', classes: 'sheet-body reveal', [
              p(classes: 'sheet-lede', [t(c.own)]),
              p(inlineLinks(c.ownCode)),
            ]),
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
            ul(classes: 'ticks ticks--even reveal', [
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

  /// The founder's portrait: the web copy without metadata (JPEG and WebP at
  /// 280, 420 and 560 px wide) in the frame that carries the chamfer.
  Component _portrait(AboutCopy c) {
    const sizes = '(min-width: 64rem) 280px, (min-width: 48rem) 240px, 192px';
    String set(String ext) =>
        [for (final w in portraitWidths) '/img/kevin-scheeren-$w.$ext ${w}w']
            .join(', ');
    return el(
      'figure',
      classes: 'founder-photo reveal',
      attrs: const {'data-i': '1'},
      [
        el('picture', [
          el(
            'source',
            const [],
            attrs: {
              'type': 'image/webp',
              'srcset': set('webp'),
              'sizes': sizes,
            },
          ),
          img(
            src: '/img/kevin-scheeren-$portraitWidth.jpg',
            alt: c.photoAlt,
            width: portraitWidth,
            height: portraitHeight,
            attributes: {
              'srcset': set('jpg'),
              'sizes': sizes,
              'loading': 'lazy',
              'decoding': 'async',
            },
          ),
        ]),
      ],
    );
  }
}

/// The widths of the portrait files in `web/img/`; the last is the largest.
const portraitWidths = [280, 420, 560];

/// The width of the largest portrait file.
const portraitWidth = 560;

/// The height of the largest portrait file (3:4).
const portraitHeight = 747;
