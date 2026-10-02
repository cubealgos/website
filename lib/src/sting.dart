// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

/// The vendored mark-only sting (`web/brand/sting/sting-mark.svg`), whose own
/// `<style>` block carries the brand's keyframes (`cas-` prefixed).
const stingMarkSource = 'web/brand/sting/sting-mark.svg';

/// The stylesheet derived from it by `brand_sync`, linked from the home pages
/// (the site sends no inline CSS, so `style-src 'self'` needs no hashes).
const stingCssPath = '/brand/sting/sting-mark.css';

final _styleBlock = RegExp(r'\s*<style[^>]*>(.*?)</style>', dotAll: true);

String _source() => File(stingMarkSource).readAsStringSync();

/// The mark as inline SVG without its `<style>` block (the CSS is the
/// external [stingCssPath]) and without its title; decorative.
String stingSvg() => _source()
    .replaceFirst(_styleBlock, '')
    .replaceFirst(RegExp(r'\s*<title>.*?</title>'), '')
    .replaceFirst(
      'role="img" aria-label="Cube Algos logo"',
      'aria-hidden="true" focusable="false"',
    );
