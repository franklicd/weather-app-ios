import SwiftUI

// MARK: - City Detail View (outer shell)

struct CityDetailView: View {
    @Environment(WeatherStore.self) private var store

    var body: some View {
        NavigationStack {
            Group {
                if let city = store.selectedCity {
                    RedesignedCityDetailView(city: city) {
                        if let i = store.cities.firstIndex(where: { $0.id == city.id }) {
                            await store.fetchWeather(at: i, sendNotification: true)
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
                            Task { await store.fetchWeather(at: idx, sendNotification: true) }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(store.selectedCity?.isLoading == true)
                    }
                }
            }
            .background {
                WeatherBackgroundView(weatherCode: store.selectedCity?.weather?.current.weather_code)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Redesigned City Detail View

struct RedesignedCityDetailView: View {
    let city: CityWeather
    let onRefresh: () async -> Void

    @State private var contentAppear = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: DTSpacing.lg) {
                if city.isLoading {
                    WeatherLoadingView()
                        .padding(.top, 60)
                        .opacity(contentAppear ? 1 : 0)
                        .scaleEffect(contentAppear ? 1 : 0.8)
                        .animation(DTAnimation.standardSpring.delay(0.1), value: contentAppear)
                } else if let weather = city.weather {
                    weatherContent(weather: weather)
                } else if let err = city.fetchError {
                    errorView(err)
                } else {
                    ContentUnavailableView(
                        "暂无数据",
                        systemImage: "wifi.slash",
                        description: Text("无法获取天气数据，请下拉刷新")
                    )
                    .padding(.top, 60)
                }
            }
            .padding(.horizontal, DTSpacing.lg)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .refreshable { await onRefresh() }
        .background(.clear)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                contentAppear = true
            }
        }
    }

    // MARK: - Weather Content

    @ViewBuilder
    private func weatherContent(weather: WeatherData) -> some View {
        // 1. Hero Card
        RedesignedHeroCard(weather: weather.current, alertCount: city.alerts.count)
            .opacity(contentAppear ? 1 : 0)
            .offset(y: contentAppear ? 0 : 30)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: contentAppear)

        // 2. Error banner (stale data warning)
        if let err = city.fetchError {
            HStack(spacing: DTSpacing.xs) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 14))
                Text(err)
                    .font(DTFont.body3.font)
            }
            .foregroundStyle(DTColor.Semantic.warning)
            .padding(.horizontal, DTSpacing.md)
            .padding(.vertical, DTSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DTRadius.md)
                    .fill(DTColor.Semantic.warning.opacity(0.1))
            )
            .opacity(contentAppear ? 1 : 0)
            .offset(y: contentAppear ? 0 : 15)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: contentAppear)
        }

        // 3. Alert Banner
        if !city.alerts.isEmpty {
            RedesignedAlertBanner(alerts: city.alerts)
                .opacity(contentAppear ? 1 : 0)
                .offset(y: contentAppear ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: contentAppear)
        }

        // 4. Hourly Forecast
        let hourlyItems = buildHourlyItems(current: weather.current, hourly: weather.hourly)
        if !hourlyItems.isEmpty {
            RedesignedHourlyForecast(items: hourlyItems)
                .opacity(contentAppear ? 1 : 0)
                .offset(y: contentAppear ? 0 : 25)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: contentAppear)
        }

        // 5. Detail Grid
        RedesignedDetailGrid(weather: weather.current)
            .opacity(contentAppear ? 1 : 0)
            .offset(y: contentAppear ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: contentAppear)

        // 6. AQI & UV Card
        if let aq = city.airQuality {
            RedesignedAQIUVCard(aq: aq)
                .opacity(contentAppear ? 1 : 0)
                .offset(y: contentAppear ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5), value: contentAppear)
        }

        // 7. 7-Day Forecast
        RedesignedForecastSection(daily: weather.daily)
            .opacity(contentAppear ? 1 : 0)
            .offset(y: contentAppear ? 0 : 25)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.6), value: contentAppear)

        // 8. Last updated timestamp
        if let updated = city.lastUpdated {
            Text("更新于 \(updated.formatted(.dateTime.hour().minute()))")
                .font(DTFont.caption2.font)
                .foregroundStyle(.tertiary)
                .padding(.bottom, DTSpacing.sm)
                .opacity(contentAppear ? 1 : 0)
                .animation(.easeInOut.delay(0.7), value: contentAppear)
        }
    }

    // MARK: - Error View

    @ViewBuilder
    private func errorView(_ err: String) -> some View {
        VStack(spacing: DTSpacing.xl) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 52))
                .foregroundStyle(DTColor.Semantic.warning)
            Text("加载失败")
                .font(DTFont.title2.font)
            Text(err)
                .font(DTFont.body2.font)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DTSpacing.xxxl)
        .padding(.top, 60)
        .opacity(contentAppear ? 1 : 0)
        .scaleEffect(contentAppear ? 1 : 0.8)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: contentAppear)
    }

    // MARK: - Hourly Items Builder

    private func buildHourlyItems(current: CurrentWeather?, hourly: HourlyForecast?) -> [RedesignedHourlyForecast.HourlyItem] {
        var items: [RedesignedHourlyForecast.HourlyItem] = []

        if let current = current {
            items.append(RedesignedHourlyForecast.HourlyItem(
                time: "现在",
                temperature: current.temperature_2m,
                weatherCode: current.weather_code,
                isNow: true
            ))
        }

        guard let hourly = hourly else { return items }

        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm"
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current

        let display = DateFormatter()
        display.dateFormat = "HH:mm"
        display.locale = Locale(identifier: "zh_CN")
        display.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current

        let now = Date()

        var parsed: [(date: Date, time: String, temp: Double, code: Int)] = []
        for i in 0..<min(hourly.time.count, hourly.temperature_2m.count, hourly.weather_code.count) {
            if let date = parser.date(from: hourly.time[i]) {
                parsed.append((date: date, time: display.string(from: date), temp: hourly.temperature_2m[i], code: hourly.weather_code[i]))
            }
        }

        let future = parsed.filter { $0.date > now }
        let maxItems = current != nil ? 23 : 24

        for item in future.prefix(maxItems) {
            items.append(RedesignedHourlyForecast.HourlyItem(
                time: item.time,
                temperature: item.temp,
                weatherCode: item.code,
                isNow: false
            ))
        }

        return items
    }
}
