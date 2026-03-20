# SimpleWeatherApp - App Store 发布检查列表

## 项目配置检查

- [x] 项目路径引用修复（从 WeatherApp/ 到 SimpleWeatherApp/）
- [x] Info.plist 路径配置正确
- [x] CFBundlePackageType 设置为 APPL
- [x] 应用图标（AppIcon）完整，包含所有必要尺寸
- [x] 应用名称和副标题设置（简天气 - 实时天气预报）
- [x] Bundle ID 配置正确（com.lyc.weatherapp.ios）
- [x] 版本号设置正确（1.2.0）

## 资源文件检查

- [x] PrivacyInfo.xcprivacy 文件存在且格式正确
- [x] Assets.xcassets 包含所有必要资源
- [x] AccentColor.colorset 配置正确
- [x] Info.plist 配置完整（权限描述、支持方向等）
- [x] 启动屏幕（SplashScreenView.swift）实现

## 构建验证

- [x] Debug 构建成功
- [x] Release 构建成功
- [x] Archive 归档成功创建
- [x] 应用可在模拟器上正常运行

## App Store 准备状态

- [x] 应用图标（1024x1024）准备就绪
- [x] 应用预设功能完整（天气查询、城市管理、定位服务）
- [x] 隐私政策配置完整（声明了位置数据使用）
- [x] 权限说明完整（NSLocationWhenInUseUsageDescription）
- [x] 支持的应用方向配置正确

## 提交所需材料

- [ ] 应用截图（iPhone、iPad 各尺寸）
- [ ] 应用描述文案
- [ ] 关键词列表
- [ ] 隐私政策 URL（需部署到服务器）
- [ ] 应用预览视频（可选）

## 后续步骤

1. 在模拟器中生成应用截图
2. 准备 App Store Connect 的描述文案
3. 部署隐私政策页面
4. 提交至 App Store Connect
5. 等待苹果审核