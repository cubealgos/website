// SPDX-License-Identifier: Apache-2.0

/// Small building blocks shared by the page bodies.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';
import 'package:website/src/content/markdown.dart';
import 'package:website/src/outbound.dart';

/// A plain element: [tag] with optional [classes], [id] and [attrs].
Component el(
  String tag,
  List<Component> children, {
  String? classes,
  String? id,
  Map<String, String>? attrs,
}) => Component.element(
  tag: tag,
  classes: classes,
  id: id,
  attributes: attrs,
  children: children,
);

/// The "back" link above a work or a post: a drawn arrow (inline SVG, no glyph:
/// the arrow `←` is not in the self-hosted font subsets) and the label. The
/// arrow is decorative.
class BackLink extends StatelessComponent {
  /// Creates the link labelled [label] (without the arrow) to [href].
  const new({required this.label, required this.href, super.key});

  /// The link text.
  final String label;

  /// The target path.
  final String href;

  @override
  Component build(BuildContext context) => p(classes: 'back', [
    a(href: href, [
      const RawText(
        '<svg class="back-arrow" viewBox="0 0 16 16" aria-hidden="true" '
        'focusable="false"><path d="M14 8H3M7.5 3.5L3 8l4.5 4.5"/></svg>',
      ),
      t(label),
    ]),
  ]);
}

/// A text node.
Component t(String value) => Component.text(value);

/// A clownfish pose from the vendored brand assets, always decorative (empty
/// alt text, hidden from assistive technology: the adjacent text carries the
/// meaning). The animated SVGs stop and show their key frame under reduced
/// motion on their own. Use [onAmber] only on an amber ground.
class Fish extends StatelessComponent {
  /// Creates the fish in [pose] (`idle`, `swimming`, `happy`, `confused`).
  const new({
    required this.pose,
    this.onAmber = false,
    this.classes,
    super.key,
  });

  /// The pose file name without extension.
  final String pose;

  /// Whether to use the on-amber variant.
  final bool onAmber;

  /// Extra CSS classes.
  final String? classes;

  @override
  Component build(BuildContext context) => img(
    src: '/brand/fish/animated/${onAmber ? 'on-amber/' : ''}$pose.svg',
    alt: '',
    classes: 'fish-img ${classes ?? ''}'.trim(),
    width: 144,
    height: 90,
    attributes: const {'aria-hidden': 'true'},
  );
}

/// A chamfered `mailto:` button (the focus ring lives on the wrapper).
class MailButton extends StatelessComponent {
  /// Creates a button labelled [label].
  const new({required this.label, super.key});

  /// The button text.
  final String label;

  @override
  Component build(BuildContext context) => span(classes: 'btn-wrap', [
    a([Component.text(label)], href: 'mailto:$contactEmail', classes: 'btn'),
  ]);
}

/// A chamfered button that links to [href] (an internal path or an in-page
/// anchor).
class LinkButton extends StatelessComponent {
  /// Creates a button labelled [label] leading to [href].
  const new({required this.label, required this.href, super.key});

  /// The button text.
  final String label;

  /// The target: a root-absolute path or an in-page anchor.
  final String href;

  @override
  Component build(BuildContext context) => span(classes: 'btn-wrap', [
    a([Component.text(label)], href: href, classes: 'btn'),
  ]);
}

/// [inlines] as elements: `code`, `strong` and links. A link to another site
/// carries `rel="noreferrer"`; [linkClass] is added to every link.
List<Component> inlineComponents(List<Inline> inlines, {String? linkClass}) => [
  for (final i in inlines)
    switch (i) {
      TextRun(:final text) => t(text),
      CodeSpan(:final text) => code([t(text)]),
      Strong(:final text) => strong([t(text)]),
      LinkRun(:final label, :final url) => a(
        [t(label)],
        href: url,
        classes: linkClass,
        attributes: {if (url.startsWith('https://')) 'rel': 'noreferrer'},
      ),
    },
];

/// [text] with `code`, `**bold**` and `[label](url)` turned into elements. A
/// link must lead to a URL of [outboundUrls] or be a `mailto:` address
/// (asserted), so a typo cannot ship a stray link.
List<Component> inlineLinks(String text, {String? linkClass}) {
  final inlines = parseInline(text);
  for (final link in inlines.whereType<LinkRun>()) {
    assert(
      outboundUrls.contains(link.url) || link.url.startsWith('mailto:'),
      'not an allowed outbound link: ${link.url}',
    );
  }
  return inlineComponents(inlines, linkClass: linkClass);
}

/// [text] as read aloud: the labels of its links, no URLs or markup.
String plainText(String text) => plain(parseInline(text));
