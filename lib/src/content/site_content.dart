// SPDX-License-Identifier: Apache-2.0

/// Everything the site shows that lives in data files: the posts. The pages,
/// the route table, the sitemap and the checks all read one [SiteContent], so
/// what is built and what is checked cannot differ.
library;

import 'dart:io';

import 'package:website/src/content/post.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// The posts of the site.
class SiteContent {
  /// Creates content from already-validated posts. [posts] may be in any
  /// order; they are kept newest first.
  new({List<Post> posts = const []}) : posts = _newestPostsFirst(posts) {
    _unique('post slug', [
      for (final p in this.posts) '${p.lang.code}/${p.slug}',
    ]);
    _unique('post id', [for (final p in this.posts) '${p.lang.code}/${p.id}']);
  }

  /// Reads the data files under [root]: `posts/*.md`. Throws a
  /// [FormatException] for the first file that is not valid.
  factory load({String root = 'content'}) {
    final posts = <Post>[];
    final postsDir = Directory('$root/posts');
    if (postsDir.existsSync()) {
      for (final f in _files(postsDir, '.md')) {
        posts.add(Post.parse(f.readAsStringSync(), file: f.path));
      }
    }
    return SiteContent(posts: posts);
  }

  /// The posts of both languages, newest first.
  final List<Post> posts;

  /// Whether the blog pages and the nav item exist.
  bool get hasPosts => posts.isNotEmpty;

  /// The post of [lang] with [slug], if any.
  Post? postBySlug(Lang lang, String slug) =>
      posts.where((p) => p.lang == lang && p.slug == slug).firstOrNull;

  /// The post with the id [id] in [lang], if it was written in that language.
  Post? postById(Lang lang, String id) =>
      posts.where((p) => p.lang == lang && p.id == id).firstOrNull;

  /// The same post in the other language, if there is one.
  Post? translationOf(Post post) => postById(post.lang.other, post.id);

  /// The newest post a visitor in [lang] should be shown: one written in
  /// [lang], else the newest of the other language.
  Post? newestPostFor(Lang lang) =>
      posts.where((p) => p.lang == lang).firstOrNull ?? posts.firstOrNull;

  /// Every URL a page may link to another site: the allow-list of
  /// `outbound.dart` plus the links of the posts.
  Set<String> get outboundAllowed => {
    ...outboundUrls,
    for (final p in posts)
      for (final url in linkUrls(p.body))
        if (url.startsWith('https://')) url,
  };
}

SiteContent? _shipped;

/// The content that ships: `content/` of the repository root, read once.
SiteContent get shippedContent => _shipped ??= SiteContent.load();

List<Post> _newestPostsFirst(List<Post> posts) =>
    List<Post>.of(posts)..sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : a.slug.compareTo(b.slug);
    });

Iterable<File> _files(Directory dir, String extension) =>
    dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith(extension))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

void _unique(String what, List<String> values) {
  final seen = <String>{};
  for (final v in values) {
    if (!seen.add(v)) throw FormatException('duplicate $what: $v');
  }
}
