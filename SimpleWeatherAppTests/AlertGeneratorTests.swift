import XCTest
@testable import WeatherApp

final class AlertGeneratorTests: XCTestCase {

    // MARK: - Helpers

    func makeWeather(
        temp: Double = 20,
        windSpeed: Double = 5,
        weatherCode: Int = 0,
        visibility: Double? = 10000
    ) -> WeatherData {
        let current = CurrentWeather(
            temperature_2m: temp,
            relative_humidity_2m: 60,
            apparent_temperature: temp - 2,
            weather_code: weatherCode,
            wind_speed_10m: windSpeed,
            visibility: visibility
        )
        let daily = DailyForecast(
            time: ["2026-03-15"],
            weather_code: [weatherCode],
            temperature_2m_max: [temp + 5],
            temperature_2m_min: [temp - 5]
        )
        return WeatherData(current: current, daily: daily, hourly: nil)
    }

    func makeAQ(aqi: Int? = nil, uv: Double? = nil) -> AirQualityData {
        AirQualityData(us_aqi: aqi, pm10: nil, pm2_5: nil, uv_index: uv)
    }

    // MARK: - Temperature Alerts

    func testHighTemperatureAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(temp: 38), airQuality: nil)
        XCTAssertTrue(alerts.contains { $0.title == "高温预警" })
    }

    func testExtremeTemperatureAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(temp: 42), airQuality: nil)
        XCTAssertTrue(alerts.contains { $0.title == "极端高温预警" && $0.severity == .extreme })
    }

    func testLowTemperatureAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(temp: -8), airQuality: nil)
        XCTAssertTrue(alerts.contains { $0.title == "低温预警" && $0.severity == .high })
    }

    func testExtremeLowTemperatureAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(temp: -20), airQuality: nil)
        XCTAssertTrue(alerts.contains { $0.title == "极端低温预警" && $0.severity == .extreme })
    }

    func testNormalTemperature_noTempAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(temp: 25), airQuality: nil)
        XCTAssertFalse(alerts.contains { $0.title.contains("温度") || $0.title.contains("温") })
    }

    // MARK: - Wind Alerts

    func testModerateWindAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(windSpeed: 25), airQuality: nil)
        XCTAssertTrue(alerts.contains { $0.title == "大风提醒" && $0.severity == .medium })
    }

    func testExtremeWindAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(windSpeed: 35), airQuality: nil)
        XCTAssertTrue(alerts.contains { $0.title == "大风预警" && $0.severity == .extreme })
    }

    // MARK: - Weather Code Alerts

    func testThunderstormAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(weatherCode: 95), airQuality: nil)
        XCTAssertTrue(alerts.contains { $0.title == "雷雨预警" && $0.severity == .extreme })
    }

    func testRainAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(weatherCode: 61), airQuality: nil)
        XCTAssertTrue(alerts.contains { $0.title == "降雨提醒" })
    }

    func testFogAlert() {
        let alerts = AlertGenerator.generate(
            from: makeWeather(weatherCode: 45, visibility: 1000), airQuality: nil
        )
        XCTAssertTrue(alerts.contains { $0.title == "大雾预警" })
    }

    // MARK: - Air Quality Alerts

    func testModerateAQIAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(), airQuality: makeAQ(aqi: 180))
        XCTAssertTrue(alerts.contains { $0.title == "空气质量预警" && $0.severity == .high })
    }

    func testSevereAQIAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(), airQuality: makeAQ(aqi: 250))
        XCTAssertTrue(alerts.contains { $0.title == "空气质量严重污染" && $0.severity == .extreme })
    }

    // MARK: - UV Alerts

    func testUVHighAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(), airQuality: makeAQ(uv: 7.0))
        XCTAssertTrue(alerts.contains { $0.title == "紫外线提醒" })
    }

    func testUVExtremeAlert() {
        let alerts = AlertGenerator.generate(from: makeWeather(), airQuality: makeAQ(uv: 12.0))
        XCTAssertTrue(alerts.contains { $0.title == "高紫外线预警" && $0.severity == .extreme })
    }

    // MARK: - Sorting

    func testAlertsSortedBySeverityDescending() {
        let data = makeWeather(temp: 38, windSpeed: 25, weatherCode: 61)
        let alerts = AlertGenerator.generate(from: data, airQuality: nil)
        guard alerts.count > 1 else { return }
        for i in 0..<(alerts.count - 1) {
            XCTAssertGreaterThanOrEqual(
                alerts[i].severity.rawValue,
                alerts[i + 1].severity.rawValue,
                "预警应按严重程度降序排列"
            )
        }
    }

    func testNoAlertsForNormalConditions() {
        let data = makeWeather(temp: 22, windSpeed: 10, weatherCode: 2)
        let alerts = AlertGenerator.generate(from: data, airQuality: makeAQ(aqi: 40, uv: 2.0))
        XCTAssertTrue(alerts.isEmpty, "正常天气条件下不应产生预警")
    }
}
