// SPDX-License-Identifier: Apache-2.0

/// A blog post: the model behind one Markdown file of `content/posts/`.
///
/// A file is `<slug>.<lang>.md`: a front matter block of `key: value` lines
/// (`id`, `slug`, `lang`, `date`, `seoTitle`, `description`), then the title
/// as a `# ` line and the body (see `markdown.dart`). The `id` ties the
/// translations of one post together; a post may exist in one language only.
library;

import 'package:website/src/content/markdown.dart';
import 'package:website/src/routes.dart';

/// One post in one language.
class Post {
  /// Creates a post from parsed parts; files go through [Post.parse].
  const new({
    required this.id,
    required this.slug,
    required this.lang,
    required this.date,
    required this.title,
    required this.seoTitle,
    required this.description,
    required this.body,
    required this.words,
  });

  /// Parses the file [file] with the contents [source]. Throws a
  /// [FormatException] naming the file and the problem.
  factory parse(String source, {required String file}) {
    Never fail(String why) => throw FormatException('$file: $why');
    final text = source.replaceAll('\r\n', '\n');
    if (!text.startsWith('---\n')) fail('starts without a front matter block');
    final end = text.indexOf('\n---\n', 4);
    if (end < 0) fail('front matter block is never closed');
    final meta = <String, String>{};
    for (final line in text.substring(4, end).split('\n')) {
      if (line.trim().isEmpty) continue;
      final colon = line.indexOf(': ');
      if (colon < 1) fail('front matter line "$line" is no "key: value"');
      meta[line.substring(0, colon)] = line.substring(colon + 2).trim();
    }
    const keys = {'id', 'slug', 'lang', 'date', 'seoTitle', 'description'};
    for (final key in keys) {
      if ((meta[key] ?? '').isEmpty) fail('front matter lacks "$key"');
    }
    for (final key in meta.keys) {
      if (!keys.contains(key)) fail('front matter has an unknown key "$key"');
    }
    final lang = Lang.values.where((l) => l.code == meta['lang']).firstOrNull;
    if (lang == null) fail('lang must be "de" or "en"');
    final slug = meta['slug']!;
    final id = meta['id']!;
    final slugPattern = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
    if (!slugPattern.hasMatch(slug) || !slugPattern.hasMatch(id)) {
      fail('slug and id must be lower-case words joined by "-"');
    }
    if (!file.endsWith('$slug.${lang.code}.md')) {
      fail('the file must be named $slug.${lang.code}.md');
    }
    final date = DateTime.tryParse('${meta['date']}T00:00:00Z');
    if (date == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(meta['date']!) ||
        !date.toIso8601String().startsWith(meta['date']!)) {
      fail('date must be YYYY-MM-DD');
    }

    final body = text.substring(end + 5).trim();
    final firstBreak = body.indexOf('\n');
    final head = firstBreak < 0 ? body : body.substring(0, firstBreak);
    if (!head.startsWith('# ')) fail('the body must start with the "# " title');
    final title = head.substring(2).trim();
    final markdown = Markdown.parse(
      firstBreak < 0 ? '' : body.substring(firstBreak + 1),
      file: file,
    );
    if (markdown.blocks.isEmpty) fail('has no text after the title');
    if (markdown.blocks.first is! Paragraph) {
      fail('the text after the title must start with a paragraph (the lede)');
    }
    for (final url in linkUrls(markdown)) {
      final ok =
          url.startsWith('/') && !url.startsWith('//') ||
          url.startsWith('mailto:') ||
          Uri.tryParse(url)?.scheme == 'https' &&
              (Uri.tryParse(url)?.host ?? '').isNotEmpty;
      if (!ok) fail('link "$url" must be a path, a mailto: or an https URL');
    }
    return Post(
      id: id,
      slug: slug,
      lang: lang,
      date: date,
      title: title,
      seoTitle: meta['seoTitle']!,
      description: meta['description']!,
      body: markdown,
      words: RegExp(r'[\p{L}\p{N}_]+', unicode: true).allMatches(body).length,
    );
  }

  /// The id shared by the translations of one post.
  final String id;

  /// The path segment of the post's page.
  final String slug;

  /// The post's language.
  final Lang lang;

  /// The publication date (UTC midnight).
  final DateTime date;

  /// The H1.
  final String title;

  /// The `<title>` (without the site name).
  final String seoTitle;

  /// The meta description; also shown under the title in lists.
  final String description;

  /// The parsed text after the title.
  final Markdown body;

  /// The number of words of title and body.
  final int words;

  /// Minutes to read, at 200 words a minute, at least one.
  int get minutes => (words / 200).round().clamp(1, 1 << 20);
}

/// The URLs of the links in [markdown].
Iterable<String> linkUrls(Markdown markdown) sync* {
  for (final block in markdown.blocks) {
    final runs = switch (block) {
      Paragraph(:final inlines) => [inlines],
      BulletList(:final items) => items,
      _ => const <List<Inline>>[],
    };
    for (final run in runs) {
      for (final i in run) {
        if (i is LinkRun) yield i.url;
      }
    }
  }
}
