// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/outbound.dart';
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
  /// Creates the switch for [route].
  const new({
    required this.route,
    required this.content,
    this.inFooter = false,
    super.key,
  });

  /// The current page.
  final Route route;

  /// What the site shows (decides where a post without a translation leads).
  final SiteContent content;

  /// Whether this is the footer's copy of the switch: its landmark needs a
  /// name of its own, since the header holds one too.
  final bool inFooter;

  @override
  Component build(BuildContext context) => nav(
    classes: 'lang-switch',
    attributes: {
      'aria-label': inFooter
          ? chromeText[route.lang]!.langFooterLabel
          : chromeText[route.lang]!.langLabel,
    },
    [
      ul([
        for (final target in Lang.values)
          li([
            a(
              [Component.text(target.code.toUpperCase())],
              href: route.switchPath(target, content),
              attributes: {
                'lang': target.code,
                'hreflang': target.code,
                if (target == route.lang) 'aria-current': 'true',
              },
            ),
          ]),
      ]),
    ],
  );
}

/// The navigation items of the header and the footer, in order: Home, Work
/// (only with a work), Blog (only with a post), About, Contact.
List<({PageKey key, String label})> navItems(Lang lang, SiteContent content) {
  final t = chromeText[lang]!;
  return [
    (key: PageKey.home, label: t.home),
    if (content.hasWorks) (key: PageKey.works, label: t.work),
    if (content.hasPosts) (key: PageKey.blog, label: t.blog),
    (key: PageKey.about, label: t.about),
    (key: PageKey.contact, label: t.contact),
  ];
}

/// The nav item a page belongs to: a work's page to Work, a post's to Blog.
PageKey _section(PageKey key) => switch (key) {
  PageKey.work => PageKey.works,
  PageKey.post => PageKey.blog,
  _ => key,
};

Component _link(
  PageKey key,
  Lang lang,
  String label, {
  required Route current,
}) {
  final here = _section(current.key) == key;
  return li([
    a(
      [Component.text(label)],
      href: pathFor(key, lang),
      // The page itself, or the index a work or a post belongs to.
      attributes: {
        if (here) 'aria-current': current.key == key ? 'page' : 'true',
      },
    ),
  ]);
}

Component _navList(Route route, SiteContent content) => ul([
  for (final item in navItems(route.lang, content))
    _link(item.key, route.lang, item.label, current: route),
]);

/// The site header: horizontal logo lockup, navigation, language switch.
class SiteHeader extends StatelessComponent {
  /// Creates the header of [route].
  const new({required this.route, required this.content, super.key});

  /// The current page.
  final Route route;

  /// What the site shows (decides the navigation items).
  final SiteContent content;

  @override
  Component build(BuildContext context) {
    final lang = route.lang;
    final t = chromeText[lang]!;
    return header(classes: 'site-header', [
      div(classes: 'wrap bar', [
        a(
          href: pathFor(PageKey.home, lang),
          classes: 'brand',
          attributes: {'aria-label': t.homeLabel},
          const [
            // Two renderings of the lockup; CSS shows the one that matches
            // the theme (ink on light, paper on dark), see web/site.css.
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
          [_navList(route, content)],
        ),
        LangSwitch(route: route, content: content),
      ]),
    ]);
  }
}

/// The site footer, text per the brand copy.
class SiteFooter extends StatelessComponent {
  /// Creates the footer of [route].
  const new({required this.route, required this.content, super.key});

  /// The current page.
  final Route route;

  /// What the site shows (decides the navigation items).
  final SiteContent content;

  @override
  Component build(BuildContext context) {
    final lang = route.lang;
    final t = chromeText[lang]!;
    return footer(classes: 'site-footer', [
      div(classes: 'wrap', [
        p(classes: 'tagline', [Component.text(t.tagline)]),
        div(classes: 'footer-links', [
          nav(
            attributes: {'aria-label': t.footerLabel},
            [_navList(route, content)],
          ),
          nav(
            attributes: {'aria-label': t.legalLabel},
            [
              ul([
                _link(PageKey.impressum, lang, t.impressum, current: route),
                _link(PageKey.datenschutz, lang, t.datenschutz, current: route),
              ]),
            ],
          ),
          const p(classes: 'footer-contact', [
            a([Component.text(contactEmail)], href: 'mailto:$contactEmail'),
          ]),
          p(classes: 'footer-contact', [
            a(
              [Component.text(t.linkedin)],
              href: linkedinCompanyUrl,
              attributes: const {'rel': 'noreferrer'},
            ),
          ]),
        ]),
        div(classes: 'bottom', [
          p([Component.text(t.bottom)]),
          LangSwitch(route: route, content: content, inFooter: true),
        ]),
      ]),
    ]);
  }
}
