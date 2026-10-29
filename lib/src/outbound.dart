// SPDX-License-Identifier: Apache-2.0

/// The only links to other sites the built pages may carry (decision 58 and
/// the studio's LinkedIn page): the GitHub organisation of wearenotabank and
/// the studio's LinkedIn company page. They are plain `<a href>` links and
/// nothing else: `html_check` and the built-output test allow exactly these
/// URLs as the `href` of an `<a>` and still fail on any other foreign link,
/// and on any foreign `src`, `srcset`, `url()` or form action (a link is not a
/// request). The links of the posts in `content/`
/// (`SiteContent.outboundAllowed`) are allowed the same way, and only as
/// links.
library;

/// The GitHub organisation of wearenotabank, the studio's product.
const wearenotabankOrgUrl = 'https://github.com/wearenotabank';

/// The studio's LinkedIn company page.
const linkedinCompanyUrl = 'https://www.linkedin.com/company/cubealgos/';

/// Whether the site names wearenotabank and links its organisation (brand
/// decision 58, under wearenotabank `DEC-082`).
///
/// This is the one switch. With `false` the home page says "We build our own
/// software for EVM chains." with its button to the contact page and no
/// Produkt row, the contact page and the head data lose the name, and no
/// built file carries the name or [wearenotabankOrgUrl]. After flipping it,
/// re-run `fvm dart run tool/og_images.dart` (the share images carry the H1;
/// `--check` fails until they match).
const namesProduct = true;

/// Exactly the URLs that may be linked, character for character (no query, no
/// fragment, no other path).
const Set<String> outboundUrls = {wearenotabankOrgUrl, linkedinCompanyUrl};
