#!/usr/bin/env python3
"""
Convert raw iPhone screenshots into App Store Connect-ready images.

Drop your source screenshots into  appstore_screenshots/source/
then run:  python3 appstore_screenshots/make_appstore_screens.py

Outputs (RGB, no alpha, exact pixel sizes Apple requires):
  out_6.9/  -> 1320 x 2868  (iPhone 6.9", 16/17 Pro Max) — REQUIRED
  out_6.5/  -> 1242 x 2688  (iPhone 6.5", 11 Pro Max)    — optional

Each source is scaled to fill the target and center-cropped (the two App Store
aspect ratios differ by ~0.4%, so the crop is a few invisible pixels). Files are
numbered in sorted filename order, so name your sources 01_home.png, 02_product.png, etc.
"""
import os
from PIL import Image

BASE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(BASE, "source")

TARGETS = {
    "out_6.9": (1320, 2868),
    "out_6.5": (1242, 2688),
}

VALID = (".png", ".jpg", ".jpeg")


def fit_crop(img, tw, th):
    """Scale to fill (tw x th), then center-crop to exact size."""
    sw, sh = img.size
    scale = max(tw / sw, th / sh)
    nw, nh = round(sw * scale), round(sh * scale)
    img = img.resize((nw, nh), Image.LANCZOS)
    left = (nw - tw) // 2
    top = (nh - th) // 2
    return img.crop((left, top, left + tw, top + th))


def flatten(img):
    """Remove alpha by compositing onto white -> RGB."""
    if img.mode in ("RGBA", "LA", "P"):
        img = img.convert("RGBA")
        bg = Image.new("RGB", img.size, (255, 255, 255))
        bg.paste(img, mask=img.split()[-1])
        return bg
    return img.convert("RGB")


def main():
    sources = sorted(f for f in os.listdir(SRC) if f.lower().endswith(VALID))
    if not sources:
        print(f"No images found in {SRC}. Drop your screenshots there first.")
        return
    print(f"Found {len(sources)} source screenshot(s): {', '.join(sources)}\n")
    for folder, (tw, th) in TARGETS.items():
        outdir = os.path.join(BASE, folder)
        os.makedirs(outdir, exist_ok=True)
        for i, name in enumerate(sources, 1):
            img = flatten(Image.open(os.path.join(SRC, name)))
            out = fit_crop(img, tw, th)
            outpath = os.path.join(outdir, f"appstore_{i:02d}.png")
            out.save(outpath, "PNG")
            print(f"  {folder}/appstore_{i:02d}.png  ({tw}x{th})  <- {name}")
    print("\nDone. Upload out_6.9/ (required) and optionally out_6.5/ in App Store Connect.")


if __name__ == "__main__":
    main()
