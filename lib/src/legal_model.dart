// SPDX-License-Identifier: Apache-2.0

/// The data model of the legal pages: plain data that the view renders, so
/// the text lives in one place per page and language and can be tested.
library;

/// A link inside running text.
class Link {
  /// Creates a link showing [text] that leads to [href].
  const new(this.text, this.href);

  /// The visible text.
  final String text;

  /// The target (`mailto:`, `tel:`, or a path).
  final String href;
}

/// Inline content: a `String` or a [Link].
typedef Inline = Object;

/// A block of a section.
sealed class Block {
  const new();
}

/// A paragraph of inline content.
class Para extends Block {
  /// Creates a paragraph of [inlines].
  const new(this.inlines);

  /// The text and links, in order.
  final List<Inline> inlines;
}

/// A list of labelled facts (`<dl>`); each value is a list of lines.
class Facts extends Block {
  /// Creates the facts list.
  const new(this.items);

  /// `(label, lines)`; each line is inline content.
  final List<({String label, List<List<Inline>> lines})> items;
}

/// A bulleted list.
class Bullets extends Block {
  /// Creates a list of [items].
  const new(this.items);

  /// One inline run per item.
  final List<List<Inline>> items;
}

/// A headed section.
class Section {
  /// Creates a section.
  const new(this.heading, this.blocks);

  /// The `<h2>` text.
  final String heading;

  /// The section's content.
  final List<Block> blocks;
}

/// One legal page in one language.
class LegalDoc {
  /// Creates a document.
  const new({required this.sections, this.notice});

  /// A line directly under the H1 (the English pages say the German text is
  /// authoritative).
  final String? notice;

  /// The sections, in order.
  final List<Section> sections;
}
