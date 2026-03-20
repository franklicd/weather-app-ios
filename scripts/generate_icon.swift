#!/usr/bin/env swift
// generate_icon.swift
// 生成 SimpleWeatherApp App Icon (1024×1024 PNG)
// 运行方法: swift scripts/generate_icon.swift

import AppKit
import CoreGraphics

let size = 1024
let outputPath = "SimpleWeatherApp/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

// MARK: - Canvas

let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
guard let ctx = CGContext(
    data: nil, width: size, height: size,
    bitsPerComponent: 8, bytesPerRow: 0,
    space: colorSpace, bitmapInfo: bitmapInfo.rawValue
) else { print("❌ Failed to create CGContext"); exit(1) }

let w = CGFloat(size)
let h = CGFloat(size)

// MARK: - Background Gradient

let bgColors = [
    CGColor(red: 0.10, green: 0.42, blue: 0.88, alpha: 1.0),
    CGColor(red: 0.04, green: 0.20, blue: 0.60, alpha: 1.0),
] as CFArray
let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0])!
ctx.drawLinearGradient(bgGradient,
    start: CGPoint(x: 0, y: h),
    end: CGPoint(x: w, y: 0),
    options: [])

// MARK: - Sun (bottom-right, partially behind cloud)

let sunCX: CGFloat = w * 0.62
let sunCY: CGFloat = h * 0.44
let sunR: CGFloat  = w * 0.22

// Glow
let glowColors = [
    CGColor(red: 1.0, green: 0.88, blue: 0.3, alpha: 0.35),
    CGColor(red: 1.0, green: 0.88, blue: 0.3, alpha: 0.0),
] as CFArray
let glowGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 1.0])!
ctx.drawRadialGradient(glowGradient,
    startCenter: CGPoint(x: sunCX, y: sunCY), startRadius: sunR,
    endCenter:   CGPoint(x: sunCX, y: sunCY), endRadius:   sunR * 2.2,
    options: [])

// Sun disc
ctx.setFillColor(CGColor(red: 1.0, green: 0.87, blue: 0.22, alpha: 1.0))
ctx.fillEllipse(in: CGRect(x: sunCX - sunR, y: sunCY - sunR, width: sunR * 2, height: sunR * 2))

// Rays
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

// MARK: - Cloud (white, centered-left)

func addCloudPath(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, scale s: CGFloat) {
    // Three overlapping circles + flat bottom
    let r1 = s * 0.30  // main top dome
    let r2 = s * 0.22  // left dome
    let r3 = s * 0.20  // right dome
    let base = cy - r1 * 0.5

    let path = CGMutablePath()
    // left dome
    path.addArc(center: CGPoint(x: cx - r1 * 0.55, y: base - r2 * 0.4),
                radius: r2, startAngle: .pi, endAngle: 0, clockwise: false)
    // main dome
    path.addArc(center: CGPoint(x: cx, y: base - r1 * 0.5),
                radius: r1, startAngle: .pi * 1.1, endAngle: .pi * -0.1, clockwise: false)
    // right dome
    path.addArc(center: CGPoint(x: cx + r1 * 0.60, y: base - r3 * 0.2),
                radius: r3, startAngle: .pi * -0.15, endAngle: .pi, clockwise: false)
    // close bottom
    path.addLine(to: CGPoint(x: cx - r1 * 0.55 - r2, y: base + r2 * 0.5))
    path.closeSubpath()
    ctx.addPath(path)
}

let cloudCX = w * 0.46
let cloudCY = h * 0.56
let cloudScale = w * 0.85

// Cloud shadow
ctx.saveGState()
ctx.setAlpha(0.18)
ctx.setShadow(offset: CGSize(width: 0, height: -w * 0.018), blur: w * 0.04,
              color: CGColor(red: 0, green: 0.1, blue: 0.4, alpha: 1))
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
addCloudPath(ctx, cx: cloudCX, cy: cloudCY, scale: cloudScale)
ctx.fillPath()
ctx.restoreGState()

// Cloud body
ctx.setFillColor(CGColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1.0))
addCloudPath(ctx, cx: cloudCX, cy: cloudCY, scale: cloudScale)
ctx.fillPath()

// Cloud inner highlight
ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.55))
addCloudPath(ctx, cx: cloudCX - w * 0.01, cy: cloudCY - w * 0.025, scale: cloudScale * 0.7)
ctx.fillPath()

// MARK: - Export PNG

guard let cgImage = ctx.makeImage() else { print("❌ Failed to make image"); exit(1) }
let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
guard let tiff = nsImage.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    print("❌ Failed to encode PNG"); exit(1)
}

let url = URL(fileURLWithPath: outputPath)
do {
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true)
    try png.write(to: url)
    print("✅ App Icon 已生成: \(outputPath)")
    print("   尺寸: \(size)×\(size) px")
    print("   大小: \(png.count / 1024) KB")
} catch {
    print("❌ 写入失败: \(error)")
    exit(1)
}
