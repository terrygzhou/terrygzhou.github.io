#!/usr/bin/env python3
"""Validator for social-card (og/twitter) image metadata.

Checks:
  1. Every post `image:` front-matter value points at a file that exists under
     assets/ (site-root-absolute path, as Jekyll's absolute_url expects).
  2. Every `image:` value has a size entry in assets/og-image-sizes.json AND
     in _config.yml's og_image_sizes map (the key head-custom.html looks up).
  3. Recorded sizes match the actual file dimensions (PIL for raster;
     viewBox parsing for SVG).

Run plain to check; `--write` regenerates assets/og-image-sizes.json and the
og_image_sizes block in _config.yml from the real file dimensions.

Exit code 1 on any mismatch — wire into pre-commit / CI like validate_posts.py.
"""
import json, pathlib, re, sys, subprocess, sys, os, pathlib
try:
    import yaml
except ImportError:
    yaml = None

ROOT = pathlib.Path(__file__).parent
POSTS = ROOT / "_posts"
SIZES_JSON = ROOT / "assets" / "og-image-sizes.json"
CONFIG = ROOT / "_config.yml"
HEAD = ROOT / "_includes" / "head-custom.html"

def fm_image(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m or yaml is None:
        return None
    data = yaml.safe_load(m.group(1))
    return data.get("image") if isinstance(data, dict) else None

def svg_dims(path):
    t = path.read_text(errors="replace")
    m = re.search(r'viewBox="([^"]+)"', t)
    if m:
        p = m.group(1).split()
        if len(p) == 4:
            return int(round(float(p[2]))), int(round(float(p[3])))
    m = re.search(r'\bwidth="(\d+)"', t) and re.search(r'\bheight="(\d+)"', t)
    if m:
        return int(re.search(r'\bwidth="(\d+)"', t).group(1)), int(re.search(r'\bheight="(\d+)"', t).group(1))
    return None

def raster_dims(path):
    from PIL import Image
    with Image.open(path) as im:
        return im.size

def get_dims(path):
    if path.suffix.lower() == ".svg":
        return svg_dims(path)
    if path.suffix.lower() in (".png", ".jpg", ".jpeg", ".webp", ".gif"):
        return raster_dims(path)
    return None

def config_entries():
    if yaml is None:
        return {}
    cfg = yaml.safe_load(CONFIG.read_text())
    return cfg.get("og_image_sizes") or {}

def check(write):
    errors = []
    posts = sorted(POSTS.glob("*.md"))
    used = {}
    for md in posts:
        text = md.read_text()
        img = fm_image(text)
        if img is None:
            continue
        # 1. path shape + file existence
        if not img.startswith("/assets/"):
            errors.append(f"{md.name}: image: {img!r} is not a root-absolute /assets/ path")
        p = ROOT / img.lstrip("/")
        if not p.exists():
            errors.append(f"{md.name}: image: {img} does not exist in repo")
            continue
        used[img] = p

    sizes = json.loads(SIZES_JSON.read_text()) if SIZES_JSON.exists() else {}
    cfg = config_entries()

    # 2. every used image is in both registries, and the two agree
    for img in used:
        if img not in sizes:
            errors.append(f"assets/og-image-sizes.json missing key {img}")
        if img not in cfg:
            errors.append(f"_config.yml og_image_sizes missing key {img}")
        elif sizes.get(img) and dict(sizes.get(img, {})) != {k: v for k, v in cfg[img].items() if k in ("width", "height")}:
            errors.append(f"size registry disagree for {img}: json={sizes[img]} vs config={cfg[img]}")

    # 3. recorded sizes match real file dimensions
    for img, p in used.items():
        real = get_dims(p)
        rec = sizes.get(img) or cfg.get(img) or {}
        if real and rec:
            if rec.get("width") != real[0] or rec.get("height") != real[1]:
                errors.append(f"{img}: recorded {rec.get('width')}x{rec.get('height')} != actual {real[0]}x{real[1]}")

    if write:
        if yaml is None:
            print("note: PyYAML missing; skipping _config.yml write")
        new_sizes = {}
        for img in sorted(set(list(sizes.keys()) + list(used.keys()))):
            p = ROOT / img.lstrip("/")
            dims = get_dims(p) if p.exists() else None
            if dims:
                new_sizes[img] = {"width": dims[0], "height": dims[1]}
        SIZES_JSON.write_text(json.dumps(new_sizes, indent=2) + "\n")
        print(f"wrote {SIZES_JSON.name} with {len(new_sizes)} entries")
        if yaml is not None:
            cfg_text = CONFIG.read_text()
            entries = []
            for k, v in new_sizes.items():
                if isinstance(v, dict) and "note" in v:
                    entries.append(f"  {k}:\n    width: {v['width']}\n    height: {v['height']}")
                else:
                    entries.append(f"  {k}: {{ width: {v['width']}, height: {v['height']} }}")
            block = "og_image_sizes:\n" + "\n".join(entries) + "\n"
            m = re.search(r"^og_image_sizes:.*?(?=^\S|\Z)", cfg_text, re.M | re.S)
            if m:
                CONFIG.write_text(cfg_text[:m.start()] + block + cfg_text[m.end():])
            else:
                CONFIG.write_text(cfg_text + "\n" + block)
            print(f"wrote og_image_sizes block ({len(new_sizes)} entries) into _config.yml")

    for e in errors:
        print("  FAIL:", e)
    if errors:
        print(f"\n{len(errors)} problem(s) in og/twitter image metadata")
        return 1
    print(f"og meta OK: {len(used)} post image(s) verified against assets + registries")
    return 0

if __name__ == "__main__":
    sys.exit(check(write="--write" in sys.argv))
