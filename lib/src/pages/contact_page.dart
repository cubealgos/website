// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';
import 'package:website/src/copy/contact_copy.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

/// The contact page body: mailto only, no form. Collaboration, integrations,
/// grants and press at hello@; vulnerability reports at security@.
class ContactPage extends StatelessComponent {
  /// Creates the contact page in [lang]. [productNamed] is whether the topics
  /// name wearenotabank (the site's [namesProduct]).
  const new({required this.lang, this.productNamed = namesProduct, super.key});

  /// The page's language.
  final Lang lang;

  /// Whether the topics name wearenotabank.
  final bool productNamed;

  @override
  Component build(BuildContext context) {
    final c = contactCopy[lang]!;
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
            el(
              'div',
              classes: 'actions rise',
              attrs: const {'data-i': '2'},
              [const MailButton(label: contactEmail)],
            ),
            p(
              classes: 'note rise',
              attributes: const {'data-i': '3'},
              [t(c.note)],
            ),
          ]),
          el(
            'section',
            classes: 'ledger rise',
            attrs: const {'data-i': '2', 'aria-labelledby': 'topics-title'},
            [
              div(classes: 'ledger-head', [
                h2(id: 'topics-title', classes: 'ledger-label', [
                  t(c.topicsTitle),
                ]),
                const div(classes: 'ledger-fish', [Fish(pose: 'idle')]),
              ]),
              ul(classes: 'note-list topic-list', [
                for (final topic in contactTopics(lang, named: productNamed))
                  li([
                    strong([t(topic.lead)]),
                    ...noHyphen(' ${topic.text}'),
                  ]),
              ]),
            ],
          ),
        ]),
      ]),
      el(
        'section',
        classes: 'sec sec--first sec--last',
        attrs: const {'aria-labelledby': 'security-title'},
        [
          div(classes: 'wrap split', [
            h2(id: 'security-title', classes: 'split-h2 reveal', [
              t(c.securityTitle),
            ]),
            div(classes: 'split-body reveal', [
              p(classes: 'split-lede', inlineLinks(c.security)),
            ]),
          ]),
        ],
      ),
    ]);
  }
}
