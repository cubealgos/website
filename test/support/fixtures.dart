// SPDX-License-Identifier: Apache-2.0

/// Content for the tests, outside the shipped data: fixture posts.
library;

import 'package:website/src/content/site_content.dart';

/// The fixture posts (or none, with [posts] false).
SiteContent fixtureContent({bool posts = true}) {
  final all = SiteContent.load(root: 'test/fixtures');
  return SiteContent(posts: posts ? all.posts : const []);
}
