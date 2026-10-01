// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:math' as math;

import 'package:test/test.dart';

/// Reads the `--color-*` custom properties of the first block that follows
/// [selector] in the vendored tokens.
Map<String, String> _tokens(String css, String selector) {
  final start = css.indexOf(selector);
  if (start < 0) throw StateError('no $selector in tokens.css');
  final body = css.substring(css.indexOf('{', start) + 1);
  final end = body.indexOf('}');
  return {
    for (final m in RegExp(
      r'(--color-[\w-]+):\s*(#[0-9A-Fa-f]{6})',
    ).allMatches(body.substring(0, end)))
      m[1]!: m[2]!,
  };
}

double _channel(int v) {
  final c = v / 255;
  return c <= 0.03928
      ? c / 12.92
      : math.pow((c + 0.055) / 1.055, 2.4) as double;
}

double _luminance(String hex) {
  final n = int.parse(hex.substring(1), radix: 16);
  return 0.2126 * _channel(n >> 16) +
      0.7152 * _channel((n >> 8) & 0xff) +
      0.0722 * _channel(n & 0xff);
}

/// The WCAG contrast ratio of two `#rrggbb` colours.
double contrast(String a, String b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  final css = File('web/brand/tokens.css').readAsStringSync();
  final light = _tokens(css, ':root {');
  final darkMedia = _tokens(css, ':root:not([data-theme="light"])');
  final darkAttr = _tokens(css, ':root[data-theme="dark"]');

  test('the dark theme is the same under the media query and data-theme', () {
    expect(darkMedia, darkAttr);
  });

  for (final theme in {'light': light, 'dark': darkAttr}.entries) {
    test('the focus ring has 3:1 against bg and card (${theme.key})', () {
      final t = theme.value;
      for (final surface in ['--color-bg', '--color-card']) {
        expect(
          contrast(t['--color-focus']!, t[surface]!),
          greaterThanOrEqualTo(3),
          reason: '--color-focus on $surface',
        );
      }
    });

    test('the focus ring is accent-text, not amber (${theme.key})', () {
      expect(theme.value['--color-focus'], theme.value['--color-accent-text']);
    });
  }

  test('no easing token overshoots or bounces', () {
    final easings = RegExp(r'--ease-[\w-]+:\s*cubic-bezier\(([^)]*)\)')
        .allMatches(css)
        .toList();
    expect(easings, hasLength(4));
    for (final m in easings) {
      final p = m[1]!.split(',').map((v) => double.parse(v.trim())).toList();
      for (final y in [p[1], p[3]]) {
        expect(y, inInclusiveRange(0, 1), reason: m[0]);
      }
    }
  });
}
