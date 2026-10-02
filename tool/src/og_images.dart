// SPDX-License-Identifier: Apache-2.0

/// The share images (1200 x 630 PNG, one per language), built from the
/// vendored brand assets: the horizontal logo lockup and the language's home
/// H1 in Onest 800 on paper, with an amber rule, rendered by headless Chrome.
///
/// Chrome's rasteriser differs slightly between platforms, so freshness is
/// checked on the *inputs*: [inputsDigest] hashes the exact HTML (text, colours
/// from `tokens.css`, the lockup SVG) and the font files, and the committed
/// `tool/og_images.lock` must match it. The PNGs' size is read from their
/// header.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/seo.dart';

import 'chrome.dart';

/// Where the generated images live, relative to the repo root.
const ogDir = 'web/og';

/// The committed digest of the inputs the images were generated from.
const lockFile = 'tool/og_images.lock';

const _fonts = ['web/fonts/onest-800.woff2', 'web/fonts/dm-mono-400.woff2'];

String _token(String css, String name) {
  final m = RegExp('--color-primitive-$name:\\s*(#[0-9A-Fa-f]{6})')
      .firstMatch(css);
  if (m == null) throw StateError('token $name not found in tokens.css');
  return m[1]!;
}

String _esc(String s) => const HtmlEscape().convert(s);

/// The HTML of the share image of [lang]; the fonts load from [fontBase].
String imageHtml(Lang lang, {String fontBase = '../../fonts'}) {
  final css = File('web/brand/tokens.css').readAsStringSync();
  final paper = _token(css, 'paper');
  final ink = _token(css, 'ink');
  final amber = _token(css, 'amber');
  final muted = _token(css, 'muted');
  final lockup = File('web/brand/logo/lockup-horizontal.svg')
      .readAsStringSync()
      .replaceFirst(RegExp(r'\s*<title>.*?</title>'), '')
      .replaceFirst(
        'role="img" aria-label="Cube Algos logo"',
        'aria-hidden="true"',
      );
  final h1 = pageMeta[PageKey.home]![lang]!.h1;
  return '''
<!DOCTYPE html>
<html lang="${lang.code}"><head><meta charset="utf-8"/><style>
@font-face{font-family:"Onest";font-weight:800;src:url("$fontBase/onest-800.woff2") format("woff2")}
@font-face{font-family:"DM Mono";font-weight:400;src:url("$fontBase/dm-mono-400.woff2") format("woff2")}
*{box-sizing:border-box;margin:0}
html,body{width:${shareImageWidth}px;height:${shareImageHeight}px;overflow:hidden}
body{background:$paper;color:$ink;font-family:Onest,sans-serif;position:relative}
.logo{position:absolute;left:80px;top:72px;width:268px;height:64px;color:$ink}
.logo svg{width:100%;height:100%;display:block}
h1{position:absolute;left:80px;top:196px;width:1040px;font-weight:800;font-size:72px;line-height:1.1;letter-spacing:-0.02em}
.rule{position:absolute;left:80px;bottom:112px;width:176px;height:12px;background:$amber}
.url{position:absolute;left:80px;bottom:52px;font-family:"DM Mono",monospace;font-size:26px;color:$muted}
</style></head><body>
<div class="logo">$lockup</div>
<h1>${_esc(h1)}</h1>
<div class="rule"></div>
<div class="url">cubealgos.de</div>
</body></html>
''';
}

/// The digest of everything the images are built from.
String inputsDigest() {
  final bytes = <int>[
    for (final lang in Lang.values) ...utf8.encode(imageHtml(lang)),
    for (final f in _fonts) ...File(f).readAsBytesSync(),
  ];
  return sha256.convert(bytes).toString();
}

/// Width and height from a PNG's IHDR chunk, or `null` if it is no PNG.
({int width, int height})? pngSize(List<int> bytes) {
  const sig = [137, 80, 78, 71, 13, 10, 26, 10];
  if (bytes.length < 24) return null;
  for (var i = 0; i < 8; i++) {
    if (bytes[i] != sig[i]) return null;
  }
  int u32(int o) =>
      (bytes[o] << 24) |
      (bytes[o + 1] << 16) |
      (bytes[o + 2] << 8) |
      bytes[o + 3];
  return (width: u32(16), height: u32(20));
}

/// Problems with the committed images: stale inputs, missing files, wrong size.
List<String> checkImages() {
  final problems = <String>[];
  final lock = File(lockFile);
  if (!lock.existsSync()) {
    problems.add('$lockFile is missing; run tool/og_images.dart');
  } else if (lock.readAsStringSync().trim() != inputsDigest()) {
    problems.add(
      'share images are stale: their inputs changed; run '
      '`fvm dart run tool/og_images.dart` and commit web/og/ and $lockFile',
    );
  }
  for (final lang in Lang.values) {
    final path = 'web${shareImagePath(lang)}';
    final file = File(path);
    if (!file.existsSync()) {
      problems.add('$path is missing');
      continue;
    }
    final size = pngSize(file.readAsBytesSync());
    if (size == null) {
      problems.add('$path is not a PNG');
    } else if (size.width != shareImageWidth ||
        size.height != shareImageHeight) {
      problems.add(
        '$path is ${size.width}x${size.height}, '
        'not ${shareImageWidth}x$shareImageHeight',
      );
    }
  }
  return problems;
}

/// Renders both images with headless Chrome and rewrites the lock file.
Future<void> generateImages() async {
  final tmp = Directory.systemTemp.createTempSync('og_images_');
  final chrome = await Chrome.launch();
  try {
    final fonts = Directory('web/fonts').absolute.path;
    final page = await chrome.newPage();
    await page.setViewport(shareImageWidth, shareImageHeight);
    for (final lang in Lang.values) {
      final html = File('${tmp.path}/${lang.code}.html')
        ..writeAsStringSync(imageHtml(lang, fontBase: 'file://$fonts'));
      await page.goto('file://${html.path}');
      await page.eval('document.fonts.ready.then(() => true)');
      final shot = await page.send('Page.captureScreenshot', {
        'format': 'png',
        'clip': {
          'x': 0,
          'y': 0,
          'width': shareImageWidth,
          'height': shareImageHeight,
          'scale': 1,
        },
      });
      File('web${shareImagePath(lang)}')
        ..createSync(recursive: true)
        ..writeAsBytesSync(base64Decode(shot['data']! as String));
    }
  } finally {
    await chrome.close();
    tmp.deleteSync(recursive: true);
  }
  File(lockFile).writeAsStringSync('${inputsDigest()}\n');
}
