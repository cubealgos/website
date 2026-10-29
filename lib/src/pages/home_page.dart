// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/legal_facts.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';
import 'package:website/src/sting.dart';
import 'package:website/src/widgets.dart';

/// The home page body: the business card, layout B "Steckbrief". Beside the
/// statement (eyebrow, H1, paragraph and the one button) sits the fact sheet
/// on the ledger card: provider, register entry, product, contact and the
/// newest post, with the Impressum link under it.
class HomePage extends StatelessComponent {
  /// Creates the home page in [lang] showing [content]. [productNamed] is
  /// whether the page names wearenotabank (the site's [namesProduct]).
  const new({
    required this.lang,
    required this.content,
    this.productNamed = namesProduct,
    super.key,
  });

  /// The page's language.
  final Lang lang;

  /// The posts of the site.
  final SiteContent content;

  /// Whether the H1, the button and the Produkt row name wearenotabank.
  final bool productNamed;

  @override
  Component build(BuildContext context) {
    final c = homeCopy[lang]!;
    return Component.fragment([
      el('div', classes: 'wrap gridlines bc-grid', [_statement(c), _sheet(c)]),
      el(
        'script',
        attrs: const {'type': 'application/ld+json'},
        [
          // `<` is escaped so the JSON can never close the script element.
          RawText(
            jsonEncode(organizationJsonLd(productNamed: productNamed))
                .replaceAll('<', r'\u003c'),
          ),
        ],
      ),
    ]);
  }

  /// The statement: eyebrow, H1, the paragraph that names the object, and the
  /// action row.
  Component _statement(HomeCopy c) {
    final h1Copy = homeHeadline(lang, named: productNamed);
    return el('div', classes: 'b-text', [
      p(classes: 'eyebrow rise', [t(c.eyebrow)]),
      h1(
        classes: 'bc-h1 rise',
        attributes: const {'data-i': '1'},
        [
          t(h1Copy.pre),
          span(classes: 'mark $noHyphenClass', [t(h1Copy.mark)]),
          t(h1Copy.post),
        ],
      ),
      p(
        classes: 'bc-lede rise',
        attributes: const {'data-i': '2'},
        noHyphen(c.lede),
      ),
      el(
        'div',
        classes: 'actions rise',
        attrs: const {'data-i': '3'},
        [
          if (productNamed) ...[
            span(classes: 'btn-wrap', [
              a(
                [...noHyphen(c.productButton), const _ExternalMark()],
                href: wearenotabankOrgUrl,
                classes: 'btn',
                attributes: const {'rel': 'noreferrer'},
              ),
            ]),
            a(
              [t(c.contactLink)],
              href: pathFor(PageKey.contact, lang),
              classes: 'text-link',
            ),
          ] else
            LinkButton(
              label: c.contactLink,
              href: pathFor(PageKey.contact, lang),
            ),
        ],
      ),
    ]);
  }

  /// The fact sheet: label and value rows on the route line, the mark sting in
  /// its head.
  Component _sheet(HomeCopy c) {
    final post = content.newestPostFor(lang);
    return el(
      'section',
      classes: 'ledger b-sheet rise',
      attrs: const {'data-i': '2', 'aria-labelledby': 'sheet-label'},
      [
        div(classes: 'ledger-head', [
          h2(id: 'sheet-label', classes: 'ledger-label', [t(c.sheetTitle)]),
          div(classes: 'ledger-mark', [RawText(stingSvg())]),
        ]),
        dl(classes: 'stack', [
          _row(c.providerLabel, [t('$companyName, $addressPlace')]),
          _row(c.registerLabel, [
            t('$registerCourt, '),
            span(classes: 'nobr', [t(registerNumber)]),
          ]),
          if (productNamed)
            // In a span: the renderer lays out an inline parent's content on
            // one line, so no space sits between the name and the arrow
            // (inside the link it would be underlined).
            _row(c.productLabel, [
              span([
                a(
                  [...noHyphen(c.product), const _ExternalMark()],
                  href: wearenotabankOrgUrl,
                  attributes: const {'rel': 'noreferrer'},
                ),
              ]),
            ]),
          _row(c.contactLabel, [
            a([t(email)], href: 'mailto:$email'),
          ]),
          if (post != null)
            _row(c.blogLabel, [
              a(
                [t(post.title)],
                href: routePath(PageKey.post, post.lang, post.slug),
                attributes: {
                  if (post.lang != lang) ...{
                    'lang': post.lang.code,
                    'hreflang': post.lang.code,
                  },
                },
              ),
            ]),
        ]),
        p(classes: 'b-sheet-foot', [
          a([
            t(chromeText[lang]!.impressum),
          ], href: pathFor(PageKey.impressum, lang)),
        ]),
      ],
    );
  }

  Component _row(String label, List<Component> value) => div([
    dt([t(label)]),
    dd(value),
  ]);
}

/// The small diagonal arrow after a link that leaves the site. Decoration:
/// the link's text already says where it goes.
class _ExternalMark extends StatelessComponent {
  const new();

  @override
  Component build(BuildContext context) => const RawText(
    '<svg class="ext" viewBox="0 0 12 12" aria-hidden="true" '
    'focusable="false"><path d="M3 1h8v8M11 1 1 11" fill="none" '
    'stroke="currentColor" stroke-width="2"/></svg>',
  );
}
