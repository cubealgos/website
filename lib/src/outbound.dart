// SPDX-License-Identifier: Apache-2.0

/// The only links to other sites the built pages may carry (decision 39 and
/// 47, and the studio's LinkedIn page): the founder's own site, the studio's
/// GitHub organisation and LinkedIn company page, and the founder's two
/// profiles. They are
/// plain `<a href>` links and nothing else: `html_check` and the built-output
/// test allow exactly these URLs as the `href` of an `<a>`
/// and still fail on any other foreign link, and on any foreign `src`,
/// `srcset`, `url()` or form action (a link is not a request). The links of
/// the works and the posts in `content/` (`SiteContent.outboundAllowed`) are
/// allowed the same way, and only as links.
library;

/// The founder's own site, German.
const personalSiteUrl = 'https://kevinscheeren.de/';

/// The founder's own site, English.
const personalSiteUrlEn = 'https://kevinscheeren.de/en/';

/// The studio's GitHub organisation.
const githubOrgUrl = 'https://github.com/cubealgos';

/// The founder's GitHub profile.
const githubProfileUrl = 'https://github.com/kevinscheeren';

/// The founder's LinkedIn profile.
const linkedinProfileUrl = 'https://www.linkedin.com/in/kevinscheeren';

/// The studio's LinkedIn company page.
const linkedinCompanyUrl = 'https://www.linkedin.com/company/cubealgos/';

/// Exactly the URLs that may be linked, character for character (no query, no
/// fragment, no other path).
const Set<String> outboundUrls = {
  personalSiteUrl,
  personalSiteUrlEn,
  githubOrgUrl,
  githubProfileUrl,
  linkedinProfileUrl,
  linkedinCompanyUrl,
};
