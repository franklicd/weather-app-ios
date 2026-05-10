//
//  WeatherDataConversionTests.swift
//  SimpleWeatherAppTests
//
//  Created by Claude on 2026/4/6.
//

import XCTest
@testable import WeatherApp

final class WeatherDataConversionTests: XCTestCase {
    func testCurrentWeatherConversion() throws {
        let qWeatherNow = QWeatherNow(
            temp: "25",
            feelsLike: "27",
            rh: "60",
            text: "晴",
            icon: "100",
            windSpeed: "10",
            vis: "10000",
            pressure: "1013"
        )

        let daily = [
            QWeatherDaily(
                fxDate: "2026-04-06",
                tempMax: "28",
                tempMin: "18",
                textDay: "晴",
                iconDay: "100",
                windSpeedDay: "8"
            ),
            QWeatherDaily(
                fxDate: "2026-04-07",
                tempMax: "26",
                tempMin: "17",
                textDay: "多云",
                iconDay: "101",
                windSpeedDay: "10"
            )
        ]

        let hourly = [
            QWeatherHourly(
                fxTime: "2026-04-06T12:00+08:00",
                temp: "25",
                text: "晴",
                icon: "100"
            ),
            QWeatherHourly(
                fxTime: "2026-04-06T13:00+08:00",
                temp: "26",
                text: "晴",
                icon: "100"
            )
        ]

        let weatherData = WeatherData.from(qWeatherNow: qWeatherNow, daily: daily, hourly: hourly)

        // 验证实时天气转换
        XCTAssertEqual(weatherData.current.temperature_2m, 25)
        XCTAssertEqual(weatherData.current.apparent_temperature, 27)
        XCTAssertEqual(weatherData.current.relative_humidity_2m, 60)
        XCTAssertEqual(weatherData.current.weather_code, 100)
        XCTAssertEqual(weatherData.current.wind_speed_10m, 10)
        XCTAssertEqual(weatherData.current.visibility, 10000)

        // 验证日预报转换
        XCTAssertEqual(weatherData.daily.time.count, 2)
        XCTAssertEqual(weatherData.daily.temperature_2m_max[0], 28)
        XCTAssertEqual(weatherData.daily.temperature_2m_min[0], 18)
        XCTAssertEqual(weatherData.daily.weather_code[0], 100)

        // 验证小时预报转换
        XCTAssertEqual(weatherData.hourly?.time.count, 2)
        XCTAssertEqual(weatherData.hourly?.temperature_2m[0], 25)
        XCTAssertEqual(weatherData.hourly?.weather_code[0], 100)
    }

    func testAirQualityConversion() throws {
        let qWeatherAir = QWeatherAirQuality(
            aqi: "50",
            pm2p5: "25",
            pm10: "40",
            o3: "80",
            uvIndex: "5"
        )

        let airQuality = AirQualityData.from(qWeatherAir: qWeatherAir)

        XCTAssertEqual(airQuality.us_aqi, 50)
        XCTAssertEqual(airQuality.pm2_5, 25)
        XCTAssertEqual(airQuality.pm10, 40)
        XCTAssertEqual(airQuality.uv_index, 5)
    }

    func testLocationConversion() throws {
        let qLocation = QWeatherLocation(
            name: "成都",
            lat: "30.5728",
            lon: "104.0668",
            country: "中国",
            adm1: "四川省",
            adm2: "成都市"
        )

        let geocodingResult = GeocodingResult(
            id: 0,
            name: qLocation.name,
            latitude: Double(qLocation.lat) ?? 0,
            longitude: Double(qLocation.lon) ?? 0,
            country: qLocation.country,
            admin1: qLocation.adm1,
            country_code: nil
        )

        XCTAssertEqual(geocodingResult.name, "成都")
        XCTAssertEqual(geocodingResult.latitude, 30.5728)
        XCTAssertEqual(geocodingResult.longitude, 104.0668)
        XCTAssertEqual(geocodingResult.subtitle, "四川省, 中国")
    }

    func testInvalidNumberConversion() throws {
        // 测试无效数值的容错处理
        let qWeatherNow = QWeatherNow(
            temp: "invalid",
            feelsLike: "27",
            rh: "invalid",
            text: "晴",
            icon: "invalid",
            windSpeed: "10",
            vis: "invalid",
            pressure: "1013"
        )

        let daily = [
            QWeatherDaily(
                fxDate: "2026-04-06",
                tempMax: "invalid",
                tempMin: "18",
                textDay: "晴",
                iconDay: "100",
                windSpeedDay: "8"
            )
        ]

        let hourly: [QWeatherHourly] = []

        let weatherData = WeatherData.from(qWeatherNow: qWeatherNow, daily: daily, hourly: hourly)

        // 无效数值应该转换为0而不是崩溃
        XCTAssertEqual(weatherData.current.temperature_2m, 0)
        XCTAssertEqual(weatherData.current.relative_humidity_2m, 0)
        XCTAssertEqual(weatherData.current.weather_code, 0)
        XCTAssertEqual(weatherData.current.visibility, 0)
        XCTAssertEqual(weatherData.daily.temperature_2m_max[0], 0)
    }
}
