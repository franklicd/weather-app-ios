import XCTest
@testable import SimpleWeatherApp

final class WeatherModelsTests: XCTestCase {

    // MARK: - CityWeather Codable

    func testCityWeather_codableRoundtrip() throws {
        var city = CityWeather(name: "北京", lat: 39.9, lon: 116.4)
        city.isCurrentLocation = false

        let data = try JSONEncoder().encode(city)
        let decoded = try JSONDecoder().decode(CityWeather.self, from: data)

        XCTAssertEqual(decoded.name, city.name)
        XCTAssertEqual(decoded.lat, city.lat)
        XCTAssertEqual(decoded.lon, city.lon)
        XCTAssertEqual(decoded.isCurrentLocation, false)
        XCTAssertFalse(decoded.isLoading)
        XCTAssertNil(decoded.fetchError)
    }

    func testCityWeather_fetchErrorNotPersisted() throws {
        var city = CityWeather(name: "上海", lat: 31.2, lon: 121.5)
        city.fetchError = "网络错误"

        let data = try JSONEncoder().encode(city)
        let decoded = try JSONDecoder().decode(CityWeather.self, from: data)

        XCTAssertNil(decoded.fetchError, "fetchError 是瞬态字段，不应被持久化")
    }

    func testCityWeather_isLoadingNotPersisted() throws {
        var city = CityWeather(name: "广州", lat: 23.1, lon: 113.3)
        city.isLoading = true

        let data = try JSONEncoder().encode(city)
        let decoded = try JSONDecoder().decode(CityWeather.self, from: data)

        XCTAssertFalse(decoded.isLoading, "isLoading 是瞬态字段，解码后应为 false")
    }

    // MARK: - CurrentWeather Decodable

    func testCurrentWeather_decodesFromJSON() throws {
        let json = """
        {
            "temperature_2m": 25.5,
            "relative_humidity_2m": 60,
            "apparent_temperature": 27.0,
            "weather_code": 2,
            "wind_speed_10m": 10.5,
            "visibility": 10000.0
        }
        """.data(using: .utf8)!

        let weather = try JSONDecoder().decode(CurrentWeather.self, from: json)
        XCTAssertEqual(weather.temperature_2m, 25.5)
        XCTAssertEqual(weather.relative_humidity_2m, 60)
        XCTAssertEqual(weather.weather_code, 2)
        XCTAssertEqual(weather.wind_speed_10m, 10.5)
        XCTAssertEqual(weather.visibility, 10000.0)
    }

    func testCurrentWeather_visibilityOptional() throws {
        let json = """
        {
            "temperature_2m": 20.0,
            "relative_humidity_2m": 50,
            "apparent_temperature": 21.0,
            "weather_code": 0,
            "wind_speed_10m": 5.0
        }
        """.data(using: .utf8)!

        let weather = try JSONDecoder().decode(CurrentWeather.self, from: json)
        XCTAssertNil(weather.visibility)
    }

    // MARK: - DailyForecast Decodable

    func testDailyForecast_decodesFromJSON() throws {
        let json = """
        {
            "time": ["2026-03-15", "2026-03-16", "2026-03-17"],
            "weather_code": [0, 2, 61],
            "temperature_2m_max": [28.0, 26.0, 22.0],
            "temperature_2m_min": [15.0, 14.0, 12.0]
        }
        """.data(using: .utf8)!

        let forecast = try JSONDecoder().decode(DailyForecast.self, from: json)
        XCTAssertEqual(forecast.time.count, 3)
        XCTAssertEqual(forecast.weather_code[0], 0)
        XCTAssertEqual(forecast.temperature_2m_max[1], 26.0)
        XCTAssertEqual(forecast.temperature_2m_min[2], 12.0)
    }

    // MARK: - AlertSeverity

    func testAlertSeverity_labels() {
        XCTAssertEqual(AlertSeverity.low.label, "提示")
        XCTAssertEqual(AlertSeverity.medium.label, "注意")
        XCTAssertEqual(AlertSeverity.high.label, "警告")
        XCTAssertEqual(AlertSeverity.extreme.label, "紧急")
    }

    func testAlertSeverity_rawValues() {
        XCTAssertEqual(AlertSeverity.low.rawValue, 1)
        XCTAssertEqual(AlertSeverity.medium.rawValue, 2)
        XCTAssertEqual(AlertSeverity.high.rawValue, 3)
        XCTAssertEqual(AlertSeverity.extreme.rawValue, 4)
    }

    // MARK: - WeatherAlert Codable

    func testWeatherAlert_codableRoundtrip() throws {
        let alert = WeatherAlert(
            title: "高温预警",
            description: "请注意防暑降温",
            icon: "thermometer.sun",
            severity: .high
        )

        let data = try JSONEncoder().encode(alert)
        let decoded = try JSONDecoder().decode(WeatherAlert.self, from: data)

        XCTAssertEqual(decoded.title, alert.title)
        XCTAssertEqual(decoded.description, alert.description)
        XCTAssertEqual(decoded.icon, alert.icon)
        XCTAssertEqual(decoded.severity, alert.severity)
    }
}
