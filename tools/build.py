"""
build.py — Python wrapper สำหรับ build pipeline ของ
ใช้ darklua ในการ bundle + minify (เหมือน build/build.sh)

Usage:
    python tools/build.py    
    python tools/build.py --dev   
    python tools/build.py --check 
    python tools/build.py --pkg

Requirements:
    - darklua (https://darklua.com) 
    - Node.js 
       --no-node for skip header
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC_ENTRY = ROOT / "src" / "Init.lua"
DIST_DIR = ROOT / "dist"
OUTPUT = DIST_DIR / "main.lua"
TEMP = DIST_DIR / "temp.lua"
PACKAGE_JSON = ROOT / "package.json"
PACKAGE_LUA = ROOT / "build" / "package.lua"
HEADER_TPL = ROOT / "build" / "header.lua"
CONFIG_BUILD = ROOT / "build" / "darklua.config.json"
CONFIG_DEV = ROOT / "build" / "darklua.dev.config.json"


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #

def read_package() -> dict:
    if not PACKAGE_JSON.is_file():
        raise FileNotFoundError(f"package.json not found at {PACKAGE_JSON}")
    return json.loads(PACKAGE_JSON.read_text(encoding="utf-8"))


def generate_package_lua(pkg: dict) -> None:
    """Re-generate build/package.lua from package.json."""
    content = (
        "-- Generated from package.json | build/build.sh\n\n"
        "return [[\n"
        + json.dumps(pkg, indent=2)
        + "\n]]\n"
    )
    PACKAGE_LUA.write_text(content, encoding="utf-8")
    print(f"  Generated build/package.lua  (v{pkg.get('version', '?')})")


def render_header(pkg: dict) -> str:
    if not HEADER_TPL.is_file():
        return ""
    tpl = HEADER_TPL.read_text(encoding="utf-8")
    replacements = {
        "{{VERSION}}": pkg.get("version", "0.0.0"),
        "{{BUILD_DATE}}": date.today().isoformat(),
        "{{DESCRIPTION}}": pkg.get("description", ""),
        "{{REPOSITORY}}": pkg.get("repository", ""),
        "{{DISCORD}}": pkg.get("discord", ""),
        "{{LICENSE}}": pkg.get("license", "MIT"),
        "{{AUTHOR}}": pkg.get("author", ""),
    }
    for k, v in replacements.items():
        tpl = tpl.replace(k, str(v))
    return tpl


DARKLUA_BIN = ROOT / "darklua" / "darklua.exe"


def run_darklua(input_path: Path, output_path: Path, config: Path) -> bool:
    """Run darklua process; return True on success."""
    exe = str(DARKLUA_BIN) if DARKLUA_BIN.is_file() else "darklua"
    cmd = [exe, "process", str(input_path), str(output_path), "--config", str(config)]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print("[ × ] darklua failed:", file=sys.stderr)
        print(result.stderr or result.stdout, file=sys.stderr)
        return False
    return True


# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #

def main() -> int:
    parser = argparse.ArgumentParser(description="Build into dist/main.lua via darklua.")
    parser.add_argument("--dev", action="store_true", help="Dev build: bundle only, no minification")
    parser.add_argument("--check", action="store_true", help="Fail if dist/main.lua is missing")
    parser.add_argument("--pkg", action="store_true", help="Only regenerate build/package.lua")
    args = parser.parse_args()

    pkg = read_package()

    # Always keep build/package.lua in sync
    generate_package_lua(pkg)

    if args.pkg:
        return 0

    if args.check:
        if not OUTPUT.is_file():
            print("dist/main.lua is missing; run python tools/build.py", file=sys.stderr)
            return 1
        print(f"dist/main.lua exists (v{pkg.get('version', '?')}).")
        return 0

    config = CONFIG_DEV if args.dev else CONFIG_BUILD
    mode_label = "DEV" if args.dev else "BUILD"

    if not SRC_ENTRY.is_file():
        print(f"[ × ] Entry point not found: {SRC_ENTRY}", file=sys.stderr)
        return 1
    if not config.is_file():
        print(f"[ × ] darklua config not found: {config}", file=sys.stderr)
        return 1

    DIST_DIR.mkdir(parents=True, exist_ok=True)

    print(f"\n[ {mode_label} ] Running darklua...")
    ok = run_darklua(SRC_ENTRY, TEMP, config)
    if not ok:
        TEMP.unlink(missing_ok=True)
        return 1

    header = render_header(pkg)
    bundled = TEMP.read_text(encoding="utf-8")
    TEMP.unlink(missing_ok=True)

    OUTPUT.write_text(header + "\n" + bundled, encoding="utf-8")

    size_kb = OUTPUT.stat().st_size // 1024
    print(f"[ ✓ ] build completed")
    print(f"[ > ] Version  : {pkg.get('version', '?')}")
    print(f"[ > ] Mode     : {mode_label}")
    print(f"[ > ] Size     : {size_kb} KB")
    print(f"[ > ] Output   : {OUTPUT}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
