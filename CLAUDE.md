# CLAUDE.md — website

Cube Algos' public website (cubealgos.de): a Jaspr **static** site, German at the root and
English under `/en/`. Public repo: no secrets and no personal data beyond the legal facts the Impressum
publishes by law (`lib/src/legal_facts.dart`: company, address, managing director, register,
VAT ID, email, phone) (see `NOTICE`).

## Read this before you do that

| about to… | read first |
| --- | --- |
| install the git hooks | `README.md` Scripts: `fvm dart run tool/hooks.dart` (once per clone) |
| start work on an issue | Branches below: new worktree, never the main checkout |
| add a dependency | its licence must be on the allow list of the licence gate (`tool/licence_check.dart`, added in #5); copyleft is denied |
| add a post | `content/README.md`: one Markdown file per post and language, validated at build time; a post's links are the allow-listed outbound links |
| name wearenotabank, or stop naming it | one switch, `namesProduct` in `lib/src/outbound.dart` (brand decisions 58 and 59; the constraints D1 to D10 of wearenotabank `DEC-082`): flip it, re-run `fvm dart run tool/og_images.dart`, and `product_state_test.dart` shows what the other state looks like |
| touch brand assets or page copy | they are all rights reserved, not covered by Apache-2.0 (`NOTICE`, README "Licence") |

## Toolchain

Flutter 3.47.5 / Dart 3.13.4 via FVM (`.fvmrc`): always `fvm dart ...`. CI uses **GitHub-hosted
runners only** (`runs-on: ubuntu-24.04`), never the org's self-hosted runner: fork PRs on a
public repo could run code on the server. CI is verification only, on push to `development` and
`production` and on `pull_request`; deployment is a separate release workflow on a tag and
gates nothing.

## Branches and issues

Two long-lived branches: `production` (releasable) and `development` (integration, default).
Both are merge-only: never push to either directly. Every working branch is `<family>/<N>-<slug>`
(`N` = GitHub issue number), family one of `feature/` `bugfix/` `chore/` `documentation/`
`release/` (from `development`) or `hotfix/` (from `production`).

Every working branch lives in its own worktree at `.worktrees/<N>/`
(`git worktree add --relative-paths .worktrees/<N> -b <family>/<N>-<slug> origin/development`).
The main checkout stays parked on `development`. `.worktrees/` is gitignored. **`git stash` is
forbidden**: use a worktree or a WIP commit. Rebase freely before a PR exists; once a PR is
open, only `git merge development` into the branch.

1 PR = 1 issue. The PR title is a conforming commit subject ending `(#N)`; the body carries the
issue's acceptance-criteria checklist. **Plain merge only** (never squash, never rebase-merge).
Kevin reviews and merges; nobody else closes issues or changes repo settings.

## Commits

`type(scope): description (#N)`: type and scope both required, type one of `feat fix docs style
refactor perf test build ci chore revert merge release`; no exemption for merge or release
commits (`merge(<scope>): <branch> into <target> (#N)`). Enforced locally by
`tool/hooks/commit-msg` after `fvm dart run tool/hooks.dart`.

## Licence

Code: **Apache-2.0 + CLA** (`LICENSE`, `NOTICE`, `CLA.md`); code files carry
`SPDX-License-Identifier: Apache-2.0`. Brand assets (everything under `web/brand/`, vendored
from `cubealgos/branding`) and page copy are all rights reserved and carry no SPDX header.
