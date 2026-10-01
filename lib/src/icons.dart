// SPDX-License-Identifier: Apache-2.0

/// The favicon set and the web manifest: the one place that spells the icon
/// paths, shared by the page head, the build and the checks.
library;

import 'dart:convert';

/// The vendored favicon directory (covered by `brand_sync --check`).
const _dir = '/brand/favicon';

/// The SVG favicon (it switches to paper in dark browser themes).
const faviconSvg = '$_dir/favicon.svg';

/// The `.ico` fallback.
const faviconIco = '$_dir/favicon.ico';

/// The iOS home-screen icon.
const appleTouchIcon = '$_dir/apple-touch-icon.png';

/// The web manifest, written by the build (`tool/build.dart`).
const manifestPath = '/site.webmanifest';

/// The manifest's icons: `(path, size, purpose)`.
const manifestIcons = <({String path, int size, String purpose})>[
  (path: '$_dir/icon-192.png', size: 192, purpose: 'any'),
  (path: '$_dir/icon-512.png', size: 512, purpose: 'any'),
  (path: '$_dir/icon-maskable-192.png', size: 192, purpose: 'maskable'),
  (path: '$_dir/icon-maskable-512.png', size: 512, purpose: 'maskable'),
];

/// Every icon file the built site must contain.
final List<String> iconFiles = [
  faviconSvg,
  faviconIco,
  appleTouchIcon,
  ...[for (final i in manifestIcons) i.path],
];

/// The text of `site.webmanifest`; [paper] is the paper token (`#RRGGBB`).
String webManifest({required String paper}) {
  final manifest = {
    'name': 'Cube Algos',
    'short_name': 'Cube Algos',
    'start_url': '/',
    'display': 'browser',
    'theme_color': paper,
    'background_color': paper,
    'icons': [
      for (final i in manifestIcons)
        {
          'src': i.path,
          'sizes': '${i.size}x${i.size}',
          'type': 'image/png',
          'purpose': i.purpose,
        },
    ],
  };
  return '${const JsonEncoder.withIndent('  ').convert(manifest)}\n';
}

/// Reads the paper token out of the vendored `tokens.css` text.
String paperFromTokens(String css) {
  final m = RegExp(r'--color-primitive-paper:\s*(#[0-9A-Fa-f]{6})\s*;')
      .firstMatch(css);
  if (m == null) {
    throw const FormatException('paper token not found in tokens.css');
  }
  return m[1]!;
}
