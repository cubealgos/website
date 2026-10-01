#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Rebuilds web/fonts/*.woff2 and tool/fonts/coverage.json from upstream.

Usage: subset.py <google/fonts checkout> [--variable]
Needs fontTools 4.66.1 and brotli (build-time only, see README.md). The default
output is two static Onest instances (wght=400 and wght=800), each subset;
--variable instead writes one variable subset (onest.woff2), only used for the
size comparison the README records.
"""
import hashlib, json, subprocess, sys, tempfile
from pathlib import Path

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "web" / "fonts"

# Latin + German. Keep in sync with README.md and check_coverage.dart.
UNICODES = (
    "U+0020-007E,U+00A0,U+00A9,U+00B7,U+00C4,U+00D6,U+00DC,U+00DF,U+00E4,"
    "U+00F6,U+00FC,U+00D7,U+2013,U+2014,U+2018,U+2019,U+201A,U+201C,U+201D,"
    "U+201E,U+2026,U+20AC"
)


def run(*args):
    subprocess.run([str(a) for a in args], check=True)


def subset(src, dest):
    run("pyftsubset", src, f"--unicodes={UNICODES}", "--flavor=woff2",
        "--layout-features=kern,liga,calt,ccmp,locl,mark,mkmk",
        "--no-hinting", "--desubroutinize", f"--output-file={dest}")


def main():
    gf = Path(sys.argv[1])
    static = "--variable" not in sys.argv
    OUT.mkdir(parents=True, exist_ok=True)
    onest = gf / "ofl/onest/Onest[wght].ttf"
    mono = gf / "ofl/dmmono/DMMono-Regular.ttf"
    faces = {}
    if static:
        with tempfile.TemporaryDirectory() as tmp:
            for w in (400, 800):
                inst = Path(tmp) / f"Onest-{w}.ttf"
                run("fonttools", "varLib.instancer", onest, f"wght={w}",
                    "-o", inst, "--update-name-table")
                subset(inst, OUT / f"onest-{w}.woff2")
                faces[f"onest-{w}.woff2"] = None
    else:
        subset(onest, OUT / "onest.woff2")
        faces["onest.woff2"] = None
    subset(mono, OUT / "dm-mono-400.woff2")
    faces["dm-mono-400.woff2"] = None
    manifest = {"unicodes": UNICODES, "faces": {}}
    for name in faces:
        data = (OUT / name).read_bytes()
        cmap = TTFont(OUT / name).getBestCmap()
        manifest["faces"][name] = {
            "sha256": hashlib.sha256(data).hexdigest(),
            "bytes": len(data),
            "codepoints": sorted(cmap),
        }
    (ROOT / "tool/fonts/coverage.json").write_text(
        json.dumps(manifest, indent=1) + "\n")


main()
