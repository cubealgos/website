// SPDX-License-Identifier: Apache-2.0

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';

const _buildDir = 'build/jaspr';

String _fileFor(String path) => path.endsWith('/') ? '${path}index.html' : path;

void main() {
  setUpAll(() async {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tool/build.dart',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  String read(String path) =>
      File(p.join(_buildDir, _fileFor(path).substring(1))).readAsStringSync();

  test('the build holds exactly the pages of the route table', () {
    final built = [
      for (final f in Directory(_buildDir).listSync(recursive: true))
        if (f is File && f.path.endsWith('.html'))
          '/${p.relative(f.path, from: _buildDir)}',
    ]..sort();
    final expected = [
      for (final m in paths.values)
        for (final path in m.values) _fileFor(path),
    ]..sort();
    expect(built, expected);
  });

  test('every page has lang, a unique title, hreflang and canonical', () {
    final titles = <String>{};
    for (final entry in paths.entries) {
      for (final lang in Lang.values) {
        final html = read(entry.value[lang]!);
        final where = '${entry.key}/${lang.code}';
        expect(html, contains('<html lang="${lang.code}">'), reason: where);
        final title = RegExp('<title>(.*?)</title>').firstMatch(html)![1]!;
        expect(title, pageMeta[entry.key]![lang]!.title, reason: where);
        expect(titles.add('${lang.code}:$title'), isTrue, reason: where);
        for (final alt in Lang.values) {
          expect(
            html,
            contains(
              '<link hreflang="${alt.code}" '
              'href="${urlFor(entry.key, alt)}" rel="alternate"/>',
            ),
            reason: where,
          );
        }
        expect(
          html,
          contains(
            '<link hreflang="x-default" '
            'href="${urlFor(entry.key, Lang.en)}" rel="alternate"/>',
          ),
          reason: where,
        );
        expect(
          html,
          contains('<link href="${urlFor(entry.key, lang)}" rel="canonical"/>'),
          reason: where,
        );
      }
    }
  });

  test('the built HTML references only same-origin resources', () {
    final ref = RegExp(r'''\b(?:src|href|action|srcset)="([^"]*)"''');
    for (final entry in paths.values) {
      for (final path in entry.values) {
        for (final m in ref.allMatches(read(path))) {
          final url = m[1]!;
          if (url.startsWith('//') || url.contains('://')) {
            expect(
              Uri.parse(url).host,
              Uri.parse(siteOrigin).host,
              reason: '$path references $url',
            );
          }
        }
        expect(read(path), isNot(contains('<script')), reason: path);
      }
    }
  });
}
