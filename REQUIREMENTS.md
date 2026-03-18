# WeatherApp - iOS 天气应用需求文档

## 项目概述
开发一个 iOS 天气应用，使用 SwiftUI 框架，支持 iOS 26+ 最新 API。

## 技术栈
- **语言**: Swift 6.0+
- **框架**: SwiftUI (iOS 26+)
- **API**: Open-Meteo (免费天气API)
- **数据持久化**: UserDefaults (轻量级存储)
- **定位**: CoreLocation

## 功能需求

### 1. 核心功能
- [ ] 显示当前城市实时天气（温度、湿度、风速、能见度、体感温度）
- [ ] GPS 定位获取当前位置
- [ ] 多城市管理（添加/删除/查看）
- [ ] 5天天气预报

### 2. 天气预警系统
自动检测并显示以下预警：
- [ ] 高温预警（≥35°C，极端≥40°C）
- [ ] 低温预警（≤-5°C，极端≤-15°C）
- [ ] 降雨提醒（毛毛雨、雨、阵雨）
- [ ] 雷雨预警（雷暴天气）
- [ ] 大风预警（≥20km/h，极端≥30km/h）
- [ ] 大雾预警（能见度低）
- [ ] 紫外线预警（UV ≥ 6，高≥8）
- [ ] 空气质量预警（AQI ≥ 150，重度≥200）

预警级别：low(蓝色) / medium(黄色) / high(橙色) / extreme(红色)

### 3. 空气质量与紫外线
- [ ] 显示 AQI 指数（美国标准）
- [ ] 显示 PM2.5 数值
- [ ] 显示 UV 指数
- [ ] 提供防护建议

### 4. 预设城市（20个）
成都、北京、上海、深圳、杭州、广州、西安、重庆、武汉、南京、天津、苏州、郑州、长沙、青岛、厦门、昆明、大连、沈阳、哈尔滨

## 界面设计

### Tab 导航（3个标签）
1. **城市** - 城市列表，可添加/删除/查看
2. **详情** - 当前选中城市的详细天气
3. **设置** - 刷新数据、版本信息

### 主要视图
- **CityListView**: 城市列表，支持搜索、添加、删除
- **CityDetailView**: 天气详情、预警横幅、AQI/UV卡片、5天预报
- **SettingsView**: 设置页面

## 数据模型

### WeatherData
```swift
struct WeatherData: Codable {
    let current: CurrentWeather
    let daily: DailyForecast
}
```

### CurrentWeather
- temperature_2m: Double (当前温度)
- relative_humidity_2m: Int (湿度)
- apparent_temperature: Double (体感温度)
- weather_code: Int (天气代码)
- wind_speed_10m: Double (风速)
- visibility: Double? (能见度)

### AirQualityData
- us_aqi: Int? (美国AQI)
- pm10: Double?
- pm2_5: Double?
- uv_index: Double?

### CityWeather
- id: UUID
- name: String
- lat: Double (纬度)
- lon: Double (经度)
- isCurrentLocation: Bool
- weather: WeatherData?
- airQuality: AirQualityData?
- alerts: [WeatherAlert]
- isLoading: Bool
- lastUpdated: Date?

### WeatherAlert
- id: UUID
- title: String
- description: String
- icon: String (SF Symbols)
- severity: AlertSeverity (low/medium/high/extreme)

### AlertSeverity
```swift
enum AlertSeverity: Int, Codable {
    case low = 1      // 蓝色
    case medium = 2   // 黄色
    case high = 3     // 橙色
    case extreme = 4  // 红色
    
    var color: Color { ... }
}
```

## API 接口

### 天气数据
```
https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,visibility&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto
```

### 空气质量数据
```
https://air-quality-api.open-meteo.com/v1/air-quality?latitude={lat}&longitude={lon}&current=us_aqi,pm10,pm2_5,uv_index&timezone=auto
```

## 技术要求

### iOS 26+ 最新 API
- 使用 NavigationStack 替代 NavigationView
- 使用新的 Section 语法（header 闭包）
- 使用 .task 替代 .onAppear
- 使用 topBarLeading/Trailing 替代 navigationBarLeading/Trailing
- 使用 @State 替代 @StateObject（iOS 17+）

### 代码结构
- 模块化设计，每个文件 < 250 行
- Models/Helpers/Services/Views 分层
- 所有数据模型支持 Codable
- 手动实现 CityWeather 的 Codable（处理默认值）

### 辅助方法
- WeatherCode: 天气代码转描述和图标
- AirQualityHelper: AQI/UV 等级转换

## 权限配置
在 Info.plist 添加：
```
NSLocationWhenInUseUsageDescription: 需要获取您的位置来显示当地天气
```

## 文件结构
```
WeatherApp/
├── WeatherApp.swift          (App入口)
├── Models/
│   └── WeatherModels.swift   (数据模型)
├── Helpers/
│   └── WeatherHelpers.swift  (辅助方法)
├── Services/
│   ├── CityDataService.swift (城市数据)
│   ├── WeatherStore.swift    (天气服务)
│   └── LocationService.swift (定位服务)
├── Views/
│   ├── CityListView.swift    (城市列表)
│   ├── CityDetailView.swift  (详情页面)
│   └── SettingsView.swift    (设置页面)
└── Assets.xcassets
```

## 版本
- v1.2.0 - 支持 iOS 26+，使用最新 SwiftUI API

## 注意事项
1. 使用模块化文件，不要创建单文件版本
2. 所有类型必须支持 Codable（Color 用 AlertSeverity 替代）
3. 每个文件保持 < 250 行
4. 使用 SF Symbols 图标
5. 支持深色模式（使用系统颜色）
