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
- UI motion, "Draw, then press": button press and hover, the amber underline drawn once, text rise with stagger, and the home sting once per session (still under reduced motion), all from the brand tokens; CI rejects duration/easing literals and non-`transform`/`opacity` animation, and `browser_check` covers the motion behaviour in headless Chrome (#9).
- Favicon set (SVG, `.ico`, apple-touch) and `site.webmanifest` (written by the build, paper token colours) linked from every page head; `html-check` fails on missing icon links, a missing manifest or a missing icon file (#31).
- Impressum in German and English (§ 5 DDG facts, liability for content and links), rendered from a small legal-page model with the facts in one file; the English page states the German text is authoritative; the font subsets gain § (U+00A7) (#15).
- Datenschutz in German and English: hosting (STRATO), no access logs and no IP storage, no cookies, tracking or analytics, self-hosted fonts, contact by `mailto:` (mailbox by Proton), rights and the LDI NRW; a built-output test pins every statement and the claims it makes (#16).
