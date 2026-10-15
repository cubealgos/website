// SPDX-License-Identifier: Apache-2.0

/// Content for the tests, outside the shipped data: fixture works (fictional,
/// with example.org links) and fixture posts.
library;

import 'package:website/src/content/site_content.dart';

/// The fixture works and posts: the first [works] works (by file name, at
/// most four) and, with [posts], the fixture posts.
SiteContent fixtureContent({int works = 4, bool posts = true}) {
  final all = SiteContent.load(root: 'test/fixtures');
  return SiteContent(
    works: all.works.reversed.take(works).toList(),
    posts: posts ? all.posts : const [],
  );
}
