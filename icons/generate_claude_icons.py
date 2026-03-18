#!/usr/bin/env python3
"""Generate 5 WeatherApp iOS icons - AppIcon_claude_v1 to v5"""

import math
from PIL import Image, ImageDraw, ImageFilter
import numpy as np

SIZE = 1024
RADIUS = 230


def apply_rounded_corners(img, radius=RADIUS):
    """Apply iOS-style rounded corners using alpha mask."""
    mask = Image.new("L", (SIZE, SIZE), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=radius, fill=255)
    result = img.copy()
    result.putalpha(mask)
    return result


# ─────────────────────────────────────────────────────────────────
# v1: 极简风格 — 白底，午夜蓝细线条太阳+云
# ─────────────────────────────────────────────────────────────────
def make_v1():
    img = Image.new("RGBA", (SIZE, SIZE), (245, 247, 252, 255))
    draw = ImageDraw.Draw(img)

    # Soft warm background tint
    for y in range(SIZE):
        t = y / SIZE
        r = int(245 + (235 - 245) * t)
        g = int(247 + (242 - 247) * t)
        b = int(252 + (255 - 252) * t)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

    cx, cy = 512, 430
    ink = (30, 50, 100)
    stroke = 22

    # Sun circle
    sun_r = 130
    draw.ellipse([cx - sun_r, cy - sun_r, cx + sun_r, cy + sun_r],
                 outline=ink, width=stroke)

    # Sun rays — 8 evenly spaced
    ray_inner = sun_r + 30
    ray_outer = sun_r + 90
    for i in range(8):
        angle = math.radians(i * 45)
        x1 = cx + ray_inner * math.cos(angle)
        y1 = cy + ray_inner * math.sin(angle)
        x2 = cx + ray_outer * math.cos(angle)
        y2 = cy + ray_outer * math.sin(angle)
        draw.line([x1, y1, x2, y2], fill=ink, width=stroke)

    # Cloud — three overlapping circles beneath sun
    cloud_y = cy + 200
    cloud_base_y = cloud_y + 60
    cloud_color = ink
    for ox, oy, cr in [(-90, 0, 70), (0, -40, 90), (90, 0, 70), (170, 10, 55)]:
        draw.ellipse([cx + ox - cr, cloud_y + oy - cr,
                      cx + ox + cr, cloud_y + oy + cr],
                     outline=cloud_color, width=stroke)

    # Minimalist label dot
    draw.ellipse([cx - 8, cy + 340, cx + 8, cy + 356],
                 fill=(30, 50, 100, 180))

    return apply_rounded_corners(img)


# ─────────────────────────────────────────────────────────────────
# v2: 渐变风格 — 黎明天空渐变 + 太阳升起光晕
# ─────────────────────────────────────────────────────────────────
def make_v2():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    # Sky gradient: deep indigo → warm amber → soft coral
    top = (20, 30, 90)
    mid = (255, 140, 60)
    bot = (255, 200, 140)

    for y in range(SIZE):
        t = y / SIZE
        if t < 0.55:
            s = t / 0.55
            r = int(top[0] + (mid[0] - top[0]) * s)
            g = int(top[1] + (mid[1] - top[1]) * s)
            b = int(top[2] + (mid[2] - top[2]) * s)
        else:
            s = (t - 0.55) / 0.45
            r = int(mid[0] + (bot[0] - mid[0]) * s)
            g = int(mid[1] + (bot[1] - mid[1]) * s)
            b = int(mid[2] + (bot[2] - mid[2]) * s)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

    # Glow layers around sun horizon
    cx, horizon = 512, 680
    for radius in range(320, 0, -4):
        alpha = int(60 * (1 - radius / 320))
        r = min(255, 255)
        g = min(255, int(180 + 75 * (1 - radius / 320)))
        b = min(255, int(80 + 100 * (1 - radius / 320)))
        draw.ellipse([cx - radius, horizon - radius,
                      cx + radius, horizon + radius],
                     fill=(r, g, b, alpha))

    # Sun disc
    sun_r = 110
    draw.ellipse([cx - sun_r, horizon - sun_r,
                  cx + sun_r, horizon + sun_r],
                 fill=(255, 240, 200, 255))

    # Thin cloud streaks
    for i, (ox, oy, w, h) in enumerate([
        (-200, -250, 260, 38),
        (80, -300, 200, 30),
        (-260, -170, 180, 28),
        (100, -180, 220, 32),
    ]):
        cloud_img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        cd = ImageDraw.Draw(cloud_img)
        cd.rounded_rectangle([0, 0, w - 1, h - 1], radius=h // 2,
                              fill=(255, 255, 255, 90))
        cloud_img = cloud_img.filter(ImageFilter.GaussianBlur(4))
        img.alpha_composite(cloud_img, (cx + ox, horizon + oy))

    return apply_rounded_corners(img)


# ─────────────────────────────────────────────────────────────────
# v3: 几何抽象风格 — 深空蓝底，多边形拼接天气图腾
# ─────────────────────────────────────────────────────────────────
def make_v3():
    img = Image.new("RGBA", (SIZE, SIZE), (8, 12, 40, 255))
    draw = ImageDraw.Draw(img)

    # Background grid dots
    for gx in range(32, SIZE, 64):
        for gy in range(32, SIZE, 64):
            draw.ellipse([gx - 1, gy - 1, gx + 1, gy + 1],
                         fill=(255, 255, 255, 30))

    cx, cy = 512, 490

    # Outer hexagon — electric blue
    def hex_pts(cx, cy, r, offset=0):
        return [(cx + r * math.cos(math.radians(60 * i + offset)),
                 cy + r * math.sin(math.radians(60 * i + offset)))
                for i in range(6)]

    draw.polygon(hex_pts(cx, cy, 340, 30), outline=(0, 180, 255, 200), width=3)
    draw.polygon(hex_pts(cx, cy, 270, 30), outline=(0, 180, 255, 120), width=2)

    # Inner triangle — cyan accent
    tri = [(cx, cy - 160),
           (cx - 138, cy + 80),
           (cx + 138, cy + 80)]
    draw.polygon(tri, outline=(0, 255, 220, 220), width=4)
    # Fill with subtle tint
    draw.polygon(tri, fill=(0, 220, 200, 18))

    # Diamond / rhombus (wind symbol)
    diamond = [(cx, cy - 230), (cx + 60, cy), (cx, cy + 230), (cx - 60, cy)]
    draw.polygon(diamond, outline=(100, 200, 255, 160), width=3)

    # Central sun icon — concentric rings
    for r, a in [(80, 200), (55, 160), (35, 230)]:
        draw.ellipse([cx - r, cy - r, cx + r, cy + r],
                     outline=(255, 220, 80, a), width=3)
    draw.ellipse([cx - 22, cy - 22, cx + 22, cy + 22],
                 fill=(255, 220, 80, 255))

    # Accent lines radiating
    for i in range(12):
        angle = math.radians(i * 30)
        x1 = cx + 92 * math.cos(angle)
        y1 = cy + 92 * math.sin(angle)
        x2 = cx + 140 * math.cos(angle)
        y2 = cy + 140 * math.sin(angle)
        draw.line([x1, y1, x2, y2], fill=(255, 220, 80, 180), width=2)

    # Corner accent triangles
    for px, py, pts in [
        (0, 0, [(0, 0), (120, 0), (0, 120)]),
        (SIZE, 0, [(SIZE, 0), (SIZE - 120, 0), (SIZE, 120)]),
        (0, SIZE, [(0, SIZE), (120, SIZE), (0, SIZE - 120)]),
        (SIZE, SIZE, [(SIZE, SIZE), (SIZE - 120, SIZE), (SIZE, SIZE - 120)]),
    ]:
        draw.polygon(pts, fill=(0, 180, 255, 25), outline=(0, 180, 255, 80), width=2)

    return apply_rounded_corners(img)


# ─────────────────────────────────────────────────────────────────
# v4: 拟物风格 — 玻璃质感卡片，写实云朵 + 温度计
# ─────────────────────────────────────────────────────────────────
def make_v4():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    # Lush blue-green sky gradient
    for y in range(SIZE):
        t = y / SIZE
        r = int(100 + (180 - 100) * t)
        g = int(180 + (220 - 180) * t)
        b = int(255 + (240 - 255) * t)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

    # Glass card
    card = Image.new("RGBA", (820, 820), (0, 0, 0, 0))
    cd = ImageDraw.Draw(card)
    cd.rounded_rectangle([0, 0, 819, 819], radius=80,
                         fill=(255, 255, 255, 55))
    # Card top highlight
    cd.rounded_rectangle([10, 10, 809, 80], radius=40,
                         fill=(255, 255, 255, 60))
    img.alpha_composite(card, (102, 102))

    # Draw realistic puffy cloud using layered blurred circles
    cloud_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    cld = ImageDraw.Draw(cloud_layer)
    cloud_cx, cloud_cy = 512, 420
    for ox, oy, cr, alpha in [
        (0, 0, 145, 240),
        (-130, 40, 110, 240),
        (130, 40, 110, 240),
        (-60, -70, 100, 240),
        (60, -70, 100, 240),
        (0, 80, 120, 240),
        (-200, 70, 80, 220),
        (200, 70, 80, 220),
    ]:
        cld.ellipse([cloud_cx + ox - cr, cloud_cy + oy - cr,
                     cloud_cx + ox + cr, cloud_cy + oy + cr],
                    fill=(255, 255, 255, alpha))
    cloud_layer = cloud_layer.filter(ImageFilter.GaussianBlur(8))
    img.alpha_composite(cloud_layer)

    # Thermometer body
    therm_x, therm_y = 512, 640
    tw, th = 36, 180
    draw2 = ImageDraw.Draw(img)
    # Tube
    draw2.rounded_rectangle([therm_x - tw // 2, therm_y - th,
                              therm_x + tw // 2, therm_y],
                             radius=tw // 2,
                             fill=(220, 230, 240, 200),
                             outline=(180, 200, 220, 255), width=3)
    # Mercury fill
    mercury_h = 110
    draw2.rounded_rectangle([therm_x - tw // 2 + 6, therm_y - mercury_h,
                              therm_x + tw // 2 - 6, therm_y],
                             radius=(tw // 2 - 6),
                             fill=(220, 50, 50, 220))
    # Bulb
    bulb_r = 34
    draw2.ellipse([therm_x - bulb_r, therm_y - bulb_r,
                   therm_x + bulb_r, therm_y + bulb_r],
                  fill=(220, 50, 50, 240))
    # Highlight on bulb
    draw2.ellipse([therm_x - bulb_r + 8, therm_y - bulb_r + 8,
                   therm_x - bulb_r + 22, therm_y - bulb_r + 22],
                  fill=(255, 160, 160, 160))

    # Tick marks
    for i in range(5):
        ty = therm_y - 20 - i * 28
        draw2.line([therm_x + tw // 2 + 4, ty,
                    therm_x + tw // 2 + 18, ty],
                   fill=(60, 80, 120, 200), width=3)

    # Bottom glass card shine
    shine = Image.new("RGBA", (820, 820), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shine)
    sd.rounded_rectangle([0, 760, 819, 819], radius=80,
                         fill=(255, 255, 255, 25))
    img.alpha_composite(shine, (102, 102))

    return apply_rounded_corners(img)


# ─────────────────────────────────────────────────────────────────
# v5: 动态感风格 — 深紫夜空，风暴闪电 + 粒子流
# ─────────────────────────────────────────────────────────────────
def make_v5():
    img = Image.new("RGBA", (SIZE, SIZE), (10, 5, 30, 255))
    draw = ImageDraw.Draw(img)

    # Deep purple-to-teal radial sweep
    for y in range(SIZE):
        t = y / SIZE
        r = int(10 + (30 - 10) * t)
        g = int(5 + (20 - 5) * t)
        b = int(30 + (60 - 30) * t)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

    # Concentric speed rings (motion blur feel)
    cx, cy = 512, 480
    for i in range(18):
        r = 80 + i * 24
        alpha = int(110 * (1 - i / 18))
        # Partial arc to suggest motion
        draw.arc([cx - r, cy - r, cx + r, cy + r],
                 start=-30, end=210,
                 fill=(100, 80, 255, alpha), width=2)

    # Storm cloud mass — layered dark blobs
    cloud_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    cld = ImageDraw.Draw(cloud_layer)
    for ox, oy, cr, col in [
        (-120, -60, 150, (50, 40, 100, 220)),
        (0, -100, 170, (60, 50, 110, 230)),
        (120, -60, 150, (50, 40, 100, 220)),
        (-200, 0, 110, (40, 35, 90, 200)),
        (200, 0, 110, (40, 35, 90, 200)),
        (0, 20, 140, (45, 38, 95, 220)),
    ]:
        cld.ellipse([cx + ox - cr, cy + oy - cr,
                     cx + ox + cr, cy + oy + cr],
                    fill=col)
    cloud_layer = cloud_layer.filter(ImageFilter.GaussianBlur(12))
    img.alpha_composite(cloud_layer)

    # Lightning bolt — main
    bolt = [
        (cx + 20, cy - 200),
        (cx - 40, cy - 60),
        (cx + 10, cy - 60),
        (cx - 80, cy + 180),
        (cx + 20, cy + 10),
        (cx - 20, cy + 10),
        (cx + 20, cy - 200),
    ]
    # Glow pass
    glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow_layer)
    gd.polygon(bolt, fill=(180, 140, 255, 60))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(20))
    img.alpha_composite(glow_layer)

    draw.polygon(bolt, fill=(240, 220, 255, 255))

    # Secondary small lightning
    bolt2 = [
        (cx + 130, cy - 120),
        (cx + 90, cy + 10),
        (cx + 110, cy + 10),
        (cx + 60, cy + 130),
        (cx + 120, cy + 50),
        (cx + 100, cy + 50),
        (cx + 130, cy - 120),
    ]
    draw.polygon(bolt2, fill=(200, 180, 255, 180))

    # Rain streaks
    import random
    random.seed(42)
    for _ in range(40):
        rx = random.randint(150, 870)
        ry = random.randint(600, 950)
        length = random.randint(20, 55)
        alpha = random.randint(80, 180)
        draw.line([rx, ry, rx - 8, ry + length],
                  fill=(140, 160, 255, alpha), width=2)

    # Particle dots
    for _ in range(60):
        px = random.randint(50, 970)
        py = random.randint(50, 970)
        pr = random.randint(1, 4)
        pa = random.randint(60, 180)
        draw.ellipse([px - pr, py - pr, px + pr, py + pr],
                     fill=(200, 180, 255, pa))

    return apply_rounded_corners(img)


# ─────────────────────────────────────────────────────────────────
# Generate all 5 icons
# ─────────────────────────────────────────────────────────────────
generators = [make_v1, make_v2, make_v3, make_v4, make_v5]
output_dir = "/Users/ghostwhisper/.openclaw/workspace/WeatherApp/icons"

for idx, gen in enumerate(generators, 1):
    out_path = f"{output_dir}/AppIcon_claude_v{idx}.png"
    icon = gen()
    icon.save(out_path, "PNG")
    print(f"Saved: AppIcon_claude_v{idx}.png")

print("Done — 5 icons generated.")
