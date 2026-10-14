// SPDX-License-Identifier: Apache-2.0

/// The parts of a work that more than one page shows: the plate (its image or
/// its generated cover), the status, the licence and the "room" band.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/content/markdown.dart';
import 'package:website/src/content/work.dart';
import 'package:website/src/copy/works_copy.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

/// A small deterministic random source (xorshift32, seeded with the FNV-1a
/// hash of a string), so a work's cover is the same on every build.
class _Rng {
  new(String seed) {
    var h = 0x811c9dc5;
    for (final unit in seed.codeUnits) {
      h = ((h ^ unit) * 0x01000193) & 0xffffffff;
    }
    _state = h == 0 ? 0x9e3779b9 : h;
  }

  late int _state;

  int _next() {
    var x = _state;
    x ^= (x << 13) & 0xffffffff;
    x ^= x >> 17;
    x ^= (x << 5) & 0xffffffff;
    return _state = x & 0xffffffff;
  }

  /// A number in [0, 1).
  double nextDouble() => _next() / 0x100000000;

  T choice<T>(List<T> items) => items[(nextDouble() * items.length).floor()];

  /// [count] distinct numbers of [from] up to (excluding) [to], sorted.
  List<int> sample(int from, int to, int count) {
    final pool = [for (var i = from; i < to; i++) i];
    final out = <int>[];
    for (var i = 0; i < count; i++) {
      out.add(pool.removeAt((nextDouble() * pool.length).floor()));
    }
    return out..sort();
  }
}

/// The generated cover of a work that has no image yet, as inline SVG: the
/// brand's grid, one large outlined chamfered tile, one small solid tile and
/// a route line with square nodes, one of them the amber chamfer (the stack
/// card's language). Drawn from the slug alone. It is decorative: the name and
/// the one-liner beside it carry the meaning, so it has no text alternative
/// and is hidden from assistive technology (the equivalent of an empty `alt`).
/// Its colours are tokens (`pl-*` rules in `site.css`), so it follows the
/// theme.
String coverSvg(String slug) {
  final r = _Rng(slug);
  const u = 40;
  const w = 12 * u;
  const h = 9 * u;
  String tile(num x, num y, num s, String cls) {
    final c = s * 0.2929;
    String n(num v) => v.toStringAsFixed(1);
    return '<path class="$cls" d="M${n(x)} ${n(y)}H${n(x + s - c)}'
        'L${n(x + s)} ${n(y + c)}V${n(y + s)}H${n(x + c)}'
        'L${n(x)} ${n(y + s - c)}Z"/>';
  }

  final parts = StringBuffer('<rect class="pl-bg" width="$w" height="$h"/>');
  for (var i = 1; i < 12; i++) {
    parts.write('<path class="pl-grid" d="M${i * u} 0V$h"/>');
  }
  for (var j = 1; j < 9; j++) {
    parts.write('<path class="pl-grid" d="M0 ${j * u}H$w"/>');
  }
  final left = r.nextDouble() < 0.5;
  final bigS = r.choice([4, 5, 6]);
  final bx = left ? r.choice([1, 2]) : 11 - bigS - r.choice([0, 1]);
  final by = bigS < 6 ? r.choice([1, 2]) : 1;
  parts.write(tile(bx * u, by * u, bigS * u, 'pl-outline'));
  final small = r.choice([1, 2]);
  final sx = r.nextDouble() < 0.5 ? bx + bigS - small ~/ 2 - 1 : (left ? 8 : 2);
  final sy = r.nextDouble() < 0.5 ? by + bigS - small : 7 - small;
  parts.write(tile(sx * u, sy * u, small * u, 'pl-ink'));
  final vertical = r.nextDouble() < 0.4;
  final nodes = r.sample(1, vertical ? 8 : 11, 4);
  final amber = r.choice(nodes);
  final List<(int, int)> points;
  if (vertical) {
    final rx = (left ? 11 : 1) * u;
    parts.write('<path class="pl-route" d="M$rx ${u}V${8 * u}"/>');
    points = [for (final n in nodes) (rx, n * u)];
  } else {
    const ry = 8 * u;
    parts.write('<path class="pl-route" d="M$u ${ry}H${11 * u}"/>');
    points = [for (final n in nodes) (n * u, ry)];
  }
  for (var i = 0; i < nodes.length; i++) {
    final (x, y) = points[i];
    parts.write(
      nodes[i] == amber
          ? tile(x - 9, y - 9, 18, 'pl-amber')
          : '<rect class="pl-node" x="${x - 7}" y="${y - 7}" width="14" '
                'height="14"/>',
    );
  }
  return '<svg class="plate-svg" viewBox="0 0 $w $h" aria-hidden="true" '
      'focusable="false" preserveAspectRatio="xMidYMid slice">$parts</svg>';
}

/// A work's plate: its first image, or the generated cover.
class Plate extends StatelessComponent {
  /// Creates the plate of [work] in [lang].
  const new({required this.work, required this.lang, this.classes, super.key});

  /// The work.
  final Work work;

  /// The page's language (the image's alt text).
  final Lang lang;

  /// Extra classes of the plate.
  final String? classes;

  @override
  Component build(BuildContext context) {
    final image = work.images.firstOrNull;
    return div(classes: 'plate ${classes ?? ''}'.trim(), [
      if (image == null)
        RawText(coverSvg(work.slug))
      else
        img(
          src: image.src,
          alt: image.alt[lang],
          width: image.width,
          height: image.height,
          classes: 'plate-img',
        ),
    ]);
  }
}

/// The status of a work as a mono label with its node.
class StatusBadge extends StatelessComponent {
  /// Creates the badge of [work] in [lang].
  const new({required this.work, required this.lang, super.key});

  /// The work.
  final Work work;

  /// The page's language.
  final Lang lang;

  @override
  Component build(BuildContext context) {
    final text = statusText(work, lang);
    return span(classes: 'status status--${work.status.id}', [
      const span(
        classes: 'status-node',
        attributes: {'aria-hidden': 'true'},
        [],
      ),
      Component.text(text.label),
    ]);
  }
}

/// The label (and explanation) of [work]'s status: an app that is deployed
/// reads "available".
StatusText statusText(Work work, Lang lang) {
  final c = worksCopy[lang]!;
  return work.kind == WorkKind.app && work.status == WorkStatus.deployed
      ? c.appAvailable
      : c.status[work.status]!;
}

/// The name of [work] in [lang], with its note ("working title") beside it.
List<Component> workName(Work work, Lang lang) => [
  Component.text(work.nameIn(lang)),
  if (work.nameNote?[lang] case final note?) ...[
    const Component.text(' '),
    span(classes: 'name-note', [Component.text('($note)')]),
  ],
];

/// The catalogue number as shown on a plate: `01`.
String numberLabel(Work work) => work.number.toString().padLeft(2, '0');

/// One work as a full-width band ("room"): the plate, the status and number,
/// the name, the one-liner, the licence and the link to the work's page.
/// [odd] decides the background and the side of the plate; [level] is the
/// heading level of the name.
class Room extends StatelessComponent {
  /// Creates the room of [work].
  const new({
    required this.work,
    required this.lang,
    required this.odd,
    required this.level,
    super.key,
  });

  /// The work.
  final Work work;

  /// The page's language.
  final Lang lang;

  /// Whether this is an odd room (card-grey, plate on the left).
  final bool odd;

  /// The heading level of the name (3 under a section, 2 on the index).
  final int level;

  @override
  Component build(BuildContext context) {
    final c = worksCopy[lang]!;
    final headingId = 'room-${work.slug}';
    final licence = work.licence;
    return el(
      'article',
      classes: 'room room--${odd ? 'odd' : 'even'}',
      attrs: {'aria-labelledby': headingId},
      [
        div(classes: 'wrap room-grid', [
          Plate(work: work, lang: lang, classes: 'reveal'),
          el(
            'div',
            classes: 'room-text reveal',
            attrs: const {'data-i': '1'},
            [
              p(classes: 'room-top', [
                span(
                  classes: 'placard-no',
                  attributes: const {'aria-hidden': 'true'},
                  [Component.text(numberLabel(work))],
                ),
                StatusBadge(work: work, lang: lang),
              ]),
              el(
                'h$level',
                classes: 'room-name',
                id: headingId,
                workName(work, lang),
              ),
              p(
                classes: 'room-line',
                inlineComponents(parseInline(work.line[lang]!)),
              ),
              if (licence != null)
                p(classes: 'placard-lic', [
                  Component.text(c.licence[licence]!.short),
                ]),
              a(
                [
                  Component.text(
                    c.more.replaceAll('{name}', work.nameIn(lang)),
                  ),
                ],
                href: routePath(PageKey.work, lang, work.slug),
                classes: 'more',
              ),
            ],
          ),
        ]),
      ],
    );
  }
}
