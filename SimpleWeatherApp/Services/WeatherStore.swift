import Foundation
import SwiftUI
import CoreLocation
import Observation

@MainActor
@Observable
class WeatherStore {
    static let shared = WeatherStore()

    var cities: [CityWeather] = []
    var selectedIndex: Int = 0 {
        willSet {
            // When user selects a new city, immediately start pre-loading its data
            // 并为当前选中的城市发送通知
            if cities.indices.contains(newValue) {
                // If data already exists, no need to load again
                if cities[newValue].weather == nil ||
                   cities[newValue].lastUpdated == nil ||
                   Date().timeIntervalSince(cities[newValue].lastUpdated!) > 15 * 60 {
                    Task { await fetchWeather(at: newValue, sendNotification: true) }
                }
            }
        }
    }
    var locationError: String?

    private let locationService = LocationService()
    private let notificationManager = NotificationManager.shared

    var selectedCity: CityWeather? {
        guard cities.indices.contains(selectedIndex) else { return nil }
        return cities[selectedIndex]
    }

    init() {
        cities = CityDataService.loadCities()
        startAutoRefresh()
        notificationManager.requestNotificationPermission()
    }

    // 仅当尚未有当前定位城市时才自动获取定位
    func startLocationOnLaunchIfNeeded() {
        guard !cities.contains(where: { $0.isCurrentLocation }) else { return }
        addCurrentLocation()
    }

    // 30 分钟自动刷新所有城市
    private func startAutoRefresh() {
        Task {
            // 启动后立即刷新一次所有城市
            await fetchAllWeather()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30 * 60))
                guard !Task.isCancelled else { break }
                await fetchAllWeather()
            }
        }
    }

    // MARK: - City Management

    func addCity(_ preset: PresetCity) {
        guard !cities.contains(where: { $0.name == preset.name }) else { return }
        let city = CityWeather(name: preset.name, lat: preset.lat, lon: preset.lon)
        cities.append(city)
        saveCities()
        let index = cities.count - 1
        Task { await fetchWeather(at: index) }
    }

    func removeCity(at offsets: IndexSet) {
        let removingCurrentLocation = offsets.contains(where: { cities[$0].isCurrentLocation })
        cities.remove(atOffsets: offsets)
        if selectedIndex >= cities.count {
            selectedIndex = max(0, cities.count - 1)
        }
        if removingCurrentLocation {
            locationService.currentLocation = nil
        }
        saveCities()
    }

    func saveCities() {
        CityDataService.saveCities(cities)
    }

    // MARK: - Weather Fetching

    func fetchWeather(at index: Int, sendNotification: Bool = false) async {
        guard cities.indices.contains(index) else { return }
        cities[index].isLoading = true
        cities[index].fetchError = nil
        let lat = cities[index].lat
        let lon = cities[index].lon
        let cityId = cities[index].id
        let cityName = cities[index].name

        async let weatherResult = fetchWeatherData(lat: lat, lon: lon)
        async let aqResult = fetchAirQuality(lat: lat, lon: lon)

        let (weather, aq) = await (weatherResult, aqResult)

        guard cities.indices.contains(index) else { return }
        cities[index].weather = weather
        // 保留旧的 AQI 数据，仅在成功获取新数据时才更新
        if let aq = aq {
            cities[index].airQuality = aq
        }
        if let weather {
            // 使用最新的 AQI 数据（新获取的或缓存的）
            let effectiveAQ = aq ?? cities[index].airQuality
            let newAlerts = AlertGenerator.generate(from: weather, airQuality: effectiveAQ)
            cities[index].alerts = newAlerts
            // 只有在需要发送通知且是当前选中的城市时才发送推送
            if sendNotification && index == selectedIndex {
                for alert in newAlerts {
                    notificationManager.sendWeatherAlertIfNeeded(cityId: cityId, cityName: cityName, alert: alert)
                }
            }
        }
        if weather == nil {
            cities[index].fetchError = "网络请求失败，请检查网络连接后下拉刷新"
        }
        cities[index].isLoading = false
        if weather != nil {
            cities[index].lastUpdated = Date()
        }
        saveCities()
    }

    func fetchAllWeather() async {
        await withTaskGroup(of: Void.self) { group in
            for index in cities.indices {
                group.addTask { await self.fetchWeather(at: index) }
            }
        }
    }

    // 后台刷新所有城市（用于后台任务）
    func fetchAllWeatherBackground() async {
        await withTaskGroup(of: Void.self) { group in
            for index in cities.indices {
                // 后台刷新时，只有当前选中的城市才发送通知
                let shouldNotify = (index == selectedIndex)
                group.addTask { await self.fetchWeather(at: index, sendNotification: shouldNotify) }
            }
        }
    }

    // 清空指定城市的数据（切换城市时使用）
    func clearCityData(at index: Int) {
        guard cities.indices.contains(index) else { return }
        cities[index].weather = nil
        cities[index].airQuality = nil
        cities[index].alerts = []
        cities[index].fetchError = nil
    }

    // MARK: - Location

    func addCurrentLocation() {
        locationError = nil
        let status = locationService.authorizationStatus
        if status == .denied || status == .restricted {
            locationError = "位置权限被拒绝，请前往「设置 > 隐私与安全性 > 位置服务」开启"
            return
        }
        locationService.requestLocation()
        Task {
            try? await Task.sleep(for: .seconds(3))
            let currentStatus = locationService.authorizationStatus
            if currentStatus == .denied || currentStatus == .restricted {
                locationError = "位置权限被拒绝，请前往「设置 > 隐私与安全性 > 位置服务」开启"
                return
            }
            guard let loc = locationService.currentLocation else {
                if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
                    locationError = "获取位置超时，请检查 GPS 信号后重试"
                }
                return
            }
            let name = locationService.locationName
            if let existing = cities.firstIndex(where: { $0.isCurrentLocation }) {
                cities[existing].lat = loc.coordinate.latitude
                cities[existing].lon = loc.coordinate.longitude
                cities[existing].name = name
                await fetchWeather(at: existing)
            } else {
                var city = CityWeather(
                    name: name,
                    lat: loc.coordinate.latitude,
                    lon: loc.coordinate.longitude,
                    isCurrentLocation: true
                )
                city.isLoading = true
                cities.insert(city, at: 0)
                await fetchWeather(at: 0)
            }
            saveCities()
        }
    }

    // MARK: - Private API

    private func fetchWeatherData(lat: Double, lon: Double) async -> WeatherData? {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            .init(name: "latitude", value: "\(lat)"),
            .init(name: "longitude", value: "\(lon)"),
            .init(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,visibility"),
            .init(name: "hourly", value: "temperature_2m,weather_code"),
            .init(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            .init(name: "forecast_days", value: "7"),
            .init(name: "timezone", value: "auto"),
        ]
        guard let url = components.url else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(WeatherData.self, from: data)
        } catch {
            // 记录错误以便调试，但在发布版本中不输出敏感信息
            #if DEBUG
            print("Weather fetch error: \(error)")
            #endif
            return nil
        }
    }

    // MARK: - JWT鉴权
    private func getQWeatherAuthHeader() -> [String: String]? {
        guard !AppConfig.qWeatherApiKey.isEmpty,
              AppConfig.qWeatherApiKey != "YOUR_API_KEY_HERE",
              !AppConfig.qWeatherApiSecret.isEmpty,
              AppConfig.qWeatherApiSecret != "YOUR_API_SECRET_HERE" else {
            return nil
        }

        guard let token = JWTGenerator.generateQWeatherToken(
            apiKey: AppConfig.qWeatherApiKey,
            apiSecret: AppConfig.qWeatherApiSecret,
            expiresIn: AppConfig.jwtExpiresIn
        ) else {
            return nil
        }

        return ["Authorization": "Bearer \(token)"]
    }

    // MARK: - 和风天气API请求
    private func fetchQWeatherNow(lat: Double, lon: Double) async throws -> QWeatherNow? {
        var components = URLComponents(string: "\(AppConfig.qWeatherBaseUrl)/weather/now")!
        components.queryItems = [
            .init(name: "location", value: "\(lon),\(lat)"),
            .init(name: "lang", value: "zh")
        ]
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        guard let authHeader = getQWeatherAuthHeader() else {
            #if DEBUG
            print("请先配置和风天气API Key和Secret")
            #endif
            return nil
        }
        authHeader.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(QWeatherResponse<QWeatherNow>.self, from: data)
        guard response.code == "200" else {
            print("和风天气API错误: \(response.code)")
            return nil
        }
        return response.now
    }

    private func fetchQWeatherDaily(lat: Double, lon: Double) async throws -> [QWeatherDaily] {
        var components = URLComponents(string: "\(AppConfig.qWeatherBaseUrl)/weather/7d")!
        components.queryItems = [
            .init(name: "location", value: "\(lon),\(lat)"),
            .init(name: "lang", value: "zh")
        ]
        guard let url = components.url else { return [] }

        var request = URLRequest(url: url)
        if let authHeader = getQWeatherAuthHeader() {
            authHeader.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        } else {
            components.queryItems?.append(.init(name: "key", value: AppConfig.qWeatherApiKey))
            request.url = components.url
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(QWeatherResponse<QWeatherDaily>.self, from: data)
        guard response.code == "200", let daily = response.daily else {
            return []
        }
        return daily
    }

    private func fetchQWeatherHourly(lat: Double, lon: Double) async throws -> [QWeatherHourly] {
        var components = URLComponents(string: "\(AppConfig.qWeatherBaseUrl)/weather/24h")!
        components.queryItems = [
            .init(name: "location", value: "\(lon),\(lat)"),
            .init(name: "lang", value: "zh")
        ]
        guard let url = components.url else { return [] }

        var request = URLRequest(url: url)
        if let authHeader = getQWeatherAuthHeader() {
            authHeader.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        } else {
            components.queryItems?.append(.init(name: "key", value: AppConfig.qWeatherApiKey))
            request.url = components.url
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(QWeatherResponse<QWeatherHourly>.self, from: data)
        guard response.code == "200", let hourly = response.hourly else {
            return []
        }
        return hourly
    }

    private func fetchAirQuality(lat: Double, lon: Double) async -> AirQualityData? {
        var components = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")!
        components.queryItems = [
            .init(name: "latitude", value: "\(lat)"),
            .init(name: "longitude", value: "\(lon)"),
            .init(name: "current", value: "us_aqi,pm10,pm2_5,uv_index"),
            .init(name: "timezone", value: "auto"),
        ]

        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue("SimpleWeatherApp iOS", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(AirQualityResponse.self, from: data)
            return response.current
        } catch {
            #if DEBUG
            print("Air quality fetch error: \(error)")
            #endif
            return nil
        }
    }

    // MARK: - 和风天气相关代码（暂时注释，需要时启用）
    /*
    // MARK: - JWT鉴权
    private func getQWeatherAuthHeader() -> [String: String]? {
        guard !AppConfig.qWeatherApiKey.isEmpty,
              AppConfig.qWeatherApiKey != "YOUR_API_KEY_HERE",
              !AppConfig.qWeatherApiSecret.isEmpty,
              AppConfig.qWeatherApiSecret != "YOUR_API_SECRET_HERE" else {
            return nil
        }

        guard let token = JWTGenerator.generateQWeatherToken(
            apiKey: AppConfig.qWeatherApiKey,
            apiSecret: AppConfig.qWeatherApiSecret,
            expiresIn: AppConfig.jwtExpiresIn
        ) else {
            return nil
        }

        return ["Authorization": "Bearer \(token)"]
    }

    // MARK: - 和风天气API请求
    private func fetchQWeatherNow(lat: Double, lon: Double) async throws -> QWeatherNow? {
        var components = URLComponents(string: "\(AppConfig.qWeatherBaseUrl)/weather/now")!
        components.queryItems = [
            .init(name: "location", value: "\(lon),\(lat)"),
            .init(name: "lang", value: "zh")
        ]
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        guard let authHeader = getQWeatherAuthHeader() else {
            #if DEBUG
            print("请先配置和风天气API Key和Secret")
            #endif
            return nil
        }
        authHeader.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(QWeatherResponse<QWeatherNow>.self, from: data)
        guard response.code == "200" else {
            print("和风天气API错误: \(response.code)")
            return nil
        }
        return response.now
    }

    private func fetchQWeatherDaily(lat: Double, lon: Double) async throws -> [QWeatherDaily] {
        var components = URLComponents(string: "\(AppConfig.qWeatherBaseUrl)/weather/7d")!
        components.queryItems = [
            .init(name: "location", value: "\(lon),\(lat)"),
            .init(name: "lang", value: "zh")
        ]
        guard let url = components.url else { return [] }

        var request = URLRequest(url: url)
        if let authHeader = getQWeatherAuthHeader() {
            authHeader.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        } else {
            components.queryItems?.append(.init(name: "key", value: AppConfig.qWeatherApiKey))
            request.url = components.url
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(QWeatherResponse<QWeatherDaily>.self, from: data)
        guard response.code == "200", let daily = response.daily else {
            return []
        }
        return daily
    }

    private func fetchQWeatherHourly(lat: Double, lon: Double) async throws -> [QWeatherHourly] {
        var components = URLComponents(string: "\(AppConfig.qWeatherBaseUrl)/weather/24h")!
        components.queryItems = [
            .init(name: "location", value: "\(lon),\(lat)"),
            .init(name: "lang", value: "zh")
        ]
        guard let url = components.url else { return [] }

        var request = URLRequest(url: url)
        if let authHeader = getQWeatherAuthHeader() {
            authHeader.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        } else {
            components.queryItems?.append(.init(name: "key", value: AppConfig.qWeatherApiKey))
            request.url = components.url
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(QWeatherResponse<QWeatherHourly>.self, from: data)
        guard response.code == "200", let hourly = response.hourly else {
            return []
        }
        return hourly
    }
    */
}
