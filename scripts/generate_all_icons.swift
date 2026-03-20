#!/usr/bin/env swift
// generate_all_icons.swift
// 生成 SimpleWeatherApp 所有必需的 App Icon 尺寸
// 运行方法: swift scripts/generate_all_icons.swift

import AppKit
import CoreGraphics

// 定义所有需要的图标尺寸
let iconSizes: [(name: String, size: Int)] = [
    // iPhone
    ("AppIcon-20x20@2x", 40),
    ("AppIcon-20x20@3x", 60),
    ("AppIcon-29x29@2x", 58),
    ("AppIcon-29x29@3x", 87),
    ("AppIcon-40x40@2x", 80),
    ("AppIcon-40x40@3x", 120),
    ("AppIcon-60x60@2x", 120), // 120x120 - 这是必需的！
    ("AppIcon-60x60@3x", 180),

    // iPad
    ("AppIcon-20x20@1x", 20),
    ("AppIcon-20x20@2x", 40),
    ("AppIcon-29x29@1x", 29),
    ("AppIcon-29x29@2x", 58),
    ("AppIcon-40x40@1x", 40),
    ("AppIcon-40x40@2x", 80),
    ("AppIcon-76x76@1x", 76),
    ("AppIcon-76x76@2x", 152),
    ("AppIcon-83.5x83.5@2x", 167),

    // App Store
    ("AppIcon-1024x1024@1x", 1024)
]

// 生成单个图标的方法
func generateIcon(size: Int, filename: String) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

    guard let ctx = CGContext(
        data: nil, width: size, height: size,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: colorSpace, bitmapInfo: bitmapInfo.rawValue
    ) else {
        print("❌ Failed to create CGContext for \(filename)");
        return
    }

    let w = CGFloat(size)
    let h = CGFloat(size)

    // 背景渐变
    let bgColors = [
        CGColor(red: 0.10, green: 0.42, blue: 0.88, alpha: 1.0),
        CGColor(red: 0.04, green: 0.20, blue: 0.60, alpha: 1.0),
    ] as CFArray
    let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(bgGradient,
        start: CGPoint(x: 0, y: h),
        end: CGPoint(x: w, y: 0),
        options: [])

    // 太阳 (右下角，部分在云后面)
    let sunCX: CGFloat = w * 0.62
    let sunCY: CGFloat = h * 0.44
    let sunR: CGFloat = w * 0.22

    // 光晕
    let glowColors = [
        CGColor(red: 1.0, green: 0.88, blue: 0.3, alpha: 0.35),
        CGColor(red: 1.0, green: 0.88, blue: 0.3, alpha: 0.0),
    ] as CFArray
    let glowGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 1.0])!
    ctx.drawRadialGradient(glowGradient,
        startCenter: CGPoint(x: sunCX, y: sunCY), startRadius: sunR,
        endCenter:   CGPoint(x: sunCX, y: sunCY), endRadius:   sunR * 2.2,
        options: [])

    // 太阳盘
    ctx.setFillColor(CGColor(red: 1.0, green: 0.87, blue: 0.22, alpha: 1.0))
    ctx.fillEllipse(in: CGRect(x: sunCX - sunR, y: sunCY - sunR, width: sunR * 2, height: sunR * 2))

    // 光线
    ctx.setStrokeColor(CGColor(red: 1.0, green: 0.87, blue: 0.22, alpha: 0.9))
    ctx.setLineWidth(w * 0.028)
    ctx.setLineCap(.round)
    let rayCount = 8
    for i in 0..<rayCount {
        let angle = CGFloat(i) * (.pi * 2 / CGFloat(rayCount))
        let r0 = sunR * 1.22
        let r1 = sunR * 1.72
        ctx.move(to: CGPoint(x: sunCX + cos(angle) * r0, y: sunCY + sin(angle) * r0))
        ctx.addLine(to: CGPoint(x: sunCX + cos(angle) * r1, y: sunCY + sin(angle) * r1))
    }
    ctx.strokePath()

    // 云朵 (白色, 左侧居中)
    func addCloudPath(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, scale s: CGFloat) {
        // 三个重叠的圆 + 平底
        let r1 = s * 0.30  // 主顶部穹顶
        let r2 = s * 0.22  // 左穹顶
        let r3 = s * 0.20  // 右穹顶
        let base = cy - r1 * 0.5

        let path = CGMutablePath()
        // 左穹顶
        path.addArc(center: CGPoint(x: cx - r1 * 0.55, y: base - r2 * 0.4),
                    radius: r2, startAngle: .pi, endAngle: 0, clockwise: false)
        // 主穹顶
        path.addArc(center: CGPoint(x: cx, y: base - r1 * 0.5),
                    radius: r1, startAngle: .pi * 1.1, endAngle: .pi * -0.1, clockwise: false)
        // 右穹顶
        path.addArc(center: CGPoint(x: cx + r1 * 0.60, y: base - r3 * 0.2),
                    radius: r3, startAngle: .pi * -0.15, endAngle: .pi, clockwise: false)
        // 封闭底部
        path.addLine(to: CGPoint(x: cx - r1 * 0.55 - r2, y: base + r2 * 0.5))
        path.closeSubpath()
        ctx.addPath(path)
    }

    let cloudCX = w * 0.46
    let cloudCY = h * 0.56
    let cloudScale = w * 0.85

    // 云阴影
    ctx.saveGState()
    ctx.setAlpha(0.18)
    ctx.setShadow(offset: CGSize(width: 0, height: -w * 0.018), blur: w * 0.04,
                  color: CGColor(red: 0, green: 0.1, blue: 0.4, alpha: 1))
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    addCloudPath(ctx, cx: cloudCX, cy: cloudCY, scale: cloudScale)
    ctx.fillPath()
    ctx.restoreGState()

    // 云身体
    ctx.setFillColor(CGColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1.0))
    addCloudPath(ctx, cx: cloudCX, cy: cloudCY, scale: cloudScale)
    ctx.fillPath()

    // 云内部高光
    ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.55))
    addCloudPath(ctx, cx: cloudCX - w * 0.01, cy: cloudCY - w * 0.025, scale: cloudScale * 0.7)
    ctx.fillPath()

    // 导出PNG
    guard let cgImage = ctx.makeImage() else {
        print("❌ Failed to make image for \(filename)");
        return
    }
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
    guard let tiff = nsImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        print("❌ Failed to encode PNG for \(filename)");
        return
    }

    let outputPath = "SimpleWeatherApp/Assets.xcassets/AppIcon.appiconset/\(filename).png"
    let url = URL(fileURLWithPath: outputPath)
    do {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true)
        try png.write(to: url)
        print("✅ Generated: \(filename).png (\(size)x\(size))")
    } catch {
        print("❌ Failed to write \(filename).png: \(error)")
    }
}

print("🎨 开始生成 SimpleWeatherApp 的所有图标...")

// 生成所有图标
for icon in iconSizes {
    generateIcon(size: icon.size, filename: icon.name)
}

print("🎉 所有图标生成完成！")
print("📝 确保 Contents.json 已包含以下必需的 iPhone 图标:")
print("   - AppIcon-60x60@2x (120x120 px) - 必需")
print("   - AppIcon-60x60@3x (180x180 px) - 必需")
print("   - 其他各种尺寸也是推荐的")