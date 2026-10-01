// SPDX-License-Identifier: Apache-2.0

/// Rules over the site's own CSS (never the vendored `brand/` files): colours,
/// durations and easings come from the tokens, nowhere else, and only
/// `transform` and `opacity` are animated.
library;

final _comment = RegExp(r'/\*.*?\*/', dotAll: true);
final _declaration = RegExp(r'([-\w]+)\s*:\s*([^;{}]+)');
final _var = RegExp(r'var\([^)]*\)');
final _colourFn = RegExp(
  r'\b(rgb|rgba|hsl|hsla|hwb|lab|lch|oklab|oklch|color|light-dark)\(',
  caseSensitive: false,
);
final _hex = RegExp(r'#[0-9a-fA-F]{3,8}\b');
final _word = RegExp('[a-zA-Z]+');

/// CSS named colours that may not appear in a value (`transparent`,
/// `currentcolor` and the keywords `inherit`/`initial`/`unset` are fine).
const _namedColours = {
  'aliceblue',
  'antiquewhite',
  'aqua',
  'aquamarine',
  'azure',
  'beige',
  'bisque',
  'black',
  'blanchedalmond',
  'blue',
  'blueviolet',
  'brown',
  'burlywood',
  'cadetblue',
  'chartreuse',
  'chocolate',
  'coral',
  'cornflowerblue',
  'cornsilk',
  'crimson',
  'cyan',
  'darkblue',
  'darkcyan',
  'darkgoldenrod',
  'darkgray',
  'darkgreen',
  'darkgrey',
  'darkkhaki',
  'darkmagenta',
  'darkolivegreen',
  'darkorange',
  'darkorchid',
  'darkred',
  'darksalmon',
  'darkseagreen',
  'darkslateblue',
  'darkslategray',
  'darkslategrey',
  'darkturquoise',
  'darkviolet',
  'deeppink',
  'deepskyblue',
  'dimgray',
  'dimgrey',
  'dodgerblue',
  'firebrick',
  'floralwhite',
  'forestgreen',
  'fuchsia',
  'gainsboro',
  'ghostwhite',
  'gold',
  'goldenrod',
  'gray',
  'green',
  'greenyellow',
  'grey',
  'honeydew',
  'hotpink',
  'indianred',
  'indigo',
  'ivory',
  'khaki',
  'lavender',
  'lavenderblush',
  'lawngreen',
  'lemonchiffon',
  'lightblue',
  'lightcoral',
  'lightcyan',
  'lightgoldenrodyellow',
  'lightgray',
  'lightgreen',
  'lightgrey',
  'lightpink',
  'lightsalmon',
  'lightseagreen',
  'lightskyblue',
  'lightslategray',
  'lightslategrey',
  'lightsteelblue',
  'lightyellow',
  'lime',
  'limegreen',
  'linen',
  'magenta',
  'maroon',
  'mediumaquamarine',
  'mediumblue',
  'mediumorchid',
  'mediumpurple',
  'mediumseagreen',
  'mediumslateblue',
  'mediumspringgreen',
  'mediumturquoise',
  'mediumvioletred',
  'midnightblue',
  'mintcream',
  'mistyrose',
  'moccasin',
  'navajowhite',
  'navy',
  'oldlace',
  'olive',
  'olivedrab',
  'orange',
  'orangered',
  'orchid',
  'palegoldenrod',
  'palegreen',
  'paleturquoise',
  'palevioletred',
  'papayawhip',
  'peachpuff',
  'peru',
  'pink',
  'plum',
  'powderblue',
  'purple',
  'rebeccapurple',
  'red',
  'rosybrown',
  'royalblue',
  'saddlebrown',
  'salmon',
  'sandybrown',
  'seagreen',
  'seashell',
  'sienna',
  'silver',
  'skyblue',
  'slateblue',
  'slategray',
  'slategrey',
  'snow',
  'springgreen',
  'steelblue',
  'tan',
  'teal',
  'thistle',
  'tomato',
  'turquoise',
  'violet',
  'wheat',
  'white',
  'whitesmoke',
  'yellow',
  'yellowgreen',
};

/// Every colour literal in [css] (hex, colour functions, named colours), one
/// message per declaration. `var(...)` references are fine.
List<String> hardCodedColours(String css) {
  final out = <String>[];
  final stripped = css.replaceAll(_comment, '');
  for (final m in _declaration.allMatches(stripped)) {
    final prop = m[1]!;
    final value = m[2]!
        .replaceAll(_var, '')
        .replaceAll(RegExp(r'url\([^)]*\)'), '');
    final hit =
        _hex.firstMatch(value)?[0] ??
        _colourFn.firstMatch(value)?[0] ??
        _word
            .allMatches(value)
            .map((w) => w[0]!.toLowerCase())
            .where(_namedColours.contains)
            .firstOrNull;
    if (hit != null) out.add('$prop: ${m[2]!.trim()} (colour literal "$hit")');
  }
  return out;
}

final _motionProp = RegExp(r'^(transition|animation)(-[a-z-]+)?$');
final _timeLiteral = RegExp(r'(?<![\w-])\d*\.?\d+m?s\b');
final _easingLiteral = RegExp(
  r'cubic-bezier\(|steps\(|linear\(|\b(ease|ease-in|ease-out|ease-in-out|linear|step-start|step-end)\b',
);

/// Duration and easing literals in `transition*`/`animation*` declarations of
/// [css]: they must be `var(--duration-*)` / `var(--ease-*)`.
List<String> literalMotion(String css) {
  final out = <String>[];
  final stripped = css.replaceAll(_comment, '');
  for (final m in _declaration.allMatches(stripped)) {
    final prop = m[1]!;
    if (!_motionProp.hasMatch(prop)) continue;
    final value = m[2]!.replaceAll(_var, '');
    final hit =
        _easingLiteral.firstMatch(value)?[0] ??
        _timeLiteral.firstMatch(value)?[0];
    if (hit != null) out.add('$prop: ${m[2]!.trim()} (literal "$hit")');
  }
  return out;
}

final _keyframes = RegExp(
  r'@keyframes\s+([\w-]+)\s*\{((?:[^{}]*\{[^{}]*\})*)\s*\}',
);
final _frameBody = RegExp(r'\{([^{}]*)\}');
// `background-size` is the one deliberate exception: it is paint-only (no
// layout), and it is how the headline underline follows a phrase that wraps
// over several lines, one segment per line.
const _animatable = {
  'transform',
  'opacity',
  'animation-timing-function',
  'background-size',
};

/// Properties other than `transform` and `opacity` that [css] animates:
/// declared in `@keyframes`, or named in `transition-property` / the
/// `transition` shorthand.
List<String> layoutMotion(String css) {
  final out = <String>[];
  final stripped = css.replaceAll(_comment, '');
  for (final k in _keyframes.allMatches(stripped)) {
    for (final frame in _frameBody.allMatches(k[2]!)) {
      for (final d in _declaration.allMatches(frame[1]!)) {
        if (!_animatable.contains(d[1])) {
          out.add('@keyframes ${k[1]}: animates ${d[1]}');
        }
      }
    }
  }
  for (final m in _declaration.allMatches(stripped)) {
    final value = m[2]!.replaceAll(_var, '').trim();
    final names = switch (m[1]) {
      'transition-property' => value.split(','),
      'transition' => [
        for (final t in value.split(',')) t.trim().split(RegExp(r'\s+')).first,
      ],
      _ => const <String>[],
    };
    for (final name in names.map((n) => n.trim())) {
      if (name.isNotEmpty && !{'transform', 'opacity', 'none'}.contains(name)) {
        out.add('${m[1]}: transitions "$name"');
      }
    }
  }
  return out;
}
