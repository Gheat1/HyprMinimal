#!/usr/bin/env python3
"""Generate a set of dark minimalist gradient wallpapers (2560x1600).

Pure gradients only — linear sweeps and soft radial glows, warm stone tint,
subtle grain to prevent OLED banding. Deterministic: same output every run.
"""
import os
import numpy as np
from PIL import Image

W, H = 2560, 1600
OUT = os.path.expanduser("~/.local/share/wallpapers/minimal")
os.makedirs(OUT, exist_ok=True)

rng = np.random.default_rng(7)

def grain(img, amount=2.0):
    """Warm-stone tint + subtle grain to kill gradient banding on OLED."""
    n = rng.normal(0, amount, (H, W, 1)).astype(np.float32)
    a = np.asarray(img).astype(np.float32) * np.array([1.0, 0.985, 0.955], np.float32) + n
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8))

def coords():
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    return x / W, y / H

def to_img(v, lo, hi):
    """v in 0..1 -> grayscale image between shades lo..hi (ints)."""
    a = (lo + (hi - lo) * np.clip(v, 0, 1)).astype(np.uint8)
    return Image.fromarray(np.dstack([a, a, a]))

def glow(cx, cy, spread):
    """Soft radial glow centred at (cx, cy), aspect-corrected."""
    d2 = (x - cx) ** 2 + ((y - cy) * (H / W)) ** 2
    return np.exp(-d2 / spread)

x, y = coords()

# 1) drift — diagonal sweep, top-left dark to bottom-right mid
v = (0.62 * x + 0.38 * y) ** 1.3
grain(to_img(v, 5, 56)).save(f"{OUT}/01-drift.png")

# 2) dawn — vertical, light rising from the bottom
v = (y ** 2.2)
grain(to_img(v, 5, 62)).save(f"{OUT}/02-dawn.png")

# 3) dusk — vertical, light fading down from the top
v = ((1 - y) ** 2.2)
grain(to_img(v, 5, 62)).save(f"{OUT}/03-dusk.png")

# 4) hearth — soft glow anchored in the bottom-left corner
v = glow(0.12, 0.95, 0.16)
grain(to_img(v, 4, 66)).save(f"{OUT}/04-hearth.png")

# 5) ember — soft glow anchored in the top-right corner
v = glow(0.88, 0.08, 0.16)
grain(to_img(v, 4, 66)).save(f"{OUT}/05-ember.png")

# 6) slate — horizontal sweep, left dark to right mid
v = (x ** 1.6)
grain(to_img(v, 5, 52)).save(f"{OUT}/06-slate.png")

# 7) vale — gentle centre glow, dark vignette edges
v = glow(0.5, 0.52, 0.22)
grain(to_img(v, 4, 48)).save(f"{OUT}/07-vale.png")

print("\n".join(sorted(f for f in os.listdir(OUT) if f.endswith(".png"))))
