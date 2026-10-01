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
| `fvm dart run tool/build.dart` | Static build into `build/jaspr/` (runs `jaspr build`, then prunes the build tooling's leftovers so only the deployable files remain). Plain `fvm dart run jaspr_cli:jaspr build` works too. |
| `fvm dart analyze` / `fvm dart format .` | Static analysis (very_good_analysis) and formatting. |
| `fvm dart test` | Unit tests plus tests over the freshly built output (builds first, takes a few seconds). |
| `fvm dart run tool/hooks.dart` | Installs the git hooks (`git config core.hooksPath tool/hooks`). Run once per clone: the `commit-msg` hook then rejects any subject not shaped `type(scope): description (#N)`. |

`jaspr_cli` is a dev dependency and run through `dart run`; nothing is activated globally.

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
| `web/` | Static files copied into the build as is (`robots.txt` for now). |
| `test/` | Route-table unit tests and tests over the built output. |
| `tool/` | `build.dart`, `hooks.dart` and the `hooks/commit-msg` git hook (POSIX `sh`). |
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
