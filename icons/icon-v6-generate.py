#!/usr/bin/env python3
"""
icon-v6-generate.py — "Ink & Atmosphere" App Icon for 简天气 (SimpleWeather)

Design language: A fusion of Chinese ink-wash aesthetics with modern atmospheric design.
Central motif: A sun partially obscured by an ink-brush cloud, evoking both
traditional calligraphy and contemporary weather visualization.

Color palette:
  - Background gradient: #1A56DB (deep ocean blue) -> #111827 (near black)
  - Sun accent: #F59E0B (warm amber)
  - Cloud highlights: #BAE6FD (ice blue)
  - Ink tones: various opacities of slate blue

Output:
  - Master 1024x1024 PNG
  - All iOS AppIcon sizes per Contents.json
"""

import math
import os
import random
from PIL import Image, ImageDraw, ImageFilter

# ─── Configuration ───────────────────────────────────────────────
SIZE = 1024
ICON_DIR = os.path.dirname(os.path.abspath(__file__))
APPCON_DIR = os.path.join(
    ICON_DIR,
    "..",
    "SimpleWeatherApp",
    "Assets.xcassets",
    "AppIcon.appiconset",
)

# Design tokens
DEEP_OCEAN = (26, 86, 219)       # #1A56DB
NEAR_BLACK = (17, 24, 39)        # #111827
WARM_AMBER = (245, 158, 11)      # #F59E0B
AMBER_LIGHT = (255, 210, 80)     # warm highlight
ICE_BLUE   = (186, 230, 253)     # #BAE6FD
INK_DARK   = (30, 41, 59)        # #1E293B
INK_MID    = (51, 65, 85)        # #334155
SLATE_MIST = (100, 116, 139)     # #64748B


# ─── Utility Functions ───────────────────────────────────────────

def lerp_color(c1, c2, t):
    """Linearly interpolate between two RGB color tuples."""
    t = max(0.0, min(1.0, t))
    return tuple(int(a + (b - a) * t) for a, b in zip(c1, c2))


def make_gradient_bg():
    """
    Create a diagonal gradient from DEEP_OCEAN (top-left) to NEAR_BLACK (bottom-right).
    Uses numpy for speed if available, falls back to PIL line-by-line.
    """
    try:
        import numpy as np
        arr = np.zeros((SIZE, SIZE, 3), dtype=np.uint8)
        # Create coordinate grids normalized to [0,1]
        y_coords = np.linspace(0, 1, SIZE).reshape(-1, 1)
        x_coords = np.linspace(0, 1, SIZE).reshape(1, -1)
        t = (x_coords + y_coords) / 2.0  # diagonal interpolation
        for c in range(3):
            arr[:, :, c] = (DEEP_OCEAN[c] + (NEAR_BLACK[c] - DEEP_OCEAN[c]) * t).astype(np.uint8)
        img = Image.fromarray(arr, "RGB").convert("RGBA")
        return img
    except ImportError:
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 255))
        draw = ImageDraw.Draw(img)
        for y in range(SIZE):
            t_diag = y / SIZE
            color = lerp_color(DEEP_OCEAN, NEAR_BLACK, t_diag * 0.5)
            draw.line([(0, y), (SIZE - 1, y)], fill=(*color, 255))
            for x in range(0, SIZE, 4):
                t = (x / SIZE + t_diag) / 2.0
                c = lerp_color(DEEP_OCEAN, NEAR_BLACK, t)
                draw.line([(x, y), (min(x + 3, SIZE - 1), y)], fill=(*c, 255))
        return img


def soft_circle(img, cx, cy, radius, color, blur=0):
    """Draw a filled circle with optional gaussian blur for soft edges."""
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        fill=color,
    )
    if blur > 0:
        layer = layer.filter(ImageFilter.GaussianBlur(blur))
    img.alpha_composite(layer)
    return img


def draw_sun_glow(img, cx, cy, sun_r):
    """
    Draw atmospheric glow around the sun position.
    Multiple concentric rings that fade outward, placed behind the sun disc.
    """
    # Large blue atmospheric haze
    img = soft_circle(img, cx, cy, 380, (30, 80, 180, 30), blur=80)
    # Medium warm glow
    img = soft_circle(img, cx, cy, 260, (200, 140, 20, 22), blur=50)
    # Close warm corona
    img = soft_circle(img, cx, cy, sun_r + 50, (245, 170, 30, 40), blur=20)
    return img


def draw_sun_disc(img, cx, cy, radius):
    """
    Draw the solid amber sun disc with inner highlight.
    """
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # Solid amber disc
    draw.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        fill=(*WARM_AMBER, 255),
    )

    # Inner brighter highlight (offset up-left for depth)
    hr = radius * 0.65
    ho = radius * 0.12
    draw.ellipse(
        [cx - hr - ho, cy - hr - ho, cx + hr - ho, cy + hr - ho],
        fill=(255, 200, 70, 130),
    )

    # Re-stamp the solid center to ensure full opacity at core
    core_r = radius * 0.75
    draw.ellipse(
        [cx - core_r, cy - core_r, cx + core_r, cy + core_r],
        fill=(250, 175, 35, 255),
    )

    # Thin rim for definition
    draw.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        outline=(255, 220, 120, 70),
        width=4,
    )

    img.alpha_composite(layer)
    return img


def draw_ink_cloud(img, cx, cy, scale=1.0):
    """
    Draw an ink-brush inspired cloud using overlapping ellipses.
    The shape evokes a calligraphic brushstroke: wider in the middle,
    tapering at the edges, with varying opacity for depth.
    Uses a slightly lighter ink tone so it reads clearly against the
    dark background at all icon sizes.

    Returns the modified image.
    """
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # Ink color for cloud body: lighter than pure INK_DARK so it
    # maintains readability against the dark blue gradient background
    CLOUD_BODY = (45, 58, 82)  # lighter slate for contrast
    CLOUD_EDGE = (55, 70, 95)

    # Main cloud body blobs (offset_x, offset_y, radius, alpha)
    blobs = [
        # Core body
        (0,     0,    120, 250),
        (-90,   10,   100, 248),
        (90,    10,   100, 248),
        # Top bumps (classic cloud silhouette)
        (-45,  -65,   80,  245),
        (45,   -70,   85,  248),
        (0,    -45,   70,  240),
        # Bottom fill
        (0,     55,   150, 230),
        (-60,   45,   120, 220),
        (60,    45,   120, 220),
        # Edge wisps (ink spray)
        (-165,  25,   55,  190),
        (165,   25,   55,  190),
        (-210,  40,   35,  150),
        (210,   40,   35,  150),
    ]

    for ox, oy, r, alpha in blobs:
        rx = int(r * scale)
        ry = int(r * scale)
        px = int(cx + ox * scale)
        py = int(cy + oy * scale)
        if rx < 1 or ry < 1:
            continue
        color = CLOUD_EDGE if r < 60 else CLOUD_BODY
        draw.ellipse(
            [px - rx, py - ry, px + rx, py + ry],
            fill=(*color, alpha),
        )

    # Soften edges with blur (ink-bleed effect)
    blurred = layer.filter(ImageFilter.GaussianBlur(4))

    # Blend: favor sharp layer (0.65) for defined edges at small sizes
    blended = Image.blend(blurred, layer, 0.65)
    img.alpha_composite(blended)
    return img


def draw_ice_blue_highlights(img, cloud_cx, cloud_cy, scale):
    """
    Add ice-blue highlights along the top edge of the cloud.
    Simulates light catching on cloud edges at dawn/dusk.
    Brighter than previous version for visibility at small sizes.
    """
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # Wider, brighter highlights along the top crescent
    highlights = [
        (-50 * scale, -85 * scale, 85 * scale, 70),
        (30 * scale,  -95 * scale, 90 * scale, 75),
        (100 * scale, -75 * scale, 60 * scale, 60),
        (-130 * scale, -55 * scale, 50 * scale, 55),
        (160 * scale,  -45 * scale, 40 * scale, 50),
    ]
    for ox, oy, r, alpha in highlights:
        r = int(r)
        if r < 1:
            continue
        px = int(cloud_cx + ox)
        py = int(cloud_cy + oy)
        draw.ellipse(
            [px - r, py - r, px + r, py + r],
            fill=(*ICE_BLUE, alpha),
        )

    layer = layer.filter(ImageFilter.GaussianBlur(12))
    img.alpha_composite(layer)
    return img


def draw_ink_wash_texture(img):
    """
    Add subtle ink-wash texture across the background.
    Large, very low-opacity ellipses with heavy blur simulate
    the granular texture of ink spreading on rice paper.
    """
    texture = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(texture)

    random.seed(42)
    for _ in range(10):
        px = random.randint(80, SIZE - 80)
        py = random.randint(80, SIZE - 80)
        rx = random.randint(180, 350)
        ry = random.randint(120, 280)
        pa = random.randint(6, 20)
        draw.ellipse(
            [px - rx, py - ry, px + rx, py + ry],
            fill=(25, 45, 85, pa),
        )

    texture = texture.filter(ImageFilter.GaussianBlur(50))
    img.alpha_composite(texture)
    return img


def draw_atmospheric_particles(img, count=45, seed=88):
    """
    Add tiny floating particles suggesting atmospheric moisture / ink droplets.
    Scattered across the background with varying opacity.
    """
    random.seed(seed)
    draw = ImageDraw.Draw(img)

    for _ in range(count):
        px = random.randint(30, SIZE - 30)
        py = random.randint(30, SIZE - 30)
        pr = random.randint(1, 4)
        pa = random.randint(20, 90)
        if random.random() < 0.3:
            color = (*WARM_AMBER, pa)
        else:
            color = (*ICE_BLUE, pa)
        draw.ellipse(
            [px - pr, py - pr, px + pr, py + pr],
            fill=color,
        )
    return img


def draw_vignette(img):
    """
    Subtle vignette to darken corners and draw focus to the center.
    """
    vignette = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(vignette)
    for corner_x, corner_y in [(0, 0), (SIZE, 0), (0, SIZE), (SIZE, SIZE)]:
        draw.ellipse(
            [corner_x - 520, corner_y - 520, corner_x + 520, corner_y + 520],
            fill=(0, 0, 0, 28),
        )
    vignette = vignette.filter(ImageFilter.GaussianBlur(130))
    img.alpha_composite(vignette)
    return img


# ─── Main Icon Composition ───────────────────────────────────────

def create_icon_v6():
    """
    Create the "Ink & Atmosphere" icon.

    Layout:
        - Sun center: upper-center, slightly right (cx=520, cy=360)
        - Cloud center: center-lower (cx=500, cy=570)
        - Sun radius: 105
        - The sun sits above the cloud; the cloud's top edge grazes
          the bottom third of the sun, creating a "sun behind cloud" effect.

    Layer order (bottom to top):
        1. Diagonal gradient background
        2. Ink-wash texture
        3. Sun atmospheric glow (behind sun disc)
        4. Sun disc
        5. Ink-brush cloud (partially overlapping sun bottom)
        6. Ice-blue cloud highlights
        7. Atmospheric particles
        8. Vignette
    """
    sun_cx, sun_cy = 520, 360
    sun_r = 105
    cloud_cx, cloud_cy = 500, 570
    cloud_scale = 1.3

    # Layer 1: Background gradient
    img = make_gradient_bg()

    # Layer 2: Ink-wash texture
    img = draw_ink_wash_texture(img)

    # Layer 3: Sun atmospheric glow (behind the disc)
    img = draw_sun_glow(img, sun_cx, sun_cy, sun_r)

    # Layer 4: Sun disc (solid amber circle + highlight)
    img = draw_sun_disc(img, sun_cx, sun_cy, sun_r)

    # Layer 5: Ink-brush cloud (overlaps lower portion of sun)
    img = draw_ink_cloud(img, cloud_cx, cloud_cy, scale=cloud_scale)

    # Layer 6: Ice-blue highlights on cloud top edge
    img = draw_ice_blue_highlights(img, cloud_cx, cloud_cy, cloud_scale)

    # Layer 7: Atmospheric particles
    img = draw_atmospheric_particles(img, count=45, seed=88)

    # Layer 8: Vignette
    img = draw_vignette(img)

    return img


# ─── Export Functions ─────────────────────────────────────────────

ALL_EXPORT = {
    # filename -> pixel size (unique entries matching Contents.json)
    "AppIcon-20x20@1x.png": 20,
    "AppIcon-20x20@2x.png": 40,
    "AppIcon-20x20@3x.png": 60,
    "AppIcon-29x29@1x.png": 29,
    "AppIcon-29x29@2x.png": 58,
    "AppIcon-29x29@3x.png": 87,
    "AppIcon-40x40@1x.png": 40,
    "AppIcon-40x40@2x.png": 80,
    "AppIcon-40x40@3x.png": 120,
    "AppIcon-60x60@2x.png": 120,
    "AppIcon-60x60@3x.png": 180,
    "AppIcon-76x76@1x.png": 76,
    "AppIcon-76x76@2x.png": 152,
    "AppIcon-83.5x83.5@2x.png": 167,
    "AppIcon-1024x1024@1x.png": 1024,
}


def export_all(master_icon, output_dir):
    """Export the master icon to all required iOS sizes."""
    os.makedirs(output_dir, exist_ok=True)

    for filename, pixel_size in ALL_EXPORT.items():
        resized = master_icon.resize((pixel_size, pixel_size), Image.LANCZOS)
        # Convert to RGB (no alpha) for App Store compatibility
        rgb = Image.new("RGB", (pixel_size, pixel_size), (0, 0, 0))
        rgb.paste(resized, mask=resized.split()[-1])
        rgb.save(os.path.join(output_dir, filename), "PNG")

    print(f"Exported {len(ALL_EXPORT)} icon files to: {output_dir}")


# ─── Main ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating icon-v6: 'Ink & Atmosphere' for 简天气 ...")
    print()

    # Generate master icon
    master = create_icon_v6()

    # Save master to icons/ directory for reference
    master_path = os.path.join(ICON_DIR, "AppIcon_v6_ink_atmosphere.png")
    master_rgb = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
    master_rgb.paste(master, mask=master.split()[-1])
    master_rgb.save(master_path, "PNG")
    print(f"Saved master icon: {master_path}")

    # Quick pixel sanity check
    print(f"  Sun center (520,360): {master.getpixel((520, 360))}")
    print(f"  Sun right   (600,360): {master.getpixel((600, 360))}")
    print(f"  Cloud center(500,570): {master.getpixel((500, 570))}")
    print(f"  Top-left    (30, 30):  {master.getpixel((30, 30))}")
    print(f"  Bot-right   (990,990): {master.getpixel((990, 990))}")
    print()

    # Export all AppIcon sizes
    export_all(master, APPCON_DIR)
    print()

    print("Done. Icon generation complete.")
