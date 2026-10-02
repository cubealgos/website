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
    final at = c.details.indexOf(contactEmail);
    assert(at >= 0, 'details must contain the address');
    return Component.fragment([
      el('section', classes: 'wrap hero', [
        el('div', classes: 'hero-text', [
          h1(classes: 'rise', [t(c.h1)]),
          p(
            classes: 'lede rise',
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
        const div(classes: 'hero-fish', [Fish(pose: 'idle')]),
      ]),
      _section('include', c.includeTitle, [
        p([t(c.includeIntro)]),
        ul(classes: 'checks', [
          for (final item in c.include) li([t(item)]),
        ]),
        p([t(c.includeOutro)]),
      ]),
      _section('next', c.nextTitle, [
        ol(classes: 'steps', [
          for (final step in c.next) li([t(step)]),
        ]),
        p(classes: 'after-steps', [t(c.nextNote)]),
      ]),
      el(
        'section',
        classes: 'section',
        attrs: const {'aria-label': 'Details'},
        [
          el('div', classes: 'wrap prose', [
            p(classes: 'details reveal', [
              t(c.details.substring(0, at)),
              a([t(contactEmail)], href: 'mailto:$contactEmail'),
              t(c.details.substring(at + contactEmail.length)),
            ]),
          ]),
        ],
      ),
    ]);
  }

  Component _reveal(Component block) => el('div', classes: 'reveal', [block]);

  Component _section(String id, String title, List<Component> body) => el(
    'section',
    classes: 'section',
    attrs: {'aria-labelledby': '$id-title'},
    [
      el('div', classes: 'wrap prose', [
        h2(id: '$id-title', classes: 'reveal', [t(title)]),
        for (final block in body) _reveal(block),
      ]),
    ],
  );
}
