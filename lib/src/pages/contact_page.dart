// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';
import 'package:website/src/copy/contact_copy.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

/// The contact page body: mailto only, no form.
class ContactPage extends StatelessComponent {
  /// Creates the contact page in [lang].
  const new({required this.lang, super.key});

  /// The page's language.
  final Lang lang;

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
              attributes: const {'style': '--i:1'},
              [t(c.lede)],
            ),
            el(
              'div',
              classes: 'actions rise',
              attrs: const {'style': '--i:2'},
              [const MailButton(label: contactEmail)],
            ),
          ]),
          el(
            'section',
            classes: 'ledger rise',
            attrs: const {'style': '--i:2', 'aria-labelledby': 'include-title'},
            [
              div(classes: 'ledger-head', [
                h2(id: 'include-title', classes: 'ledger-label', [
                  t(c.includeTitle),
                ]),
                const div(classes: 'ledger-fish', [Fish(pose: 'idle')]),
              ]),
              p([t(c.includeIntro)]),
              ul(classes: 'note-list', [
                for (final item in c.include) li([t(item)]),
              ]),
              p(classes: 'note-outro', [t(c.includeOutro)]),
            ],
          ),
        ]),
      ]),
      el(
        'section',
        classes: 'sec sec--first sec--last',
        id: 'next',
        attrs: const {'aria-labelledby': 'next-title'},
        [
          el('div', classes: 'wrap', [
            h2(id: 'next-title', classes: 'sec-h2 reveal', [t(c.nextTitle)]),
            el('div', classes: 'rail-wrap rail-wrap--plain', [
              ol(classes: 'rail reveal', [
                for (var i = 0; i < c.next.length; i++)
                  li(classes: i == 2 ? 'is-call' : null, [t(c.next[i])]),
              ]),
            ]),
            p(classes: 'next-note', [t(c.nextNote)]),
          ]),
        ],
      ),
    ]);
  }
}
