// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:website/src/copy/about_copy.dart';
import 'package:website/src/copy/common_copy.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/pages/about_page.dart';
import 'package:website/src/routes.dart';

import 'support/page_text.dart';

List<String> expectedBlocks(Lang lang) {
  final c = aboutCopy[lang]!;
  return [
    c.h1,
    c.lede,
    c.whoTitle,
    ...c.who,
    '${c.linksIntro} ${c.links.join(' · ')}',
    c.oneTitle,
    c.one,
    c.ownTitle,
    c.own,
    c.ownCode,
    c.howTitle,
    ...c.how,
    c.whereTitle,
    c.where,
    c.ctaTitle,
    writeToKevin[lang]!,
  ];
}

void main() {
  setUpAll(() async {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tool/build.dart',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  for (final lang in Lang.values) {
    group('about ${lang.code}', () {
      late String html;
      setUp(() => html = builtHtml(PageKey.about, lang));

      test('the page shows exactly the copy, in order', () {
        expect(mainBlocks(html), expectedBlocks(lang));
      });

      test('title, description and the single H1 match', () {
        final meta = pageMeta[PageKey.about]![lang]!;
        expect(meta.h1, aboutCopy[lang]!.h1);
        expect('<h1'.allMatches(html), hasLength(1));
        expect(RegExp('<title>(.*?)</title>').firstMatch(html)![1], meta.title);
      });

      test('the closing CTA is the only contact route', () {
        final mail = RegExp('href="(mailto:[^"]*)"').allMatches(html);
        expect(mail.map((m) => m[1]).toSet(), {'mailto:hello@cubealgos.de'});
        expect(html, isNot(contains('<form')));
      });

      test('the portrait is the founder photo with its alt text', () {
        final figure = RegExp(
          '<figure class="founder-photo[^"]*"[^>]*>(.*?)</figure>',
          dotAll: true,
        ).firstMatch(html)![1]!;
        expect(figure, contains('alt="Kevin Scheeren"'));
        expect(figure, contains('type="image/webp"'));
        expect(figure, contains('/img/kevin-scheeren-420.webp 420w'));
        expect(figure, contains('/img/kevin-scheeren-560.jpg'));
        expect(figure, contains('width="560" height="747"'));
        expect(figure, isNot(contains('/brand/fish/')));
      });

      test('no fish stands in for the portrait, no product is named', () {
        expect(html, isNot(contains('class="portrait')));
        expect(
          html,
          isNot(matches(RegExp('barrierewacht', caseSensitive: false))),
        );
      });

      test('other sites are plain text, never links', () {
        expect(html, isNot(matches(RegExp('<a [^>]*href="(https?:)?//'))));
        for (final address in aboutCopy[lang]!.links) {
          expect(html, contains('<span class="url">$address</span>'));
        }
      });

      test('no sentence about prices', () {
        final text = mainBlocks(html).join('\n');
        expect(
          text,
          isNot(
            matches(
              RegExp(
                r'Festpreis|fixed price|Preis|prices?\b|keine Kosten|'
                'costs nothing',
                caseSensitive: false,
              ),
            ),
          ),
        );
      });
    });
  }

  test('the portrait files are web copies without any metadata', () {
    for (final w in portraitWidths) {
      for (final ext in ['jpg', 'webp']) {
        final bytes = File('web/img/kevin-scheeren-$w.$ext').readAsBytesSync();
        final text = String.fromCharCodes(bytes);
        for (final marker in ['Exif', 'XMP', 'ICC_PROFILE', 'Photoshop']) {
          expect(text, isNot(contains(marker)), reason: '$w.$ext: $marker');
        }
        if (ext == 'jpg') {
          expect(
            _jpegSegments(bytes),
            everyElement(isNot(anyOf(0xE1, 0xE2, 0xED, 0xFE))),
          );
        } else {
          // RIFF/WEBP with the bare image chunk only (no EXIF, XMP, ICCP).
          expect(String.fromCharCodes(bytes.sublist(8, 16)), 'WEBPVP8 ');
        }
      }
    }
  });
}

/// The marker bytes of a JPEG's segments up to the start of the scan.
List<int> _jpegSegments(List<int> bytes) {
  final markers = <int>[];
  var i = 2;
  while (i + 4 <= bytes.length && bytes[i] == 0xFF) {
    final marker = bytes[i + 1];
    markers.add(marker);
    if (marker == 0xDA) break;
    i += 2 + (bytes[i + 2] << 8 | bytes[i + 3]);
  }
  return markers;
}
