#!/usr/bin/env python3
"""Markdown link-integrity gate for blog posts (regression guard for EYW-881).

The c3af2f2 sync sed-bug stripped `](../assets/` (and in some posts `](/assets/`)
from markdown image links, leaving broken literals like:

    ![SGLang throughput dashboardsglang-metric.png)

— no `(`, no `]`, the path fragment glued directly to the alt text. Jekyll
renders these as literal text on the live site (verified in EYW-881).

This check fails CI on that class of regression:

  1. SYNTAX — every `![alt](target)` / `[text](target)` target must be
     well-formed (URI scheme, site-root path, relative asset path, post
     permalink, in-page anchor, or sibling .md).

  2. RESIDUE — the c3af2f2 sed-bug signature: an image `![...` whose closing
     `)` carries a bare media/source path fragment with no `](` before it
     (i.e. `]` is missing or `(` is missing — both shapes from c3af2f2).
     Detected two ways:
       a. `]` + bare media path + `)`  (the `]`-kept variant), or
       b. an image label (text after `![` up to the line's final `)`)
          containing a bare path fragment ending in a media/source
          extension, where that fragment is NOT preceded by `](` — meaning
          the whole `](target)` structure was mangled.

  3. EXISTS — every relative asset target (`../assets/...`, `/assets/...`,
     `./assets/...`) must exist on disk in the repo. A missing asset = a
     broken image source that will 404 live.

Front-matter blocks (between the leading `---` pair) are excluded: the
`image:`/`permalink:` fields there are YAML, not markdown link syntax.

Fenced code blocks and inline code spans are masked before matching so that
link syntax shown as documentation does not false-positive.

Usage: python3 check_link_integrity.py   (from anywhere; paths resolve
relative to this file's directory). Exits 1 on any finding.
"""
import re, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent
POSTS = ROOT / "_posts"

FENCE_RE = re.compile(r"^\s*(```|~~~)")
# Well-formed link target: `![alt](target)` / `[text](target)` — target is
# paren-free, whitespace-trimmed.
LINK_RE = re.compile(r"(!?)\[[^\[\]]*\]\(\s*([^()]*?)\s*\)")
# c3af2f2 residue shape (a): `]` kept, `(` stripped — `]` glued to a bare
# media/source path fragment, closed by `)`. A well-formed `](target)` has
# `(` immediately after `]` and can never match this.
RESIDUE_CLOSE_RE = re.compile(
    r"\]"
    r"[A-Za-z0-9._/-]*\.(?:png|jpe?g|svg|gif|html?|mmd|mm|plantuml|puml|d2|json|ya?ml|py|ts|tsx|js|css|md|txt|csv|sh)"
    r"\)"
)
# c3af2f2 residue shape (b): both `]` AND `(` stripped — the line contains
# `![` followed by a label and a closing `)` with NO `]` between them (the
# well-formed `![alt](target)` always has `]` before `(`). The label of the
# broken form carries a bare media/source path fragment. Front-matter `image:`
# lines have no `![` so are unaffected.
IMG_NO_BRACKET_RE = re.compile(r"!\[([^\[\]\n]*)\)")
MEDIA_EXT_RE = re.compile(
    r"[A-Za-z0-9._/-]*\.(?:png|jpe?g|svg|gif|html?|mmd|mm|plantuml|puml|d2|json|ya?ml|py|ts|tsx|js|css|md|txt|csv|sh)"
)
KNOWN_PREFIXES = (
    "http://", "https://", "mailto:", "tel:", "ftp://", "data:",
)


def strip_front_matter(text: str) -> str:
    """Return the post body with a leading `---` front-matter block removed
    (length-preserved so line numbers survive)."""
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return text
    end = next((i for i, l in enumerate(lines[1:], 1) if l.strip() == "---"), None)
    if end is None:
        return text
    kept = lines[:1] + [" " * len(l) for l in lines[1:end]] + lines[end + 1:]
    return "\n".join(kept)


def mask_code(text: str) -> str:
    """Blank out fenced code blocks and inline code spans (length-preserving)
    so link regexes skip documentation examples but line numbers survive."""
    lines = text.split("\n")
    out = []
    in_fence = False
    for line in lines:
        if FENCE_RE.match(line):
            in_fence = not in_fence
            out.append(" " * len(line))
            continue
        if in_fence:
            out.append(" " * len(line))
            continue
        parts, in_code = [], False
        for ch in line:
            if ch == "`":
                in_code = not in_code
                parts.append(" ")
            else:
                parts.append(" " if in_code else ch)
        out.append("".join(parts))
    return "\n".join(out)


def target_is_wellformed(t: str) -> bool:
    if t.startswith(KNOWN_PREFIXES):
        return True
    if t.startswith("/"):                       # site-root absolute
        return True
    if t.startswith("#"):                       # in-page anchor
        return True
    if re.match(r"^(?:\.\.?/)[\w./-]+$", t):   # ./x, ../assets/x
        return True
    if re.match(r"^[\w-]+\.md$", t):           # sibling post cross-link
        return True
    return False


def resolve_asset(target: str) -> pathlib.Path | None:
    """Repo path for a relative asset target, else None."""
    if target.startswith("/assets/"):
        return ROOT / target.lstrip("/")
    if target.startswith("../"):
        # posts serve from /YYYY-MM-DD/ at site root; ../assets -> /assets
        return ROOT / target[len("../"):]
    if target.startswith("./"):
        return ROOT / target[2:]
    return None


def main() -> int:
    if not POSTS.is_dir():
        print(f"ERROR: {POSTS} not found", file=sys.stderr)
        return 2
    errors = 0
    for md in sorted(POSTS.glob("*.md")):
        text = md.read_text(encoding="utf-8", errors="replace")
        masked = mask_code(strip_front_matter(text))
        post_errors = []

        # Spans of well-formed links — residue matches inside them are
        # genuine targets, not mangled residue.
        link_spans = [m.span() for m in LINK_RE.finditer(masked)]

        def in_a_link(pos: int) -> bool:
            return any(ls <= pos < le for ls, le in link_spans)

        for line_no, raw in enumerate(masked.split("\n"), 1):
            for m in LINK_RE.finditer(raw):
                bang, target = m.group(1), m.group(2)
                kind = "image" if bang else "link"
                if not target_is_wellformed(target):
                    post_errors.append(
                        f"line {line_no}: {kind} target not well-formed: {target!r}"
                    )
                    continue
                resolved = resolve_asset(target)
                if resolved is not None and not resolved.is_file():
                    post_errors.append(
                        f"line {line_no}: referenced asset not found: {target}"
                    )

            # residue shape (a): `]<media-path>)`
            for rm in RESIDUE_CLOSE_RE.finditer(raw):
                if in_a_link(rm.start()):
                    continue
                post_errors.append(
                    f"line {line_no}: broken markdown link residue "
                    f"(c3af2f2 sed-bug, missing '('): "
                    f"{raw[max(0, rm.start() - 30):rm.end()]!r}"
                )

            # residue shape (b): '![label)' with no ']' between '!' and ')'
            # — both ']' and '(' were stripped (c3af2f2). A well-formed
            # image '![alt](target)' always has ']' before '(' so this
            # pattern cannot match it.
            for bm in IMG_NO_BRACKET_RE.finditer(raw):
                label = bm.group(1)
                if MEDIA_EXT_RE.search(label):
                    post_errors.append(
                        f"line {line_no}: broken markdown image (c3af2f2 "
                        f"sed-bug, missing '](' link syntax): "
                        f"{raw[max(0, bm.start() - 5):bm.end()]!r}"
                    )

        if post_errors:
            errors += 1
            print(f"  {md.name}:")
            for e in post_errors:
                print(f"    {e}")

    if errors:
        print(f"link-integrity: {errors} post(s) with findings")
        return 1
    print("link-integrity: all post links OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
