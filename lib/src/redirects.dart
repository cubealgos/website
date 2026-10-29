// SPDX-License-Identifier: Apache-2.0

/// The retired pages and the redirect page each one is built as.
///
/// About folded into Home (brand decision 59): `/ueber/` and `/en/about/`
/// lead to the home page of their language. The site is static files, so the
/// build writes a page at each retired path that redirects the browser at once
/// (`<meta http-equiv="refresh" content="0; url=...">`, which Google treats as
/// a permanent redirect), names the home page as canonical and is `noindex`. A
/// true `301` is the server's job: `docs/redirects.md` has the rule.
library;

import 'package:website/src/copy/not_found_copy.dart';
import 'package:website/src/icons.dart';
import 'package:website/src/routes.dart';

/// A retired page: the [path] it answered at and the language of the home page
/// it leads to.
class Redirect {
  /// Creates the redirect from [path] to the home page in [lang].
  const new(this.path, this.lang);

  /// The retired path, directory style (`/ueber/`).
  final String path;

  /// The language of the target, the home page of that language.
  final Lang lang;

  /// The path of the target.
  String get target => pathFor(PageKey.home, lang);

  /// The absolute URL of the target.
  String get targetUrl => urlFor(PageKey.home, lang);

  /// The file the build writes, relative to the build directory.
  String get file => '${path.substring(1)}index.html';
}

/// Every retired page. Nothing links to them; they exist for old links.
const List<Redirect> redirects = [
  Redirect('/ueber/', Lang.de),
  Redirect('/en/about/', Lang.en),
];

const Map<Lang, ({String title, String description})> _text = {
  Lang.de: (
    title: 'Weiterleitung zur Startseite | Cube Algos',
    description: 'Weiterleitung zur Startseite von Cube Algos.',
  ),
  Lang.en: (
    title: 'Redirecting to the home page | Cube Algos',
    description: 'Redirecting to the Cube Algos home page.',
  ),
};

/// The HTML of the redirect page of [r]: refresh to the target, canonical to
/// the target, `noindex`, and a link to the target for a browser that does
/// not follow the refresh. Same-origin resources only, no inline CSS or
/// script.
String redirectHtml(Redirect r) {
  final text = _text[r.lang]!;
  final link = notFoundCopy[r.lang]!.homeAction;
  return '<!DOCTYPE html>\n'
      '<html lang="${r.lang.code}">\n'
      '<head>\n'
      '<meta charset="utf-8"/>\n'
      '<meta name="viewport" content="width=device-width, initial-scale=1"/>\n'
      '<title>${text.title}</title>\n'
      '<meta name="description" content="${text.description}"/>\n'
      '<meta name="robots" content="noindex"/>\n'
      '<meta http-equiv="refresh" content="0; url=${r.target}"/>\n'
      '<link href="${r.targetUrl}" rel="canonical"/>\n'
      '<link href="$faviconSvg" rel="icon" type="image/svg+xml"/>\n'
      '<link href="$faviconIco" rel="icon" sizes="any"/>\n'
      '<link href="$appleTouchIcon" rel="apple-touch-icon"/>\n'
      '<link href="$manifestPath" rel="manifest"/>\n'
      '<link href="/fonts/fonts.css" rel="stylesheet"/>\n'
      '<link href="/brand/tokens.css" rel="stylesheet"/>\n'
      '<link href="/site.css" rel="stylesheet"/>\n'
      '</head>\n'
      '<body>\n'
      '<main id="main" class="wrap">\n'
      '<p><a href="${r.target}">$link</a></p>\n'
      '</main>\n'
      '</body>\n'
      '</html>\n';
}
