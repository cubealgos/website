// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

/// The vendored mark-only sting (`web/brand/sting/sting-mark.svg`), whose own
/// `<style>` block carries the brand's keyframes (`cas-` prefixed).
const stingMarkSource = 'web/brand/sting/sting-mark.svg';

/// Where the build writes the sting's stylesheet, linked from the home pages
/// (the site sends no inline CSS, so `style-src 'self'` needs no hashes).
const stingCssPath = '/brand/sting-mark.css';

final _styleBlock = RegExp(r'\s*<style[^>]*>(.*?)</style>', dotAll: true);

String _source() => File(stingMarkSource).readAsStringSync();

/// The mark's CSS: the content of the `<style>` block in the vendored SVG.
String stingCss() {
  final m = _styleBlock.firstMatch(_source());
  if (m == null) {
    throw StateError('$stingMarkSource has no <style> block');
  }
  return '${m[1]!.trim().replaceAll(RegExp('^ {4}', multiLine: true), '')}\n';
}

/// The mark as inline SVG without its `<style>` block (the CSS is the
/// external [stingCssPath]) and without its title; decorative.
String stingSvg() => _source()
    .replaceFirst(_styleBlock, '')
    .replaceFirst(RegExp(r'\s*<title>.*?</title>'), '')
    .replaceFirst(
      'role="img" aria-label="Cube Algos logo"',
      'aria-hidden="true" focusable="false"',
    );
