// SPDX-License-Identifier: Apache-2.0

/// Small building blocks shared by the page bodies.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/chrome_text.dart';

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
