// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';
import 'package:website/src/routes.dart';

/// The id of the `<main>` element the skip link targets.
const mainId = 'main';

/// The first focusable element of every page: jumps to `<main>`.
class SkipLink extends StatelessComponent {
  /// Creates the skip link in [lang].
  const new({required this.lang, super.key});

  /// The page's language.
  final Lang lang;

  @override
  Component build(BuildContext context) => a(
    [Component.text(chromeText[lang]!.skip)],
    href: '#$mainId',
    classes: 'skip',
  );
}

/// The EN / DE switch: each link goes to the same page in that language
/// (from the route table), the current language is `aria-current="true"`.
class LangSwitch extends StatelessComponent {
  /// Creates the switch for [pageKey] in [lang].
  const new({required this.pageKey, required this.lang, super.key});

  /// The current page.
  final PageKey pageKey;

  /// The current language.
  final Lang lang;

  @override
  Component build(BuildContext context) => nav(
    classes: 'lang-switch',
    attributes: {'aria-label': chromeText[lang]!.langLabel},
    [
      ul([
        for (final target in Lang.values)
          li([
            a(
              [Component.text(target.code.toUpperCase())],
              href: pathFor(pageKey, target),
              attributes: {
                'lang': target.code,
                'hreflang': target.code,
                if (target == lang) 'aria-current': 'true',
              },
            ),
          ]),
      ]),
    ],
  );
}

Component _link(
  PageKey key,
  Lang lang,
  String label, {
  required PageKey current,
}) => li([
  a(
    [Component.text(label)],
    href: pathFor(key, lang),
    attributes: {if (key == current) 'aria-current': 'page'},
  ),
]);

/// The site header: horizontal logo lockup (home), navigation, language switch.
class SiteHeader extends StatelessComponent {
  /// Creates the header of [pageKey] in [lang].
  const new({required this.pageKey, required this.lang, super.key});

  /// The current page.
  final PageKey pageKey;

  /// The current language.
  final Lang lang;

  @override
  Component build(BuildContext context) {
    final t = chromeText[lang]!;
    return header(classes: 'site-header', [
      div(classes: 'wrap bar', [
        a(
          href: pathFor(PageKey.home, lang),
          classes: 'brand',
          attributes: {'aria-label': t.homeLabel},
          const [
            // Two renderings of the lockup; CSS shows the one that matches the
            // theme (ink on light, paper on dark), see web/site.css.
            img(
              src: '/brand/logo/svg/lockup-horizontal-ink.svg',
              alt: '',
              classes: 'logo for-light',
              width: 269,
              height: 64,
            ),
            img(
              src: '/brand/logo/svg/lockup-horizontal-paper.svg',
              alt: '',
              classes: 'logo for-dark',
              width: 269,
              height: 64,
            ),
          ],
        ),
        nav(
          classes: 'primary',
          attributes: {'aria-label': t.navLabel},
          [
            ul([
              _link(PageKey.home, lang, t.home, current: pageKey),
              _link(PageKey.about, lang, t.about, current: pageKey),
              _link(PageKey.contact, lang, t.contact, current: pageKey),
            ]),
          ],
        ),
        LangSwitch(pageKey: pageKey, lang: lang),
      ]),
    ]);
  }
}

/// The site footer, text per the brand copy.
class SiteFooter extends StatelessComponent {
  /// Creates the footer of [pageKey] in [lang].
  const new({required this.pageKey, required this.lang, super.key});

  /// The current page.
  final PageKey pageKey;

  /// The current language.
  final Lang lang;

  @override
  Component build(BuildContext context) {
    final t = chromeText[lang]!;
    return footer(classes: 'site-footer', [
      div(classes: 'wrap', [
        p(classes: 'tagline', [Component.text(t.tagline)]),
        div(classes: 'footer-links', [
          nav(
            attributes: {'aria-label': t.footerLabel},
            [
              ul([
                _link(PageKey.home, lang, t.home, current: pageKey),
                _link(PageKey.about, lang, t.about, current: pageKey),
                _link(PageKey.contact, lang, t.contact, current: pageKey),
              ]),
            ],
          ),
          nav(
            attributes: {'aria-label': t.legalLabel},
            [
              ul([
                _link(PageKey.impressum, lang, t.impressum, current: pageKey),
                _link(
                  PageKey.datenschutz,
                  lang,
                  t.datenschutz,
                  current: pageKey,
                ),
              ]),
            ],
          ),
          const p(classes: 'footer-contact', [
            a([Component.text(contactEmail)], href: 'mailto:$contactEmail'),
          ]),
        ]),
        div(classes: 'bottom', [
          p([Component.text(t.bottom)]),
          LangSwitch(pageKey: pageKey, lang: lang),
        ]),
      ]),
    ]);
  }
}

/// The home hero: the logo sting, the headline with its drawn underline and
/// the contact button. Placeholder copy until the home content lands (#10).
class Hero extends StatelessComponent {
  /// Creates the hero with [headline].
  const new({required this.headline, super.key});

  /// The H1 text; all of it is the underlined key phrase for now.
  final String headline;

  @override
  Component build(BuildContext context) => div(classes: 'hero', [
    // The still, per theme (paper in light, ink in dark). `sting.js` hides it
    // and inserts the animated SVG on arrival (no same-origin referrer).
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
    h1(classes: 'rise', [
      span(classes: 'mark', [Component.text(headline)]),
    ]),
    const p(
      classes: 'rise',
      attributes: {'style': '--i:1'},
      [
        span(classes: 'btn-wrap', [
          a(
            [Component.text(contactEmail)],
            href: 'mailto:$contactEmail',
            classes: 'btn',
          ),
        ]),
      ],
    ),
  ]);
}
