// SPDX-License-Identifier: Apache-2.0

/// Rules over the site's own CSS (never the vendored `brand/` files): colours
/// come from the tokens, nowhere else.
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
