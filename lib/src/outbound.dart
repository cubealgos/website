// SPDX-License-Identifier: Apache-2.0

/// The only links to other sites the built pages may carry (decision 39 and
/// 47): Kevin's own site, the studio's GitHub organisation, and Kevin's two
/// profiles. They are plain `<a href>` links and nothing else: `html_check`
/// and the built-output test allow exactly these URLs as the `href` of an `<a>`
/// and still fail on any other foreign link, and on any foreign `src`,
/// `srcset`, `url()` or form action (a link is not a request).
library;

/// Kevin's own site, German.
const personalSiteUrl = 'https://kevinscheeren.de/';

/// Kevin's own site, English.
const personalSiteUrlEn = 'https://kevinscheeren.de/en/';

/// The studio's GitHub organisation.
const githubOrgUrl = 'https://github.com/cubealgos';

/// Kevin's GitHub profile.
const githubProfileUrl = 'https://github.com/kevinscheeren';

/// Kevin's LinkedIn profile.
const linkedinProfileUrl = 'https://www.linkedin.com/in/kevinscheeren';

/// Exactly the URLs that may be linked, character for character (no query, no
/// fragment, no other path).
const Set<String> outboundUrls = {
  personalSiteUrl,
  personalSiteUrlEn,
  githubOrgUrl,
  githubProfileUrl,
  linkedinProfileUrl,
};
