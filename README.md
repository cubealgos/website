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
| `fvm dart run tool/hooks.dart` | Installs the git hooks (`git config core.hooksPath tool/hooks`). Run once per clone: the `commit-msg` hook then rejects any subject not shaped `type(scope): description (#N)`. |

## Layout

| path | what is in it |
| --- | --- |
| `tool/hooks/` | Git hooks (POSIX `sh`): `commit-msg`. |
| `tool/hooks.dart` | The hook installer. |
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
