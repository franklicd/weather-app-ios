import SwiftUI

struct CityDetailView: View {
    @Environment(WeatherStore.self) private var store
    @State private var lastSelectedCityId: UUID?

    var body: some View {
        NavigationStack {
            Group {
                if let city = store.selectedCity {
                    CityWeatherDetailView(city: city) {
                        if let i = store.cities.firstIndex(where: { $0.id == city.id }) {
                            await store.fetchWeather(at: i)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "未选择城市",
                        systemImage: "cloud.sun",
                        description: Text("请在城市列表中选择一个城市")
                    )
                }
            }
            .navigationTitle(store.selectedCity?.name ?? "详情")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let idx = store.cities.firstIndex(where: { $0.id == store.selectedCity?.id }) {
                        Button {
                            Task { await store.fetchWeather(at: idx) }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(store.selectedCity?.isLoading == true)
                    }
                }
            }
            .onAppear {
                if let idx = store.cities.firstIndex(where: { $0.id == store.selectedCity?.id }) {
                    Task { await store.fetchWeather(at: idx) }
                }
            }
            .onChange(of: store.selectedCity?.id) { oldValue, newValue in
                if let newId = newValue, newId != lastSelectedCityId {
                    lastSelectedCityId = newId
                    if let idx = store.cities.firstIndex(where: { $0.id == newId }) {
                        store.clearCityData(at: idx)
                        Task { await store.fetchWeather(at: idx) }
                    }
                }
            }
        .background {
                WeatherBackgroundView(weatherCode: store.selectedCity?.weather?.current.weather_code)
                    .ignoresSafeArea()
            }
        } // NavigationStack
    }
}

// MARK: - Detail Content

struct CityWeatherDetailView: View {
    let city: CityWeather
    let onRefresh: () async -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 顶部告警横幅（始终在最顶部）
            if !city.alerts.isEmpty {
                AlertBannerView(alerts: city.alerts)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    if city.isLoading {
                        // 品牌化加载动画
                        WeatherLoadingView()
                            .padding(.top, 60)
                    } else if let weather = city.weather {
                        // 网络更新失败横幅（保留旧数据时显示）
                        if let err = city.fetchError {
                            Label(err, systemImage: "wifi.exclamationmark")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                        }

                        // 主温度卡片
                        MainWeatherCard(weather: weather.current)

                        // 预警横幅（保留在详情区域）
                        if !city.alerts.isEmpty {
                            AlertBannerSection(alerts: city.alerts)
                        }

                        // 小时预报
                        HourlyForecastSection(hourly: weather.hourly)

                        // 详细数据
                        WeatherDetailGrid(weather: weather.current)

                        // AQI & UV 卡片
                        if let aq = city.airQuality {
                            AirQualityCard(aq: aq)
                        }

                        // 7天预报
                        ForecastSection(daily: weather.daily)

                        if let updated = city.lastUpdated {
                            Text("更新于 \(updated.formatted(.dateTime.hour().minute()))")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .padding(.bottom, 8)
                        }
                    } else if let err = city.fetchError {
                        // 无数据且有错误时显示重试界面
                        VStack(spacing: 20) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 52))
                                .foregroundStyle(.orange)
                            Text("加载失败")
                                .font(.title3)
                                .fontWeight(.medium)
                            Text(err)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 60)
                    } else {
                        ContentUnavailableView(
                            "暂无数据",
                            systemImage: "wifi.slash",
                            description: Text("无法获取天气数据，请下拉刷新")
                        )
                        .padding(.top, 60)
                    }
                }
                .padding()
            }
            .refreshable {
                await onRefresh()
            }
            .background(.clear)
        }
    }
}

// MARK: - Main Weather Card

struct MainWeatherCard: View {
    let weather: CurrentWeather

    var body: some View {
        VStack(spacing: 12) {
            DynamicWeatherIcon(weatherCode: weather.weather_code)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

            TemperatureView(temperature: weather.temperature_2m)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)

            Text(WeatherCode.description(for: weather.weather_code))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary.opacity(0.9))

            Text("体感温度 \(Int(weather.apparent_temperature))°C")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Alert Banner

struct AlertBannerSection: View {
    let alerts: [WeatherAlert]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(alerts) { alert in
                HStack(spacing: 16) {
                    // 左侧图标和渐变背景
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [alert.severity.color.opacity(0.8), alert.severity.color.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: alert.icon)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: alert.severity.color.opacity(0.4), radius: 8, x: 0, y: 4)

                    // 右侧文字内容
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(alert.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(alert.severity.label)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [alert.severity.color, alert.severity.color.opacity(0.7)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                                .foregroundStyle(.white)
                        }
                        Text(alert.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    alert.severity.color.opacity(0.15),
                                    alert.severity.color.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: alert.severity.color.opacity(0.2), radius: 12, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            alert.severity.color.opacity(0.4),
                                            alert.severity.color.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                )
            }
        }
    }
}

// MARK: - Detail Grid

struct WeatherDetailGrid: View {
    let weather: CurrentWeather

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("详细信息")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                DetailCell(icon: "humidity.fill", label: "湿度", value: "\(weather.relative_humidity_2m)%", color: .blue)
                DetailCell(icon: "wind", label: "风速", value: "\(Int(weather.wind_speed_10m)) km/h", color: .teal)
                if let vis = weather.visibility {
                    DetailCell(icon: "eye.fill", label: "能见度", value: "\(Int(vis / 1000)) km", color: .purple)
                }
                DetailCell(icon: "thermometer.medium", label: "体感温度", value: "\(Int(weather.apparent_temperature))°C", color: .orange)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct DetailCell: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color)
            }
            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
            
            // 数值和标签
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - Air Quality Card

struct AirQualityCard: View {
    let aq: AirQualityData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("空气质量 & 紫外线")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                if let aqi = aq.us_aqi {
                    AQIGaugeView(aqi: aqi)
                }
                if let uv = aq.uv_index {
                    UVGaugeView(uv: uv)
                }
            }

            VStack(spacing: 8) {
                if let pm25 = aq.pm2_5 {
                    PollutantRow(label: "PM2.5", value: "\(Int(pm25)) μg/m³")
                }
                if let pm10 = aq.pm10 {
                    PollutantRow(label: "PM10", value: "\(Int(pm10)) μg/m³")
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct PollutantRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
    }
}

struct AQIGaugeView: View {
    let aqi: Int
    
    private let aqiColor: Color
    private let aqiLevel: String
    
    init(aqi: Int) {
        self.aqi = aqi
        self.aqiColor = AirQualityHelper.aqiColor(for: aqi)
        self.aqiLevel = AirQualityHelper.aqiLevel(for: aqi)
    }

    var body: some View {
        VStack(spacing: 8) {
            // 圆形仪表盘
            ZStack {
                // 背景圆环
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                // 进度圆环
                Circle()
                    .trim(from: 0, to: min(Double(aqi) / 300.0, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [aqiColor, aqiColor.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                // AQI数值
                VStack(spacing: 2) {
                    Text("\(aqi)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(aqiColor)
                    Text("AQI")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 等级标签
            Text(aqiLevel)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(aqiColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(aqiColor.opacity(0.2))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
        )
    }
}

struct UVGaugeView: View {
    let uv: Double
    
    private let uvColor: Color
    private let uvLevel: String
    
    init(uv: Double) {
        self.uv = uv
        self.uvColor = AirQualityHelper.uvColor(for: uv)
        self.uvLevel = AirQualityHelper.uvLevel(for: uv)
    }

    var body: some View {
        VStack(spacing: 8) {
            // 圆形仪表盘
            ZStack {
                // 背景圆环
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                // 进度圆环
                Circle()
                    .trim(from: 0, to: min(Double(uv) / 11.0, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [uvColor, uvColor.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                // UV数值
                VStack(spacing: 2) {
                    Text("\(Int(uv))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(uvColor)
                    Text("紫外线")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 等级标签
            Text(uvLevel)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(uvColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(uvColor.opacity(0.2))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - Hourly Forecast Section

struct HourlyForecastSection: View {
    let hourly: HourlyForecast?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("24小时预报")
                .font(.headline)
                .fontWeight(.semibold)
            
            if hourly != nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(hourlyItems.prefix(24).enumerated()), id: \.element.time) { index, item in
                            HourlyForecastItem(
                                time: item.time,
                                temperature: item.temperature,
                                weatherCode: item.weatherCode,
                                isNow: index == 0
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } else {
                // 占位视图，当没有小时预报数据时显示
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { _ in
                        HourlyForecastPlaceholder()
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    struct HourlyItem {
        let time: String
        let temperature: Double
        let weatherCode: Int
    }
    
    var hourlyItems: [HourlyItem] {
        guard let hourly = hourly else { return [] }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        displayFormatter.locale = Locale(identifier: "zh_CN")
        
        return zip(hourly.time, zip(hourly.temperature_2m, hourly.weather_code)).compactMap { time, tempAndCode in
            let (temp, code) = tempAndCode
            let displayTime: String
            if let date = formatter.date(from: time) {
                displayTime = displayFormatter.string(from: date)
            } else {
                displayTime = String(time.suffix(5))
            }
            return HourlyItem(time: displayTime, temperature: temp, weatherCode: code)
        }
    }
}

struct HourlyForecastItem: View {
    let time: String
    let temperature: Double
    let weatherCode: Int
    let isNow: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text(isNow ? "现在" : time)
                .font(.caption)
                .fontWeight(isNow ? .semibold : .medium)
                .foregroundStyle(isNow ? .white : .primary.opacity(0.8))
            
            Image(systemName: WeatherCode.icon(for: weatherCode))
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(isNow ? .white : .orange)
                .shadow(color: isNow ? .white.opacity(0.5) : .orange.opacity(0.3), radius: 4, x: 0, y: 2)
            
            Text("\(Int(temperature))°")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(isNow ? .white : .primary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(minWidth: 70)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    isNow ?
                    LinearGradient(
                        colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF8E53")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isNow ? Color(hex: "#FF6B6B").opacity(0.4) : .black.opacity(0.15), radius: isNow ? 10 : 6, x: 0, y: isNow ? 6 : 3)
        )
    }
}

struct HourlyForecastPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 30, height: 12)
                .cornerRadius(6)
            
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 24, height: 24)
                .cornerRadius(12)
            
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 28, height: 16)
                .cornerRadius(8)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(minWidth: 70)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Forecast Section

struct ForecastSection: View {
    let daily: DailyForecast

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("7天预报")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 0) {
                ForEach(forecastItems, id: \.date) { item in
                    HStack(spacing: 16) {
                        // 日期
                        Text(item.date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(width: 70, alignment: .leading)
                        
                        // 天气图标
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: WeatherCode.icon(for: item.code))
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.orange)
                        }
                        
                        // 天气描述
                        Text(WeatherCode.description(for: item.code))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // 温度范围
                        HStack(spacing: 12) {
                            Text("\(Int(item.min))°")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                            
                            // 温度进度条
                            GeometryReader { geometry in
                                let range = (item.max - item.min)
                                let normalizedMax = range > 0 ? CGFloat((item.max - item.min) / range) : 0.5
                                let normalizedMin = range > 0 ? CGFloat(0) : 0.5
                                
                                ZStack(alignment: .leading) {
                                    // 背景条
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 6)
                                    
                                    // 温度范围条
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue, Color.orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * (normalizedMax - normalizedMin), height: 6)
                                        .offset(x: geometry.size.width * normalizedMin)
                                }
                            }
                            .frame(width: 80, height: 6)
                            
                            Text("\(Int(item.max))°")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.vertical, 12)
                    
                    if item.date != forecastItems.last?.date {
                        Divider()
                            .background(Color.white.opacity(0.15))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }

    struct ForecastItem {
        let date: String
        let code: Int
        let max: Double
        let min: Double
    }

    var forecastItems: [ForecastItem] {
        let count = min(7, daily.time.count)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let display = DateFormatter()
        display.dateFormat = "M/d E"
        display.locale = Locale(identifier: "zh_CN")

        return (0..<count).compactMap { i in
            guard i < daily.weather_code.count,
                  i < daily.temperature_2m_max.count,
                  i < daily.temperature_2m_min.count else { return nil }
            let label: String
            if let date = formatter.date(from: daily.time[i]) {
                label = i == 0 ? "今天" : display.string(from: date)
            } else {
                label = daily.time[i]
            }
            return ForecastItem(
                date: label,
                code: daily.weather_code[i],
                max: daily.temperature_2m_max[i],
                min: daily.temperature_2m_min[i]
            )
        }
    }
}
