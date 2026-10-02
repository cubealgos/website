// SPDX-License-Identifier: Apache-2.0

/// Small building blocks shared by the page bodies.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';
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

/// A chamfered `mailto:` button (the focus ring lives on the wrapper). Set
/// [inverse] for use on an amber ground.
class MailButton extends StatelessComponent {
  /// Creates a button labelled [label].
  const new({required this.label, this.inverse = false, super.key});

  /// The button text.
  final String label;

  /// Ink button for amber panels.
  final bool inverse;

  @override
  Component build(BuildContext context) => span(classes: 'btn-wrap', [
    a(
      [Component.text(label)],
      href: 'mailto:$contactEmail',
      classes: inverse ? 'btn btn--inverse' : 'btn',
    ),
  ]);
}

/// A chamfered button that links to [href] (an internal path).
class LinkButton extends StatelessComponent {
  /// Creates a button labelled [label] leading to [href].
  const new({required this.label, required this.href, super.key});

  /// The button text.
  final String label;

  /// The root-absolute target path.
  final String href;

  @override
  Component build(BuildContext context) => span(classes: 'btn-wrap', [
    a([Component.text(label)], href: href, classes: 'btn'),
  ]);
}

final _markdownLink = RegExp(r'\[([^\]]+)\]\(([^)|]+)(?:\|([^)]+))?\)');

/// [text] with `[label](url)` links turned into `<a>` elements; the URLs must
/// be in [outboundUrls] (asserted), so a typo cannot ship a stray link. A
/// `[label](url|name)` link also carries `name` as its accessible name (it
/// must contain the label), for two links of one label to different targets.
List<Component> inlineLinks(String text, {String? linkClass}) {
  final out = <Component>[];
  var at = 0;
  for (final m in _markdownLink.allMatches(text)) {
    assert(
      outboundUrls.contains(m[2]),
      'not an allowed outbound link: ${m[2]}',
    );
    if (m.start > at) out.add(t(text.substring(at, m.start)));
    out.add(
      a(
        [t(m[1]!)],
        href: m[2]!,
        classes: linkClass,
        attributes: {'rel': 'noreferrer', 'aria-label': ?m[3]},
      ),
    );
    at = m.end;
  }
  if (at < text.length) out.add(t(text.substring(at)));
  return out;
}

/// [text] as read aloud: the labels of its `[label](url)` links, no URLs.
String plainText(String text) =>
    text.replaceAllMapped(_markdownLink, (m) => m[1]!);
