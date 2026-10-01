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
      el('section', classes: 'wrap hero', [
        el('div', classes: 'hero-text', [
          h1(classes: 'rise', [t(c.h1)]),
          p(
            classes: 'lede rise',
            attributes: const {'style': '--i:1'},
            [t(c.lede)],
          ),
        ]),
        // The portrait slot: a fixed-ratio frame. Until a photo exists the
        // idle fish stands in; a photo replaces the `img` inside the figure
        // (object-fit: cover) without any layout change.
        el('figure', classes: 'portrait', [const Fish(pose: 'idle')]),
      ]),
      _section('who', c.whoTitle, [
        for (final para in c.who) p([t(para)]),
      ]),
      _section('one', c.oneTitle, [
        p([t(c.one)]),
      ]),
      _section('how', c.howTitle, [
        ul(classes: 'checks', [
          for (final item in c.how) li([t(item)]),
        ]),
      ]),
      _section('where', c.whereTitle, [
        p([t(c.where)]),
      ]),
      el(
        'section',
        classes: 'wrap section-cta',
        attrs: const {'aria-labelledby': 'cta-title'},
        [
          el('div', classes: 'cta-panel reveal', [
            el('div', classes: 'cta-text', [
              h2(id: 'cta-title', [t(c.ctaTitle)]),
              MailButton(label: writeToKevin[lang]!, inverse: true),
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
