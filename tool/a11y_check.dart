// SPDX-License-Identifier: Apache-2.0

// Automated accessibility checks over the built site in headless Chrome (build
// first: `fvm dart run tool/build.dart`). Every page in both languages, in the
// light and the dark theme:
//
//  * structure: one banner, main and contentinfo landmark, named navigation
//    landmarks, nothing outside a landmark but the skip link, exactly one H1,
//    no skipped heading level, `lang` as the route table says, accessible names
//    on links, buttons and disclosure summaries, alt text, unique ids;
//  * focus: Tab through every interactive element (skip link, navigation,
//    language switch, FAQ summaries, buttons, footer links): document order,
//    a visible 2px focus ring in the focus token on each, in view and not
//    covered;
//  * contrast: every rendered text against its effective background (4.5:1,
//    3:1 for large text), in both themes, reduced motion on so scroll reveals
//    are at rest.
//
// Lighthouse's audits run separately (`tool/a11y/`); these cover what it cannot
// reach: both themes, the focus walk and the site's own landmark rules.
// Run: `fvm dart run tool/a11y_check.dart`.
import 'dart:io';

import 'package:website/src/routes.dart';

import 'src/a11y_probes.dart';
import 'src/chrome.dart';
import 'src/static_server.dart';

const _focusToken = '''
(() => {
  const probe = document.createElement('span');
  probe.style.color = getComputedStyle(document.documentElement).getPropertyValue('--color-focus').trim();
  document.body.append(probe);
  const c = getComputedStyle(probe).color;
  probe.remove();
  return c;
})()
''';

Future<void> main() async {
  if (!Directory('build/jaspr').existsSync()) {
    stderr.writeln('a11y_check: build/jaspr missing; build first.');
    exit(2);
  }
  final server = await serveDirectory('build/jaspr');
  final base = 'http://localhost:${server.port}';
  final chrome = await Chrome.launch();
  final page = await chrome.newPage();
  final failures = <String>[];
  var stops = 0;
  var texts = 0;
  var skipped = 0;
  try {
    await page.setViewport(1280, 800);
    for (final dark in [false, true]) {
      // Reduced motion: scroll reveals are at rest, so the contrast scan sees
      // the final colours.
      await page.setMedia(dark: dark, reducedMotion: true);
      final theme = dark ? 'dark' : 'light';
      for (final entry in paths.entries) {
        for (final lang in Lang.values) {
          final path = pathFor(entry.key, lang);
          final where = '$path ($theme)';
          await page.goto('$base$path');

          final structure = await page.eval(
            structureProbe.replaceAll('%LANG%', lang.code),
          );
          if (!dark) {
            for (final f in (structure! as List<dynamic>)) {
              failures.add('structure: $where: $f');
            }
          }

          final contrast = await page.evalMap(contrastProbe);
          texts += contrast['checked']! as int;
          skipped += contrast['skipped']! as int;
          for (final f in contrast['findings']! as List<dynamic>) {
            failures.add('contrast: $where: $f');
          }

          final focus = await page.eval(_focusToken);
          final count = (await page.eval(stopsProbe))! as int;
          for (var i = 0; i < count; i++) {
            await page.press('Tab');
            final s = await page.evalMap(focusProbe);
            stops++;
            if (s['index'] != i) {
              failures.add(
                'tab order: $where: stop $i focused ${s['label']} '
                '(#${s['index']})',
              );
              break;
            }
            final label = '${s['label']}';
            final ring =
                s['outlineStyle'] == 'solid' &&
                s['outlineWidth'] == '2px' &&
                s['outlineColor'] == focus;
            // A chamfered button clips an outline: its ring is a drop-shadow
            // on the wrapper (see browser_check).
            final shadowRing = '${s['parentFilter']}'.contains('$focus');
            if (!ring && !shadowRing) {
              failures.add(
                'focus ring: $where: $label has ${s['outlineStyle']} '
                '${s['outlineWidth']} ${s['outlineColor']} '
                '(filter ${s['parentFilter']}), expected solid 2px $focus',
              );
            }
            if (s['inView'] != true) {
              failures.add('focus out of view: $where: $label');
            }
            if (s['obscured'] == true) {
              failures.add('focus obscured by another element: $where: $label');
            }
          }
        }
      }
    }
  } finally {
    await chrome.close();
    await server.close(force: true);
  }
  if (failures.isNotEmpty) {
    failures.forEach(stderr.writeln);
    stderr.writeln('a11y_check: ${failures.length} finding(s).');
    exit(1);
  }
  stdout.writeln(
    'a11y_check: ${paths.length * Lang.values.length} pages x 2 themes ok: '
    'structure, $stops focus stops, $texts text contrasts '
    '($skipped over images or gradients not judged).',
  );
}
