# Contributing

`website` is Cube Algos' public website (Jaspr static, English and German). It is developed with
GitHub issues; see `CLAUDE.md` for the full branch, worktree, commit and PR rules. This file
covers how to contribute.

## Before you start

- **Sign the CLA**: required before a first PR is merged, see `CLA.md`. This keeps the project
  open while preserving the Maintainer's ability to relicense. Apache-2.0 + CLA is the licence
  for the code; the page copy and brand assets are not contributed to or offered for reuse (see
  `NOTICE`).
- **Open an issue first** for anything non-trivial. Small fixes and docs can go straight to a PR.
- **Work on a branch, in its own worktree**: never commit directly to `development` or
  `production`. Branches are `<family>/<N>-<slug>` with family one of `feature`, `bugfix`,
  `chore`, `documentation`, `release` (from `development`) or `hotfix` (from `production`).
- **Keep the scope tight.** One PR, one issue, one concern.

## Commit and PR conventions

Commits follow Conventional Commits with a required scope and issue reference:
`type(scope): description (#N)`, type one of `feat fix docs style refactor perf test build ci
chore revert merge release`. A PR title is a conforming commit subject ending `(#N)`, and the
body carries the issue's acceptance-criteria checklist and says how the change was verified.
Merges are plain merges (no squash, no rebase-merge).

## Security

Do not report a suspected vulnerability in a public issue or PR: see `SECURITY.md`.
