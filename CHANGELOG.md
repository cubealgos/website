# Changelog

## Unreleased

- Licence and governance files (#2).
- Repo conventions, README, CLAUDE.md, commit-msg hook (#3).
- Jaspr static scaffold with bilingual routes (#4).
- Verification CI on GitHub-hosted runners: format, analyze, test, build, licence-check, html-check, branch-lint, lint-history, changelog-check (#5).
- Self-hosted Onest (400, 800) and DM Mono (400) Latin + German woff2 subsets with their OFL licences, `@font-face` rules, a preload of the display face, the reproducible subsetting recipe in `tool/fonts/`, a font coverage check and a no-third-party-host check over built HTML and CSS (#7).
- Release workflow: a `vX.Y.Z` tag builds the site and attaches a reproducible `site-vX.Y.Z.tar.gz` with its `.sha256` to a GitHub release (`tool/package_release.dart`, `docs/releasing.md`) (#18).
- Branch rule accepts `release/<N>-<X.Y.Z>` for the release family, as `docs/releasing.md` prescribes (#26).
- Brand sync: `tool/brand_sync.dart` vendors the pinned `cubealgos/branding` v1.0.0 release (tokens, logos, favicons, fish, sting) into `web/brand/`, verified against `SHA256SUMS` and recorded in `brand.lock.json`; `--check` and the new `brand-check` workflow fail on any hand edit (#6).
- Layout shell: skip link, header with the theme-aware logo lockup, nav and EN/DE switch, footer, visible focus rings, light/dark via the vendored tokens, responsive from 320 px; `browser_check` (headless Chrome: no horizontal scroll, keyboard walkthrough, language switch) and a hard-coded-colour check in `html-check` (#8).
- UI motion, "Draw, then press": button press and hover, the amber underline drawn once, text rise with stagger, and the home sting (still under reduced motion), all from the brand tokens; CI rejects duration/easing literals and non-`transform`/`opacity` animation, and `browser_check` covers the motion behaviour in headless Chrome (#9).
- Favicon set (SVG, `.ico`, apple-touch) and `site.webmanifest` (written by the build, paper token colours) linked from every page head; `html-check` fails on missing icon links, a missing manifest or a missing icon file (#31).
- Impressum in German and English (§ 5 DDG facts, liability for content and links), rendered from a small legal-page model with the facts in one file; the English page states the German text is authoritative; the font subsets gain § (U+00A7) (#15).
- Datenschutz in German and English: hosting (STRATO), no access logs and no IP storage, no cookies, tracking or analytics, self-hosted fonts, contact by `mailto:` (mailbox by Proton), rights and the LDI NRW; a built-output test pins every statement and the claims it makes (#16).
- The home sting no longer stores a `sessionStorage` flag: it plays unless `document.referrer` is a page of this site; `html-check` fails on any `sessionStorage`, `localStorage`, `indexedDB` or `document.cookie` in the build, `browser_check` covers the referrer rule and empty storage, and the Datenschutz page drops its exception paragraph and says nothing is stored on the device (#35).
- Home page, EN and DE: hero with the idle fish, two lanes, offers, workflow, care, FAQ with matching `FAQPage` JSON-LD and a closing call to action, all from one copy data file per page and tested against the built output (#10). The pages carry no `<base>` element, so in-page links (`#main`, `#offers`) stay on the page.
- About page, EN and DE: who I am, why one person, how I work, where, with the idle fish in a figure slot a photo can replace (#11).
- Contact page, EN and DE: mailto only with no form, script or tracking, what to put in the first email, what happens next and the company details (#12).
- The headline underline is an inline background that follows the wrapped phrase, one segment per line; headings no longer hyphenate (#10).
