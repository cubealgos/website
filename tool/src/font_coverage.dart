// SPDX-License-Identifier: Apache-2.0

/// Checks the committed font subsets against their coverage manifest and the
/// characters the site's copy needs. No woff2 reader is needed: the manifest
/// (`tool/fonts/coverage.json`) is generated from each face's cmap by
/// `tool/fonts/subset.py`, and carries the sha256 of the woff2 it describes,
/// so a manifest that no longer matches the committed files is a finding.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

String _hex(int c) => c.toRadixString(16).toUpperCase().padLeft(4, '0');

/// Expands a `pyftsubset` unicodes spec such as `U+0020-007E,U+00A0`.
Set<int> parseUnicodes(String spec) {
  final out = <int>{};
  for (final part in spec.split(',')) {
    final m = RegExp(r'^U\+([0-9A-Fa-f]+)(?:-([0-9A-Fa-f]+))?$')
        .firstMatch(part.trim());
    if (m == null) throw FormatException('bad unicodes entry "$part"');
    final lo = int.parse(m[1]!, radix: 16);
    final hi = m[2] == null ? lo : int.parse(m[2]!, radix: 16);
    for (var c = lo; c <= hi; c++) {
      out.add(c);
    }
  }
  return out;
}

/// The characters the text of [file] (Markdown as is, HTML with tags removed
/// and entities decoded) needs a glyph for; whitespace controls are ignored.
Set<int> charsOf(File file) {
  var text = file.readAsStringSync();
  if (file.path.endsWith('.html')) {
    text = text
        .replaceAll(
          RegExp(
            r'<(script|style)\b.*?</\1>|<!--.*?-->',
            dotAll: true,
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp('<[^>]*>'), ' ')
        .replaceAllMapped(
          RegExp(r'&(#x[0-9a-fA-F]+|#\d+|amp|lt|gt|quot|apos|nbsp);'),
          (m) => switch (m[1]!) {
            'amp' => '&',
            'lt' => '<',
            'gt' => '>',
            'quot' => '"',
            'apos' => "'",
            'nbsp' => ' ',
            final n when n.startsWith('#x') => String.fromCharCode(
              int.parse(n.substring(2), radix: 16),
            ),
            final n => String.fromCharCode(int.parse(n.substring(1))),
          },
        );
  }
  return text.runes.where((c) => c > 0x20 || c == 0x20).toSet()..remove(0x7f);
}

/// Runs every check; [copyPaths] are files or directories (`.md`, `.html`)
/// whose text must be covered. Returns the findings (empty is ok).
List<String> checkFontCoverage({
  required Directory repoRoot,
  List<String> copyPaths = const [],
}) {
  final out = <String>[];
  final manifestFile = File(
    p.join(repoRoot.path, 'tool', 'fonts', 'coverage.json'),
  );
  final manifest =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  final required = parseUnicodes(manifest['unicodes'] as String);
  final faces = manifest['faces'] as Map<String, dynamic>;

  final needed = {...required};
  for (final path in copyPaths) {
    final type = FileSystemEntity.typeSync(path);
    final files = switch (type) {
      FileSystemEntityType.directory => [
        for (final f in Directory(path).listSync(recursive: true))
          if (f is File && (f.path.endsWith('.md') || f.path.endsWith('.html')))
            f,
      ],
      FileSystemEntityType.file => [File(path)],
      _ => <File>[],
    };
    if (files.isEmpty) out.add('no .md/.html copy found at $path');
    for (final f in files) {
      for (final c in charsOf(f)) {
        if (!required.contains(c)) {
          out.add(
            '${f.path}: U+${_hex(c)}'
            ' (${String.fromCharCode(c)}) is not in the subset spec',
          );
        }
      }
    }
  }

  for (final MapEntry(key: name, value: raw) in faces.entries) {
    final face = raw as Map<String, dynamic>;
    final file = File(p.join(repoRoot.path, 'web', 'fonts', name));
    if (!file.existsSync()) {
      out.add('$name: missing from web/fonts');
      continue;
    }
    final sha = sha256.convert(file.readAsBytesSync()).toString();
    if (sha != face['sha256']) {
      out.add('$name: differs from the manifest; rerun tool/fonts/subset.py');
    }
    final have = (face['codepoints'] as List).cast<int>().toSet();
    for (final c in needed.difference(have)) {
      out.add('$name: no glyph for U+${_hex(c)}');
    }
  }
  return out;
}
