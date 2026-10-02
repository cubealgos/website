# Fonts

The site self-hosts three Latin + German woff2 subsets in `web/fonts/` (privacy notice: no
request to a third party). All are SIL OFL 1.1 without a Reserved Font Name; the licence files
with the upstream copyright lines are in `web/fonts/licenses/`.

| file | face | use | source file in `google/fonts` | source sha256 |
| --- | --- | --- | --- | --- |
| `onest-800.woff2` | Onest ExtraBold | display (preloaded) | `ofl/onest/Onest[wght].ttf`, instanced to wght=800 | `966c5c29b4755da84b6854d5c21dd4eaa2420225d0e9874de602de176d4a9f31` |
| `onest-400.woff2` | Onest Regular | text | same file, instanced to wght=400 | same |
| `dm-mono-400.woff2` | DM Mono Regular | labels, code | `ofl/dmmono/DMMono-Regular.ttf` | `55b4c98f123daebb3ed27947ba47b2af00554fc6284d639a540bcef5e6258ad2` |

Upstream: <https://github.com/google/fonts> at commit
`9710da1eacb3be272583c3224dcb70f9da6eadbb` (2026-10-01). Upstream ships Onest only as the
variable font, so the two weights are instanced (the same `varLib.instancer` command the
`cubealgos/branding` repo uses for its wordmark source) and then subset.

## Variable or static

Static instances won: 9,192 + 9,364 = 18,556 bytes for Onest 400 and 800 against 20,568 bytes
for one variable subset (the variable file keeps the `gvar` deltas for every weight between
100 and 900, the site uses two). The static pair also needs no `font-weight: 400 800` range
and matches the file names in the issue; the cost is one more request, which is negligible
next to 2 KB, and only the 800 face is on the critical path (preloaded).

## Rebuild

Build-time only; fontTools (MIT) and brotli are not dependencies of the site.

```sh
python3 -m venv /tmp/fonts-venv && /tmp/fonts-venv/bin/pip install fonttools==4.66.1 brotli
git clone --filter=blob:none --sparse https://github.com/google/fonts.git /tmp/gf
git -C /tmp/gf checkout 9710da1eacb3be272583c3224dcb70f9da6eadbb
git -C /tmp/gf sparse-checkout set ofl/onest ofl/dmmono
PATH=/tmp/fonts-venv/bin:$PATH python3 tool/fonts/subset.py /tmp/gf
```

The script runs `fonttools varLib.instancer 'Onest[wght].ttf' wght=<w> --update-name-table`
and `pyftsubset --flavor=woff2 --no-hinting --desubroutinize
--layout-features=kern,liga,calt,ccmp,locl,mark,mkmk` with these unicodes (see `UNICODES` in
the script): U+0020-007E, U+00A0, § (U+00A7), U+00A9, U+00B7, Ä Ö Ü ä ö ü ß, × (U+00D7), – —, ‘ ’ ‚ “ ” „,
… and €. It then rewrites `tool/fonts/coverage.json`.

## Coverage check

There is no Dart woff2 reader, so `coverage.json` is generated from each face's cmap by
`subset.py` and holds the codepoint list and sha256 of every woff2. The check
(`fvm dart run tool/fonts/check_coverage.dart [file or dir]...`) fails when a woff2 differs
from its manifest entry, when a face lacks a codepoint of the subset spec, or when a `.md` or
`.html` file given as an argument contains a character outside the spec. CI runs it over
`build/jaspr` (the page copy as built). The brand copy lives in a private vault, so CI cannot
read it; run it locally against it too:
`fvm dart run tool/fonts/check_coverage.dart <vault>/projects/cubealgos_brand/copy`.
