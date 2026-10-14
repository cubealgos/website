// SPDX-License-Identifier: Apache-2.0

/// The small Markdown of the blog: second-level headings, paragraphs, bullet
/// lists, fenced code blocks and, inside text, `code`, **bold** and
/// `[label](url)` links.
///
/// Anything else (a third-level heading, a numbered list, a quotation, an
/// image, raw HTML) is refused with the line number, so a post can never
/// render something the template does not style or the CSP does not allow.
library;

/// A piece of running text.
sealed class Inline {
  const new();
}

/// Plain text.
class TextRun extends Inline {
  /// Creates plain text.
  const new(this.text);

  /// The text.
  final String text;
}

/// `code`.
class CodeSpan extends Inline {
  /// Creates a code span.
  const new(this.text);

  /// The code.
  final String text;
}

/// **bold**.
class Strong extends Inline {
  /// Creates bold text.
  const new(this.text);

  /// The text.
  final String text;
}

/// `[label](url)`.
class LinkRun extends Inline {
  /// Creates a link.
  const new(this.label, this.url);

  /// The visible text.
  final String label;

  /// A root-absolute path, an `https` URL or a `mailto:` address.
  final String url;
}

/// A block of a post.
sealed class MdBlock {
  const new();
}

/// A second-level heading with the id its contents entry links to.
class Heading extends MdBlock {
  /// Creates a heading.
  const new(this.text, this.id);

  /// The heading text (plain).
  final String text;

  /// The anchor id.
  final String id;
}

/// A paragraph.
class Paragraph extends MdBlock {
  /// Creates a paragraph.
  const new(this.inlines);

  /// The text.
  final List<Inline> inlines;
}

/// A bullet list.
class BulletList extends MdBlock {
  /// Creates a bullet list.
  const new(this.items);

  /// One run of text per item.
  final List<List<Inline>> items;
}

/// A fenced code block.
class CodeBlock extends MdBlock {
  /// Creates a code block.
  const new(this.code);

  /// The code, as written.
  final String code;
}

/// A parsed post body.
class Markdown {
  /// Creates the parse result.
  const new(this.blocks);

  /// Parses [source]; [file] names it in errors.
  factory parse(String source, {required String file}) =>
      _Parser(source, file).parse();

  /// The blocks, in order.
  final List<MdBlock> blocks;

  /// The headings, in order.
  Iterable<Heading> get headings => blocks.whereType<Heading>();
}

/// The plain text of [inlines] (labels of links, no markup).
String plain(List<Inline> inlines) => [
  for (final i in inlines)
    switch (i) {
      TextRun(:final text) => text,
      CodeSpan(:final text) => text,
      Strong(:final text) => text,
      LinkRun(:final label) => label,
    },
].join();

/// The anchor id of a heading: lower-case words joined by `-`, umlauts
/// transliterated.
String slugify(String heading) => heading
    .toLowerCase()
    .replaceAll('ä', 'ae')
    .replaceAll('ö', 'oe')
    .replaceAll('ü', 'ue')
    .replaceAll('ß', 'ss')
    .replaceAll(RegExp('[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

final _inline = RegExp(r'`([^`]+)`|\*\*([^*]+)\*\*|\[([^\]]+)\]\(([^)\s]+)\)');

/// Splits one run of text into [Inline]s.
List<Inline> parseInline(String text) {
  final out = <Inline>[];
  var at = 0;
  for (final m in _inline.allMatches(text)) {
    if (m.start > at) out.add(TextRun(text.substring(at, m.start)));
    if (m[1] != null) {
      out.add(CodeSpan(m[1]!));
    } else if (m[2] != null) {
      out.add(Strong(m[2]!));
    } else {
      out.add(LinkRun(m[3]!, m[4]!));
    }
    at = m.end;
  }
  if (at < text.length) out.add(TextRun(text.substring(at)));
  return out;
}

class _Parser {
  new(String source, this.file) : lines = source.split('\n');

  final String file;
  final List<String> lines;
  final blocks = <MdBlock>[];
  final para = <String>[];
  final items = <String>[];
  final ids = <String>{};

  Never fail(int line, String why) =>
      throw FormatException('$file:${line + 1}: $why');

  void flush() {
    if (para.isNotEmpty) {
      blocks.add(Paragraph(parseInline(para.join(' '))));
      para.clear();
    }
    if (items.isNotEmpty) {
      blocks.add(BulletList([for (final i in items) parseInline(i)]));
      items.clear();
    }
  }

  Markdown parse() {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();
      if (line.trim().isEmpty) {
        flush();
      } else if (line.startsWith('```')) {
        flush();
        final start = i;
        final code = <String>[];
        i++;
        while (i < lines.length && !lines[i].startsWith('```')) {
          code.add(lines[i].trimRight());
          i++;
        }
        if (i >= lines.length) fail(start, 'code fence is never closed');
        blocks.add(CodeBlock(code.join('\n')));
      } else if (line.startsWith('## ')) {
        flush();
        final text = line.substring(3).trim();
        var id = slugify(text);
        if (id.isEmpty) fail(i, 'heading has no usable text');
        var n = 2;
        final base = id;
        while (!ids.add(id)) {
          id = '$base-${n++}';
        }
        blocks.add(Heading(text, id));
      } else if (line.startsWith('#')) {
        fail(i, 'only "## " headings are supported inside a post');
      } else if (line.startsWith('- ')) {
        if (para.isNotEmpty) {
          blocks.add(Paragraph(parseInline(para.join(' '))));
          para.clear();
        }
        items.add(line.substring(2).trim());
      } else if (line.startsWith('  ') && items.isNotEmpty) {
        items[items.length - 1] += ' ${line.trim()}';
      } else if (RegExp(r'^(\d+[.)]|>|\||<|!\[|\* )').hasMatch(line)) {
        fail(
          i,
          'numbered lists, quotations, tables, images and HTML are not '
          'supported',
        );
      } else {
        if (items.isNotEmpty) flush();
        para.add(line.trim());
      }
    }
    flush();
    return Markdown(blocks);
  }
}
