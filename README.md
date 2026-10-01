# website

Cube Algos' public website (cubealgos.de): a [Jaspr](https://jaspr.site) static site in Dart,
English by default at the root and German under `/de/`. Hosting is plain static files, so the
build output is just files. The scaffold itself arrives in #4; this file is kept current as it
lands.

## Toolchain

Flutter 3.47.5 / Dart 3.13.4 via [FVM](https://fvm.app) (`.fvmrc`). Always run `fvm dart ...`.
Dart tooling only: no `just`, no shell scripts beyond the git hook stub in `tool/hooks/`.

## Scripts

| command | what it does |
| --- | --- |
| `fvm dart pub get` | Installs dependencies (`pubspec.lock` is committed). |
| `fvm dart run build_runner build` | Regenerates `lib/main.server.options.dart` (only needed after changing the entrypoint). |
| `fvm dart run jaspr_cli:jaspr serve` | Local dev server with hot reload (http://localhost:8080). |
| `fvm dart run tool/build.dart` | Static build into `build/jaspr/` (runs `jaspr build`, then prunes the build tooling's leftovers so only the deployable files remain, and adds `sitemap.xml` from the route table). |
| `fvm dart analyze` / `fvm dart format .` | Static analysis (very_good_analysis) and formatting. |
| `fvm dart test` | Unit tests plus tests over the freshly built output (builds first, takes a few seconds). |
| `fvm dart run tool/package_release.dart --tag vX.Y.Z` | Packs `build/jaspr/` into the reproducible release archive plus `.sha256` in `dist/` (what `release.yml` runs; see `docs/releasing.md`). |
| `fvm dart run tool/hooks.dart` | Installs the git hooks (`git config core.hooksPath tool/hooks`). Run once per clone: the `commit-msg` hook then rejects any subject not shaped `type(scope): description (#N)`. |

The static build starts a temporary server on port 8080 to crawl the routes, so stop `jaspr serve` before building or running the tests.

`jaspr_cli` is a dev dependency and run through `dart run`; nothing is activated globally.

## Checks

Every check is one workflow in `.github/workflows/` (GitHub-hosted `ubuntu-24.04`, verification
only, on `pull_request` and on push to `development` and `production`) and one local command.
The workflows share `.github/actions/setup`, which downloads the pinned Dart SDK 3.13.4 and
verifies its sha256 (the Dart SDK zip instead of the whole Flutter tarball: the site has no
Flutter dependency, and the zip is a fraction of the size while still pinning exactly the
Dart of Flutter 3.47.5).

| check | what it enforces | local command |
| --- | --- | --- |
| `format` | `dart format` clean | `fvm dart format --output=none --set-exit-if-changed .` |
| `analyze` | no analyzer findings (very_good_analysis), infos included | `fvm dart analyze --fatal-infos` |
| `test` | unit tests plus tests over a fresh build | `fvm dart test` |
| `build` | the static build succeeds | `fvm dart run tool/build.dart` |
| `licence-check` | pub (and npm lockfile) licences against the org policy; needs network (pub.dev) | `fvm dart run tool/licence_check.dart` |
| `html-check` | head metadata, internal links, fragments, foreign hosts (HTML and CSS, Google Fonts included), sitemap, over the built site (build first); the workflow also runs the font coverage check | `fvm dart run tool/html_check.dart`, `fvm dart run tool/fonts/check_coverage.dart build/jaspr` |
| `branch-lint` | the branch is `<family>/<N>-<slug>` (no argument: audits all local branches) | `fvm dart run tool/branch_lint.dart [branch]` |
| `lint-history` | every commit is `type(scope): description (#N)`; exempt by SHA only via `tool/commit-baseline.txt` | `fvm dart run tool/lint_history.dart` |
| `changelog-check` | `CHANGELOG.md` exists with an `Unreleased` section | `fvm dart run tool/changelog_check.dart` |

The licence gate allows MIT, Apache-2.0 (also with LLVM-exception), BSD-2/3-Clause, Unicode-3.0,
Unlicense, CC0-1.0, Zlib, ISC, PSF-2.0, BlueOak-1.0.0, MIT-0 and 0BSD; denies GPL, AGPL, LGPL,
SSPL and BUSL; and denies MPL-2.0 unless recorded in `tool/licence-exceptions.yaml`. An unknown
licence fails. Recorded exceptions and hand-verified detection gaps are printed on every run.

## Routes

`lib/src/routes.dart` is the single route table. Every page exists in both languages; the
language switch, hreflang alternates and canonical URLs all derive from it.

| page | English | German |
| --- | --- | --- |
| Home | `/` | `/de/` |
| About | `/about/` | `/de/ueber-mich/` |
| Contact | `/contact/` | `/de/kontakt/` |
| Impressum | `/impressum/` | `/de/impressum/` |
| Datenschutz | `/datenschutz/` | `/de/datenschutz/` |
| 404 | `/404.html` | `/de/404.html` |

The pages are empty shells for now (title, description, H1); content arrives in later issues.
The built HTML references only same-origin resources.

## Fonts

Onest (800 display, 400 text) and DM Mono (400) are self-hosted from `web/fonts/` (SIL OFL 1.1, licences in `web/fonts/licenses/`); the built site makes no request to Google Fonts or any other third party, and `html-check` fails if a built page or stylesheet points at one. Source, subsetting recipe and coverage check: `tool/fonts/README.md`.

## Versions

Jaspr 0.23.5 (`jaspr`, `jaspr_builder`, `jaspr_cli`, all pinned exactly). `build_runner` is held
at 2.15.1 because `jaspr_builder` 0.23.5 needs `analyzer ^12.1.0`, which newer `build_runner`
releases exclude.

## Layout

| path | what is in it |
| --- | --- |
| `lib/main.server.dart` | Server entrypoint (`mode: static` pre-renders every route). |
| `lib/app.dart` | Root component: reports all routes to the build, renders the page shell for the request path. |
| `lib/src/routes.dart` | The route table (page keys, both paths, switch target). |
| `lib/src/page_meta.dart` | Title, description and H1 per page and language. |
| `lib/src/page.dart` | The page shell (`lang`, title, description, canonical, hreflang). |
| `web/` | Static files copied into the build as is: `robots.txt`, `fonts/` (self-hosted Onest and DM Mono woff2 subsets, `fonts.css`, OFL licences in `fonts/licenses/`). |
| `test/` | Route-table unit tests and tests over the built output. |
| `tool/` | One script per check (`licence_check.dart`, `html_check.dart`, ...) with shared code in `tool/src/`, `build.dart`, `hooks.dart`, the `hooks/commit-msg` git hook (POSIX `sh`), `commit-baseline.txt` and `licence-exceptions.yaml`. |
| `.github/` | The setup action and one workflow per check. |
| `CHANGELOG.md` | Keep-a-changelog style, with an `Unreleased` section. |
| `CLAUDE.md` | Rules for working in this repo with Claude Code. |

## Contributing

Branches, commits and PRs follow the rules in `CONTRIBUTING.md` and `CLAUDE.md`.

## Licence

| part | licence | may you reuse it? |
| --- | --- | --- |
| Source code (everything in this repository except the two rows below) | Apache-2.0 + CLA, see `LICENSE`, `NOTICE`, `CLA.md` | Yes, under Apache-2.0. Contributions need a signed CLA. |
| Brand assets: everything under the vendored `web/brand/` directory (added in #6): logos, wordmark, fish, share images | All rights reserved, per `assets/LICENSE.md` of the `cubealgos/branding` repository | No. Not relicensed here. |
| Page copy: the words on the site, in any language | All rights reserved, Cube Algos UG (haftungsbeschränkt) | No. Not offered for reuse. |

The Apache-2.0 licence covers the code only, not the words or the images.
