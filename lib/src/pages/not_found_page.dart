// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';
import 'package:website/src/copy/not_found_copy.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

/// The 404 body: the confused fish, the headline, a line of help and two
/// actions. Every URL here is root-absolute, so the page works when the server
/// answers an unknown path from any depth with it.
class NotFoundPage extends StatelessComponent {
  /// Creates the 404 page in [lang].
  const new({required this.lang, super.key});

  /// The page's language.
  final Lang lang;

  @override
  Component build(BuildContext context) {
    final c = notFoundCopy[lang]!;
    return el('section', classes: 'wrap hero', [
      el('div', classes: 'hero-text', [
        h1(classes: 'rise', [t(c.headline)]),
        p(
          classes: 'lede rise',
          attributes: const {'style': '--i:1'},
          [t(c.body)],
        ),
        el(
          'div',
          classes: 'actions rise',
          attrs: const {'style': '--i:2'},
          [
            LinkButton(label: c.homeAction, href: pathFor(PageKey.home, lang)),
            a(
              [t(c.mailAction)],
              href: 'mailto:$contactEmail',
              classes: 'text-link',
            ),
          ],
        ),
      ]),
      // The `?` of the confused fish is ink: it needs a light ground in dark
      // mode, so the fish sits on a light stage in both themes.
      const div(classes: 'hero-fish fish-stage', [Fish(pose: 'confused')]),
    ]);
  }
}
