// SPDX-License-Identifier: Apache-2.0

// Builds the static site into `build/jaspr/`, prunes it to the deployable
// files (`jaspr build` also leaves the build tooling's own bookkeeping --
// `packages/`, `.dart_tool/`, `.build.manifest` -- next to the pages) and
// adds `sitemap.xml` from the route table and the redirect pages of the retired
// URLs (`lib/src/redirects.dart`).
//
// Run: `fvm dart run tool/build.dart`.
import 'dart:io';

import 'package:website/src/content/site_content.dart';
import 'package:website/src/icons.dart';
import 'package:website/src/redirects.dart';
import 'package:website/src/seo.dart';

const _outDir = 'build/jaspr';
// The sitemap with hreflang alternates, from the route table.
void _writeSitemap() =>
    File('$_outDir/sitemap.xml').writeAsStringSync(sitemapXml(shippedContent));

// The web manifest, with the paper token as theme and background colour.
void _writeManifest() {
  final paper = paperFromTokens(
    File('$_outDir/brand/tokens.css').readAsStringSync(),
  );
  File('$_outDir$manifestPath').writeAsStringSync(webManifest(paper: paper));
}

// A redirect page at each retired path (About folded into Home).
void _writeRedirects() {
  for (final r in redirects) {
    File('$_outDir/${r.file}')
      ..createSync(recursive: true)
      ..writeAsStringSync(redirectHtml(r));
  }
}

const _leftovers = ['packages', '.dart_tool', '.build.manifest'];

Future<void> main() async {
  final result = await Process.start(Platform.resolvedExecutable, [
    'run',
    'jaspr_cli:jaspr',
    'build',
  ], mode: ProcessStartMode.inheritStdio);
  final code = await result.exitCode;
  if (code != 0) {
    exit(code);
  }
  for (final name in _leftovers) {
    final dir = Directory('$_outDir/$name');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    final file = File('$_outDir/$name');
    if (file.existsSync()) file.deleteSync();
  }
  _writeSitemap();
  _writeManifest();
  _writeRedirects();
  stdout.writeln('static site written to $_outDir');
}
