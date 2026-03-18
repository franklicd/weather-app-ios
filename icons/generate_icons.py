from PIL import Image, ImageDraw
import math

# 创建 1024x1024 的图像
size = 1024
radius = 230  # iOS 图标圆角

def create_icon_v1():
    """方案一：极简渐变太阳"""
    img = Image.new('RGB', (size, size), '#FF6B35')
    draw = ImageDraw.Draw(img)
    
    # 绘制渐变背景（简化版，用圆形模拟）
    for i in range(size):
        ratio = i / size
        r = int(255 - ratio * 60)  # FF -> C5
        g = int(107 + ratio * 140)  # 6B -> C5
        b = int(53 + ratio * 100)   # 35 -> 9F
        draw.line([(0, i), (size, i)], fill=(r, g, b))
    
    # 绘制太阳（白色圆形）
    sun_x, sun_y = 650, 450
    sun_r = 120
    draw.ellipse([sun_x-sun_r, sun_y-sun_r, sun_x+sun_r, sun_y+sun_r], fill='white')
    
    # 绘制太阳光线
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        x1 = sun_x + math.cos(rad) * 150
        y1 = sun_y + math.sin(rad) * 150
        x2 = sun_x + math.cos(rad) * 200
        y2 = sun_y + math.sin(rad) * 200
        draw.line([(x1, y1), (x2, y2)], fill='white', width=20)
    
    # 绘制小云朵（左下角）
    draw.ellipse([220, 620, 380, 780], fill='white')  # 左
    draw.ellipse([312, 600, 512, 800], fill='white')  # 中
    draw.ellipse([420, 620, 580, 780], fill='white')  # 右
    
    # 应用圆角蒙版
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    img.putalpha(mask)
    
    return img

def create_icon_v2():
    """方案二：蓝天白云"""
    img = Image.new('RGB', (size, size), '#4A90D9')
    draw = ImageDraw.Draw(img)
    
    # 渐变背景
    for i in range(size):
        ratio = i / size
        r = int(74 + ratio * 89)
        g = int(144 + ratio * 92)
        b = int(217 + ratio * 18)
        draw.line([(0, i), (size, i)], fill=(r, g, b))
    
    # 太阳（右上角）
    draw.ellipse([650, 180, 850, 380], fill='#FFD700')
    
    # 主云朵
    draw.ellipse([250, 450, 450, 650], fill='white')  # 左
    draw.ellipse([382, 420, 642, 680], fill='white')  # 中
    draw.ellipse([574, 450, 774, 650], fill='white')  # 右
    draw.rounded_rectangle([312, 520, 712, 650], radius=50, fill='white')
    
    # 小云朵
    draw.ellipse([140, 590, 260, 710], fill='white')
    draw.ellipse([205, 565, 355, 715], fill='white')
    draw.ellipse([300, 590, 420, 710], fill='white')
    
    # 应用圆角蒙版
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    img.putalpha(mask)
    
    return img

def create_icon_v3():
    """方案三：抽象艺术"""
    img = Image.new('RGB', (size, size), '#1A1A2E')
    draw = ImageDraw.Draw(img)
    
    # 深空渐变
    for i in range(size):
        ratio = i / size
        r = int(26 + ratio * 48)
        g = int(26 + ratio * 52)
        b = int(46 + ratio * 59)
        draw.line([(0, i), (size, i)], fill=(r, g, b))
    
    # 太阳弧线
    draw.arc([200, 300, 800, 600], start=0, end=180, fill='#FFD700', width=24)
    
    # 光线
    draw.line([(500, 220), (500, 170)], fill='#FFD700', width=16)
    draw.line([(650, 280), (690, 240)], fill='#FFD700', width=16)
    draw.line([(720, 400), (770, 400)], fill='#FFD700', width=16)
    
    # 风线条
    draw.arc([200, 550, 500, 650], start=0, end=180, fill='#E0E0E0', width=16)
    draw.arc([300, 630, 600, 730], start=0, end=180, fill='#C0C0C0', width=16)
    
    # 星星
    stars = [(200, 250, 8), (850, 200, 6), (900, 500, 10), (150, 550, 5), (800, 800, 7)]
    for x, y, r in stars:
        draw.ellipse([x-r, y-r, x+r, y+r], fill='white')
    
    # 应用圆角蒙版
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    img.putalpha(mask)
    
    return img

def create_icon_v4():
    """方案四：温度圆环"""
    img = Image.new('RGB', (size, size), '#F8F9FA')
    draw = ImageDraw.Draw(img)
    
    # 白色背景
    draw.rectangle([0, 0, size, size], fill='#F8F9FA')
    
    # 温度圆环（分段绘制实现渐变效果）
    center = size // 2
    ring_r = 320
    
    # 红色段（左上）
    draw.arc([center-ring_r, center-ring_r, center+ring_r, center+ring_r], 
             start=135, end=225, fill='#FF6B35', width=60)
    # 黄色段（上）
    draw.arc([center-ring_r, center-ring_r, center+ring_r, center+ring_r], 
             start=45, end=135, fill='#FFE66D', width=60)
    # 青色段（右下）
    draw.arc([center-ring_r, center-ring_r, center+ring_r, center+ring_r], 
             start=315, end=405, fill='#4ECDC4', width=60)
    # 绿色段（下）
    draw.arc([center-ring_r, center-ring_r, center+ring_r, center+ring_r], 
             start=225, end=315, fill='#95E1D3', width=60)
    
    # 中心温度符号（用圆形代替）
    draw.ellipse([center-40, center-100, center+40, center-20], fill='#2C3E50')
    
    # 刻度点
    dots = [(center, 120), (center, 904), (120, center), (904, center)]
    for x, y in dots:
        draw.ellipse([x-15, y-15, x+15, y+15], fill='#CBD5E0')
    
    # 应用圆角蒙版
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    img.putalpha(mask)
    
    return img

def create_icon_v5():
    """方案五：清新雨天"""
    img = Image.new('RGB', (size, size), '#56CCF2')
    draw = ImageDraw.Draw(img)
    
    # 蓝渐变背景
    for i in range(size):
        ratio = i / size
        r = int(86 + ratio * 33)
        g = int(204 - ratio * 44)
        b = int(242 - ratio * 35)
        draw.line([(0, i), (size, i)], fill=(r, g, b))
    
    # 太阳（右上）
    draw.ellipse([620, 220, 820, 420], fill='#FFD93D')
    # 光线
    draw.line([(720, 170), (720, 130)], fill='#FFD93D', width=16)
    draw.line([(870, 320), (910, 320)], fill='#FFD93D', width=16)
    draw.line([(820, 220), (850, 190)], fill='#FFD93D', width=16)
    draw.line([(820, 420), (850, 450)], fill='#FFD93D', width=16)
    
    # 雨滴（椭圆）
    rain_drops = [(300, 600), (400, 700), (500, 580), (600, 720)]
    for x, y in rain_drops:
        draw.ellipse([x-20, y-35, x+20, y+35], fill='white')
    
    # 彩虹弧线
    draw.arc([200, 550, 824, 950], start=0, end=180, fill='white', width=20)
    
    # 应用圆角蒙版
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    img.putalpha(mask)
    
    return img

# 生成所有图标
icons = [
    ('AppIcon_v1_sun.png', create_icon_v1),
    ('AppIcon_v2_cloud.png', create_icon_v2),
    ('AppIcon_v3_abstract.png', create_icon_v3),
    ('AppIcon_v4_temp.png', create_icon_v4),
    ('AppIcon_v5_fresh.png', create_icon_v5),
]

for filename, create_func in icons:
    img = create_func()
    img.save(filename, 'PNG')
    print(f'Generated: {filename}')

print('\nAll icons generated successfully!')