// SPDX-License-Identifier: Apache-2.0

// The phrase gate of brand decision 57 (principle: decision 56, say what we
// are, never what we are not). The studio no longer defines itself by what it
// does not take, hold or show; these defensive phrases are retired and fail
// the build's tests if one comes back, in German or English, on any built page
// (legal pages included), and on the home page and the blog rendered from the
// fixtures.
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/pages/blog_pages.dart';
import 'package:website/src/pages/home_page.dart';
import 'package:website/src/routes.dart';

import 'support/fixtures.dart';
import 'support/render.dart';

/// The retired phrases, matched without regard to case on the text of a page
/// (tags removed, entities decoded, whitespace collapsed), so „Kundenprojekte"
/// and "client projects" are caught by their stems.
const retiredPhrases = [
  'Kundenprojekt',
  'client project',
  'verwahren nichts',
  'hold nothing',
  'noch nicht öffentlich',
  'not public yet',
  'nehmen keine',
];

/// The retired phrases found in [html]: in its text and in its attributes (the
/// meta description, `alt`, `aria-label`).
List<String> retiredIn(String html) {
  final text = html
      .replaceAll(RegExp('<script[^>]*>.*?</script>', dotAll: true), ' ')
      .replaceAll(RegExp('<style[^>]*>.*?</style>', dotAll: true), ' ');
  final attributes = [
    for (final m in RegExp('="([^"]*)"').allMatches(text)) m[1]!,
  ];
  final haystacks = [
    text.replaceAll(RegExp('<[^>]*>'), ' '),
    ...attributes,
  ].map(_normalise).toList();
  return [
    for (final phrase in retiredPhrases)
      if (haystacks.any((h) => h.contains(phrase.toLowerCase()))) phrase,
  ];
}

String _normalise(String s) => s
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
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\s+'), ' ')
    .toLowerCase();

void main() {
  setUpAll(() async {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tool/build.dart',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  test('the scan catches every retired phrase and passes the new ones', () {
    for (final phrase in retiredPhrases) {
      expect(retiredIn('<main><p>Wir ${phrase.toUpperCase()}.</p></main>'), [
        phrase,
      ], reason: phrase);
    }
    expect(retiredIn('<p>Wir nehmen\n  keine Kundenprojekte an.</p>'), [
      'Kundenprojekt',
      'nehmen keine',
    ]);
    expect(retiredIn('<meta name="description" content="We hold nothing">'), [
      'hold nothing',
    ]);
    expect(
      retiredIn(
        '<p>Ihre Schlüssel bleiben bei Ihnen. Wir bauen die Software, die '
        'wir selbst benutzen wollen. Once it is published, its source code '
        'is linked here.</p>',
      ),
      isEmpty,
    );
  });

  test('no built page, in either language, carries a retired phrase', () {
    final files = Directory('build/jaspr')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.html'))
        .toList();
    // Every route of the shipped site is among them.
    final built = {
      for (final f in files) p.relative(f.path, from: 'build/jaspr'),
    };
    for (final route in routesFor(shippedContent)) {
      final file = route.path.endsWith('/')
          ? '${route.path.substring(1)}index.html'
          : route.path.substring(1);
      expect(built, contains(file));
    }
    final hits = <String>[];
    for (final f in files) {
      for (final phrase in retiredIn(f.readAsStringSync())) {
        hits.add('${f.path}: "$phrase"');
      }
    }
    expect(hits, isEmpty);
  });

  test('the home page and the blog index of the fixtures carry none', () async {
    final content = fixtureContent();
    final hits = <String>[];
    for (final lang in Lang.values) {
      final pages = {
        'home': await renderHtml(HomePage(lang: lang, content: content)),
        'home unnamed': await renderHtml(
          HomePage(lang: lang, content: content, productNamed: false),
        ),
        'blog': await renderHtml(BlogIndexPage(lang: lang, content: content)),
      };
      for (final MapEntry(:key, :value) in pages.entries) {
        for (final phrase in retiredIn(value)) {
          hits.add('${lang.code} $key: "$phrase"');
        }
      }
    }
    expect(hits, isEmpty);
  });
}
