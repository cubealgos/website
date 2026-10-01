# Releasing

The site is released as a tagged archive; nothing is deployed from this repo. The server
(`cubealgos_server`, recipe `just deploy-website <tag>`) pulls the archive on demand. A failed
release workflow gates nothing: it is a new bug issue.

1. Branch `release/<N>-X.Y.Z` from `development` (in a worktree).
2. Bump `version:` in `pubspec.yaml` to `X.Y.Z` and turn the `Unreleased` entries of
   `CHANGELOG.md` into a `## X.Y.Z` section (leave a fresh empty `## Unreleased` above it).
3. Open a PR titled `release(site): X.Y.Z (#N)`; plain merge into `production`.
4. Tag the merge commit on `production`: `git tag -a vX.Y.Z -m vX.Y.Z && git push origin vX.Y.Z`.
5. Merge `production` back into `development` (`merge(site): production into development (#N)`).

Pushing the tag runs `.github/workflows/release.yml` (GitHub-hosted `ubuntu-24.04`, default
`GITHUB_TOKEN` only, `contents: write` on the release job only). It rebuilds the site from the
tag, refuses a tag that is not `vX.Y.Z` or does not equal the `pubspec.yaml` version or has no
non-empty `CHANGELOG.md` section, then creates the GitHub release (notes = that CHANGELOG
section; a tag with a `-suffix` is marked pre-release) with two assets:

- `site-vX.Y.Z.tar.gz`: the contents of `build/jaspr/` at the top level (`index.html`, `de/`,
  `brand/`, `fonts/`, ...), so it unpacks straight into a versioned directory.
- `site-vX.Y.Z.tar.gz.sha256`: `<hash>  site-vX.Y.Z.tar.gz`, verify with
  `shasum -a 256 -c site-vX.Y.Z.tar.gz.sha256`.

The workflow refuses a tag whose commit is not on `production`, so a stray tag on another branch fails instead of publishing a release.

## Reproducibility

The archive is built by `tool/package_release.dart`: entries sorted bytewise, every mtime the
tagged commit's time, owner and group 0, a fixed gzip header (no filename, no timestamp).
Rebuilding the same tag yields the same sha256. To check locally without a tag:

```sh
fvm dart run tool/build.dart
fvm dart run tool/package_release.dart --tag v$(sed -n 's/^version: //p' pubspec.yaml) --mtime 0
```

(needs a `## <version>` section in `CHANGELOG.md`; `--mtime` defaults to the HEAD commit time).
