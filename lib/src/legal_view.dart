// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/legal_model.dart';

/// Renders a [LegalDoc]: the H1, the optional authoritative-text notice and
/// the sections.
class LegalPage extends StatelessComponent {
  /// Creates the view of [doc] under the heading [heading].
  const new({required this.heading, required this.doc, super.key});

  /// The H1 text.
  final String heading;

  /// The content.
  final LegalDoc doc;

  @override
  Component build(BuildContext context) => div(classes: 'wrap legal', [
    h1(classes: 'rise', [Component.text(heading)]),
    if (doc.notice case final notice?)
      p(classes: 'notice', [Component.text(notice)]),
    for (final sec in doc.sections)
      section([
        h2([Component.text(sec.heading)]),
        for (final block in sec.blocks) _block(block),
      ]),
  ]);
}

Component _inline(Inline part) => switch (part) {
  final String text => Component.text(text),
  final Link link => a([Component.text(link.text)], href: link.href),
  _ => throw ArgumentError('unsupported inline: $part'),
};

Component _line(List<Inline> parts) =>
    Component.fragment([for (final part in parts) _inline(part)]);

Component _block(Block block) => switch (block) {
  Para(:final inlines) => p([_line(inlines)]),
  Bullets(:final items) => ul([
    for (final item in items) li([_line(item)]),
  ]),
  Facts(:final items) => dl(classes: 'facts', [
    for (final item in items) ...[
      dt([Component.text(item.label)]),
      dd([
        for (var i = 0; i < item.lines.length; i++) ...[
          if (i > 0) const br(),
          _line(item.lines[i]),
        ],
      ]),
    ],
  ]),
};
