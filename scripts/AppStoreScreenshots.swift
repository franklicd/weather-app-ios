// AppStoreScreenshots.swift
// App Store 截图预览代码
// 在 Xcode 中打开此文件，使用 #Preview 宏预览各设备尺寸截图
//
// 设备截图尺寸要求（像素）：
//   iPhone 17 Pro Max (6.9"): 1320 × 2868 px  →  440 × 956 pt @3x
//   iPhone 17 Pro     (6.3"): 1206 × 2622 px  →  402 × 874 pt @3x
//   iPhone 17         (6.1"): 1179 × 2556 px  →  393 × 852 pt @3x

import SwiftUI

// MARK: - 设备尺寸配置

struct DeviceSpec {
    let name: String
    let widthPt: CGFloat
    let heightPt: CGFloat
    let scale: CGFloat

    var widthPx: Int { Int(widthPt * scale) }
    var heightPx: Int { Int(heightPt * scale) }

    static let iPhone17ProMax = DeviceSpec(
        name: "iPhone 17 Pro Max",
        widthPt: 440, heightPt: 956, scale: 3.0
    )
    static let iPhone17Pro = DeviceSpec(
        name: "iPhone 17 Pro",
        widthPt: 402, heightPt: 874, scale: 3.0
    )
    static let iPhone17 = DeviceSpec(
        name: "iPhone 17",
        widthPt: 393, heightPt: 852, scale: 3.0
    )

    static let all: [DeviceSpec] = [.iPhone17ProMax, .iPhone17Pro, .iPhone17]
}

// MARK: - 截图 1: 启动画面

#Preview("截图1 - 启动画面 iPhone 17 Pro Max",
         traits: .fixedLayout(width: 440, height: 956)) {
    SplashScreenView()
        .environmentObject(WeatherStore())
}

#Preview("截图1 - 启动画面 iPhone 17 Pro",
         traits: .fixedLayout(width: 402, height: 874)) {
    SplashScreenView()
        .environmentObject(WeatherStore())
}

#Preview("截图1 - 启动画面 iPhone 17",
         traits: .fixedLayout(width: 393, height: 852)) {
    SplashScreenView()
        .environmentObject(WeatherStore())
}

// MARK: - 截图 2: 城市列表

#Preview("截图2 - 城市列表 iPhone 17 Pro Max",
         traits: .fixedLayout(width: 440, height: 956)) {
    CityListView()
        .environmentObject(WeatherStore())
}

#Preview("截图2 - 城市列表 iPhone 17",
         traits: .fixedLayout(width: 393, height: 852)) {
    CityListView()
        .environmentObject(WeatherStore())
}

// MARK: - 截图 3: 天气详情

#Preview("截图3 - 天气详情 iPhone 17 Pro Max",
         traits: .fixedLayout(width: 440, height: 956)) {
    CityDetailView()
        .environmentObject(WeatherStore())
}

#Preview("截图3 - 天气详情 iPhone 17",
         traits: .fixedLayout(width: 393, height: 852)) {
    CityDetailView()
        .environmentObject(WeatherStore())
}

// MARK: - 截图 4: 设置页面

#Preview("截图4 - 设置 iPhone 17 Pro Max",
         traits: .fixedLayout(width: 440, height: 956)) {
    SettingsView()
        .environmentObject(WeatherStore())
}
