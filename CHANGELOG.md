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
