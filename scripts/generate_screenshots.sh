#!/bin/bash
# generate_screenshots.sh
# App Store 截图自动化生成脚本
# 使用方法: bash scripts/generate_screenshots.sh

set -e

PROJECT="WeatherApp.xcodeproj"
SCHEME="WeatherApp"
BUNDLE_ID="com.lyc.weatherapp.ios"
OUTPUT_DIR="$(pwd)/screenshots"
SDK="iphonesimulator"

# iPhone 17 系列模拟器名称（在 Xcode 中创建对应模拟器后使用）
DEVICES=(
    "iPhone 17 Pro Max"
    "iPhone 17 Pro"
    "iPhone 17"
)

mkdir -p "$OUTPUT_DIR"

echo "📦 编译 WeatherApp (Debug)..."
xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -sdk "$SDK" \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=iPhone 17 Pro Max" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    | grep -E "error:|warning:|Build succeeded|Build failed" || true

APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "${SCHEME}.app" \
    -path "*/Debug-iphonesimulator/*" 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ 未找到编译产物，请先在 Xcode 中 Build 项目"
    exit 1
fi

echo "✅ 找到应用: $APP_PATH"

take_screenshots() {
    local DEVICE="$1"
    local DEVICE_KEY="${DEVICE// /_}"

    echo ""
    echo "📱 处理设备: $DEVICE"

    # 获取模拟器 UDID
    UDID=$(xcrun simctl list devices available | grep "$DEVICE" | \
        grep -oE '[0-9A-F-]{36}' | head -1)

    if [ -z "$UDID" ]; then
        echo "  ⚠️  未找到模拟器 '$DEVICE'，跳过"
        echo "  提示: 在 Xcode > Simulator 中创建对应设备"
        return
    fi

    echo "  UDID: $UDID"

    # 启动模拟器
    xcrun simctl boot "$UDID" 2>/dev/null || true
    sleep 2

    # 安装并启动应用
    xcrun simctl install "$UDID" "$APP_PATH"
    xcrun simctl launch "$UDID" "$BUNDLE_ID"
    sleep 3

    # 截图：城市列表
    xcrun simctl io "$UDID" screenshot \
        "$OUTPUT_DIR/${DEVICE_KEY}_01_city_list.png"
    echo "  ✓ 截图1: 城市列表"

    # 切换到详情标签（通过 URL Scheme 或等待）
    sleep 2
    xcrun simctl io "$UDID" screenshot \
        "$OUTPUT_DIR/${DEVICE_KEY}_02_weather_detail.png"
    echo "  ✓ 截图2: 天气详情"

    # 关闭模拟器（可选）
    # xcrun simctl shutdown "$UDID"
}

for DEVICE in "${DEVICES[@]}"; do
    take_screenshots "$DEVICE"
done

echo ""
echo "🎉 截图完成！保存路径: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"/*.png 2>/dev/null | awk '{print "  " $NF}' || echo "  （暂无截图文件）"

echo ""
echo "📋 App Store 截图尺寸要求："
echo "  iPhone 17 Pro Max: 1320 × 2868 px (6.9\")"
echo "  iPhone 17 Pro:     1206 × 2622 px (6.3\")"
echo "  iPhone 17:         1179 × 2556 px (6.1\")"
