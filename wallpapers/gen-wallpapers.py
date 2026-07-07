#!/usr/bin/env python3
"""Generate a set of dark minimalist wallpapers (2560x1600) for the monochrome rice."""
import math
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

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

x, y = coords()

# 1) drift — diagonal gradient, dark slate
v = (0.62 * x + 0.38 * y)
grain(to_img(v ** 1.2, 6, 58), 1.6).save(f"{OUT}/01-drift.png")

# 2) orb — huge soft glow off-center
d = np.sqrt((x - 0.30) ** 2 + ((y - 0.62) * (H / W) * 1.6) ** 2)
v = np.exp(-(d ** 2) / 0.09)
grain(to_img(v, 5, 78), 1.8).save(f"{OUT}/02-orb.png")

# 3) horizon — dark sky, faint glowing line at the lower third
base = 0.20 * (1 - y)                       # sky slightly lighter at top
line = np.exp(-((y - 0.66) ** 2) / 0.00012) # sharp core
glow = np.exp(-((y - 0.66) ** 2) / 0.006) * 0.35
below = (y > 0.66) * -0.5                   # ground darker
v = np.clip(base + glow + below, 0, 1) + line * 2.2
grain(to_img(np.clip(v, 0, 1.3) / 1.3, 4, 86), 1.6).save(f"{OUT}/03-horizon.png")

# 4) ridge — layered mountain silhouettes
img = to_img((1 - y) ** 1.4, 12, 62)  # sky gradient
draw = ImageDraw.Draw(img)
def ridge_pts(seed, base_y, rough):
    r = np.random.default_rng(seed)
    xs = np.linspace(0, W, 24)
    ys = base_y + np.cumsum(r.normal(0, rough, 24))
    ys -= (ys.mean() - base_y)
    return [(0, H)] + list(zip(xs, ys)) + [(W, H)]
for seed, by, rough, shade in [(3, H*0.52, 60, 30), (9, H*0.66, 45, 19), (5, H*0.80, 30, 10)]:
    draw.polygon(ridge_pts(seed, by, rough), fill=(shade, shade, shade))
grain(img, 1.5).save(f"{OUT}/04-ridge.png")

# 5) ring — thin circle outline on a whisper of gradient
img = to_img((0.3 * x + 0.7 * y) ** 1.3, 6, 38)
big = Image.new("L", (W * 2, H * 2), 0)
d2 = ImageDraw.Draw(big)
cx, cy, r = int(W * 2 * 0.63), int(H * 2 * 0.42), int(H * 0.62)
d2.ellipse([cx - r, cy - r, cx + r, cy + r], outline=195, width=6)
ring = big.resize((W, H), Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.6))
halo = ring.filter(ImageFilter.GaussianBlur(24)).point(lambda p: p * 0.5)
img = Image.composite(Image.new("RGB", (W, H), (170, 166, 157)), img,
                      Image.fromarray(np.maximum(np.asarray(ring), np.asarray(halo))))
grain(img, 1.5).save(f"{OUT}/05-ring.png")

# 6) beam — soft diagonal shaft of light
t = ((1 - x) * 0.8 - y * 0.55)                    # signed distance-ish across a diagonal
v = np.exp(-((t - 0.22) ** 2) / 0.012) * 0.9
grain(to_img(v * (0.4 + 0.6 * (1 - y)), 5, 70), 1.8).save(f"{OUT}/06-beam.png")

# 7) dune — two soft overlapping curves, barely-there
base = 0.15 * (1 - y)
c1 = np.clip((y - (0.55 + 0.12 * np.sin(x * math.pi * 1.2))) * 8, 0, 1) * 0.35
c2 = np.clip((y - (0.72 + 0.08 * np.sin(x * math.pi * 0.9 + 1.7))) * 8, 0, 1) * 0.5
v = np.clip(base + c1 - c2 + 0.25 * np.clip((y - (0.55 + 0.12 * np.sin(x * math.pi * 1.2))) * 8, 0, 1), 0, 1)
grain(to_img(v, 7, 55), 1.6).save(f"{OUT}/07-dune.png")

print("\n".join(sorted(os.listdir(OUT))))
