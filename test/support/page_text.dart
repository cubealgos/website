// SPDX-License-Identifier: Apache-2.0

/// Helpers that read a built page back into the blocks of text it shows.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:website/src/routes.dart';

/// The built file of [key] in [lang] under `build/jaspr`.
String builtHtml(PageKey key, Lang lang) {
  final path = pathFor(key, lang);
  final file = path.endsWith('/') ? '${path}index.html' : path;
  return File(p.join('build/jaspr', file.substring(1))).readAsStringSync();
}

const _inline = {'span', 'strong', 'em', 'a', 'b', 'i', 'mark', 'small'};

String _decode(String s) => s
    .replaceAllMapped(
      RegExp('&#x([0-9a-fA-F]+);'),
      (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)),
    )
    .replaceAllMapped(
      RegExp('&#([0-9]+);'),
      (m) => String.fromCharCode(int.parse(m[1]!)),
    )
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&amp;', '&');

/// The text blocks of `<main>` in document order: one entry per block-level
/// element's text (inline elements join their parent's block), whitespace
/// collapsed, scripts excluded.
List<String> mainBlocks(String html) {
  final start = html.indexOf('<main');
  final end = html.indexOf('</main>');
  var body = html.substring(start, end);
  body = body.replaceAll(RegExp('<script[^>]*>.*?</script>', dotAll: true), '');
  // Decorative inline SVGs (the card sting) carry a stylesheet, not text.
  body = body.replaceAll(RegExp('<style[^>]*>.*?</style>', dotAll: true), '');
  // The renderer wraps a long line of text and inline elements; a source
  // newline before more text, or after text before an inline tag, is no block
  // boundary. A newline between two tags still separates sibling inline
  // elements such as two buttons.
  body = body.replaceAllMapped(
    RegExp(
      r'\s*\n\s*(?=[^<\s])|'
      '(?<=[^>\\s])[ \\t]*\\n\\s*(?=<(?:${_inline.join('|')})\\b)',
    ),
    (_) => ' ',
  );
  body = body.replaceAllMapped(RegExp(r'</?([a-zA-Z][a-zA-Z0-9]*)\b[^>]*>'), (
    m,
  ) {
    return _inline.contains(m[1]!.toLowerCase()) ? '' : '\n';
  });
  return [
    for (final line in _decode(body).split('\n'))
      if (line.trim().isNotEmpty) line.replaceAll(RegExp(r'\s+'), ' ').trim(),
  ];
}
