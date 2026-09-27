#!/usr/bin/env python3
"""Pre-commit validator for blog posts.

Catches three classes of defects:
  1. Invisible characters (NBSP, ZWS, etc.) that break CommonMark pipe alignment
  2. Tables touching headings/fences without a blank line separator
  3. Broken or incomplete front matter — Jekyll silently drops the whole block
     on a YAML parse error (losing layout/title/date, which on GitHub Pages
     makes the post URL fall back to the build-time mtime)
"""
import re, sys, os, pathlib

POSTS = pathlib.Path(__file__).parent / "_posts"
try:
    import yaml
except ImportError:
    yaml = None
INVISIBLE_RE = re.compile(
    r"[\u00a0\u200b\u202b\u202c\u202d\u202e\u2060\ufeff]"
)
TABLE_ROW_RE = re.compile(r"^\s*\|")
HEADING_RE = re.compile(r"^#{1,6}\s")
FENCE_RE = re.compile(r"^```")
HR_RE = re.compile(r"^---{3,}$")

errors = 0

for md in sorted(POSTS.glob("*.md")):
    text = md.read_bytes().decode("utf-8", errors="replace")
    lines = text.splitlines()

    # ── 1. Invisible characters ──────────────────────────────────
    bad_lines = [
        i + 1
        for i, line in enumerate(lines)
        if INVISIBLE_RE.search(line)
    ]
    if bad_lines:
        errors += 1
        print(f"  {md.name}: invisible chars on line(s) {bad_lines[:5]}")
        if len(bad_lines) > 5:
            print(f"    ... and {len(bad_lines)-5} more")

    # ── 2. Table-block boundary violations ────────────────────────
    for i, line in enumerate(lines):
        if not TABLE_ROW_RE.match(line):
            continue
        # Next non-blank line must also be a table row or a separator
        for j in range(i + 1, len(lines)):
            next_line = lines[j]
            if not next_line.strip():
                continue  # blank lines are OK — but we want at least one
            # If next non-blank line is heading/fence/HR and there was NO
            # blank line between them, that's a boundary violation.
            blank_between = any(not lines[k].strip() for k in range(i + 1, j))
            if not blank_between:
                if HEADING_RE.match(next_line):
                    errors += 1
                    print(f"  {md.name}: table row {i+1} directly before heading line {j+1} (no blank line)")
                elif FENCE_RE.match(next_line):
                    errors += 1
                    print(f"  {md.name}: table row {i+1} directly before fence line {j+1} (no blank line)")
            break

# ── 3. Front matter sanity ───────────────────────────────────────────
if yaml is None:
    print("  note: PyYAML not available — front-matter YAML check skipped")
else:
    FM_RE = re.compile(r"^---\n(.*?)\n---\n", re.S)
    for md in sorted(POSTS.glob("*.md")):
        m = FM_RE.match(md.read_text())
        if not m:
            errors += 1
            print(f"  {md.name}: missing front matter block")
            continue
        try:
            data = yaml.safe_load(m.group(1))
            if not isinstance(data, dict):
                errors += 1
                print(f"  {md.name}: front matter is not a mapping")
                continue
            for key in ("title", "date"):
                if key not in data:
                    errors += 1
                    print(f"  {md.name}: front matter missing required key '{key}' "
                          f"(Jekyll falls back to mtime/dateless URL)")
        except yaml.YAMLError as e:
            errors += 1
            print(f"  {md.name}: front matter YAML parse error: {str(e).splitlines()[0]}")

if errors:
    sys.exit(1)