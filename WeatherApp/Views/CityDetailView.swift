import SwiftUI

struct CityDetailView: View {
    @Environment(WeatherStore.self) private var store
    @State private var lastSelectedCityId: UUID?

    var body: some View {
        ZStack {
            // 天气动画背景
            WeatherBackgroundView(weatherCode: store.selectedCity?.weather?.current.weather_code)
            
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
                // 进入详情页时自动刷新当前城市天气
                if let idx = store.cities.firstIndex(where: { $0.id == store.selectedCity?.id }) {
                    Task { await store.fetchWeather(at: idx) }
                }
            }
            .onChange(of: store.selectedCity?.id) { oldValue, newValue in
                // 切换城市时强制刷新
                if let newId = newValue, newId != lastSelectedCityId {
                    lastSelectedCityId = newId
                    if let idx = store.cities.firstIndex(where: { $0.id == newId }) {
                        // 清空当前城市数据，显示加载状态
                        store.clearCityData(at: idx)
                        Task { await store.fetchWeather(at: idx) }
                    }
                }
            }
            }
        }
    }
}

// MARK: - Detail Content

struct CityWeatherDetailView: View {
    let city: CityWeather
    let onRefresh: () async -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if city.isLoading {
                    ProgressView("加载天气数据...")
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

                    // 预警横幅
                    if !city.alerts.isEmpty {
                        AlertBannerSection(alerts: city.alerts)
                    }

                    // 详细数据
                    WeatherDetailGrid(weather: weather.current)

                    // AQI & UV 卡片
                    if let aq = city.airQuality {
                        AirQualityCard(aq: aq)
                    }

                    // 5天预报
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
    }
}

// MARK: - Main Weather Card

struct MainWeatherCard: View {
    let weather: CurrentWeather

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: WeatherCode.icon(for: weather.weather_code))
                .font(.system(size: 64))
                .foregroundStyle(.orange)
                .symbolRenderingMode(.multicolor)

            Text("\(Int(weather.temperature_2m))°C")
                .font(.system(size: 72, weight: .thin))

            Text(WeatherCode.description(for: weather.weather_code))
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("体感温度 \(Int(weather.apparent_temperature))°C")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Alert Banner

struct AlertBannerSection: View {
    let alerts: [WeatherAlert]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(alerts) { alert in
                HStack(spacing: 12) {
                    Image(systemName: alert.icon)
                        .font(.title3)
                        .foregroundStyle(alert.severity.color)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(alert.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(alert.severity.label)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(alert.severity.color.opacity(0.2))
                                .foregroundStyle(alert.severity.color)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        Text(alert.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(alert.severity.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(alert.severity.color.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Detail Grid

struct WeatherDetailGrid: View {
    let weather: CurrentWeather

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            DetailCell(icon: "humidity.fill", label: "湿度", value: "\(weather.relative_humidity_2m)%", color: .blue)
            DetailCell(icon: "wind", label: "风速", value: "\(Int(weather.wind_speed_10m)) km/h", color: .teal)
            if let vis = weather.visibility {
                DetailCell(icon: "eye.fill", label: "能见度", value: "\(Int(vis / 1000)) km", color: .purple)
            }
            DetailCell(icon: "thermometer.medium", label: "体感温度", value: "\(Int(weather.apparent_temperature))°C", color: .orange)
        }
    }
}

struct DetailCell: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer()
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Air Quality Card

struct AirQualityCard: View {
    let aq: AirQualityData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("空气质量 & 紫外线")
                .font(.headline)

            HStack(spacing: 12) {
                if let aqi = aq.us_aqi {
                    AQIGaugeView(aqi: aqi)
                }
                if let uv = aq.uv_index {
                    UVGaugeView(uv: uv)
                }
            }

            if let pm25 = aq.pm2_5 {
                HStack {
                    Text("PM2.5")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(pm25)) μg/m³")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            if let pm10 = aq.pm10 {
                HStack {
                    Text("PM10")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(pm10)) μg/m³")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct AQIGaugeView: View {
    let aqi: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("AQI")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(aqi)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(AirQualityHelper.aqiColor(for: aqi))
            Text(AirQualityHelper.aqiLevel(for: aqi))
                .font(.caption2)
                .foregroundStyle(AirQualityHelper.aqiColor(for: aqi))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(AirQualityHelper.aqiColor(for: aqi).opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct UVGaugeView: View {
    let uv: Double

    var body: some View {
        VStack(spacing: 4) {
            Text("紫外线")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(Int(uv))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(AirQualityHelper.uvColor(for: uv))
            Text(AirQualityHelper.uvLevel(for: uv))
                .font(.caption2)
                .foregroundStyle(AirQualityHelper.uvColor(for: uv))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(AirQualityHelper.uvColor(for: uv).opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Forecast Section

struct ForecastSection: View {
    let daily: DailyForecast

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("5天预报")
                .font(.headline)
                .padding(.bottom, 4)

            ForEach(forecastItems, id: \.date) { item in
                HStack {
                    Text(item.date)
                        .font(.subheadline)
                        .frame(width: 60, alignment: .leading)
                    Image(systemName: WeatherCode.icon(for: item.code))
                        .foregroundStyle(.orange)
                        .frame(width: 28)
                    Text(WeatherCode.description(for: item.code))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Text("\(Int(item.min))°")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    Text("~")
                        .foregroundStyle(.secondary)
                    Text("\(Int(item.max))°")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
                .padding(.vertical, 4)
                if item.date != forecastItems.last?.date {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    struct ForecastItem {
        let date: String
        let code: Int
        let max: Double
        let min: Double
    }

    var forecastItems: [ForecastItem] {
        let count = min(5, daily.time.count)
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
