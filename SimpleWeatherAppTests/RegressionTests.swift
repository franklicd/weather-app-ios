//
//  RegressionTests.swift
//  SimpleWeatherAppTests
//
//  Created by Claude on 2026/4/6.
//

import XCTest
import CoreLocation
@testable import WeatherApp

@MainActor
final class RegressionTests: XCTestCase {

    func testLocationServiceBasicFunctionality() async throws {
        // 测试定位服务基本功能没有被破坏
        let locationService = LocationService()

        // 验证初始状态（currentLocation 和 locationName 在新实例上应为默认值）
        XCTAssertNil(locationService.currentLocation)
        XCTAssertEqual(locationService.locationName, "当前位置")
        // authorizationStatus 取决于模拟器当前的权限状态，
        // 无法保证一定是 .notDetermined，只验证它是合法枚举值即可
        let validStatuses: [CLAuthorizationStatus] = [.notDetermined, .restricted, .denied, .authorizedAlways, .authorizedWhenInUse]
        XCTAssertTrue(validStatuses.contains(locationService.authorizationStatus), "授权状态应为合法枚举值")
    }

    func testCityDataServicePresetCities() async throws {
        // 测试预设城市列表正常（使用公开的 presetCities 属性）
        let presetCities = CityDataService.presetCities
        XCTAssertFalse(presetCities.isEmpty, "预设城市列表不能为空")
        XCTAssertTrue(presetCities.contains { $0.name == "成都" }, "预设城市应该包含成都")
        XCTAssertTrue(presetCities.contains { $0.name == "北京" }, "预设城市应该包含北京")
        XCTAssertTrue(presetCities.contains { $0.name == "上海" }, "预设城市应该包含上海")
    }

    func testWeatherStoreInitialState() async throws {
        // 测试WeatherStore初始状态正常
        let store = WeatherStore()
        XCTAssertFalse(store.cities.isEmpty, "初始城市列表不能为空")
        XCTAssertNil(store.locationError, "初始定位错误应该为空")
    }

    func testLocalPersistence() async throws {
        // 测试本地持久化功能正常
        let store = WeatherStore()
        let initialCount = store.cities.count

        // 添加一个测试城市
        let testCity = CityWeather(name: "测试城市", lat: 0, lon: 0)
        store.cities.append(testCity)
        store.saveCities()

        // 重新加载
        let newStore = WeatherStore()
        XCTAssertEqual(newStore.cities.count, initialCount + 1, "保存的城市应该能被正确加载")
        XCTAssertTrue(newStore.cities.contains { $0.name == "测试城市" }, "测试城市应该被持久化")

        // 清理测试数据
        newStore.cities.removeAll { $0.name == "测试城市" }
        newStore.saveCities()
    }

    func testWeatherModelCompatibility() async throws {
        // 测试原有WeatherData模型兼容性
        let json = """
        {
            "current": {
                "temperature_2m": 25,
                "relative_humidity_2m": 60,
                "apparent_temperature": 27,
                "weather_code": 100,
                "wind_speed_10m": 10,
                "visibility": 10000
            },
            "daily": {
                "time": ["2026-04-06"],
                "weather_code": [100],
                "temperature_2m_max": [28],
                "temperature_2m_min": [18]
            },
            "hourly": {
                "time": ["2026-04-06T12:00"],
                "temperature_2m": [25],
                "weather_code": [100]
            }
        }
        """

        guard let data = json.data(using: .utf8),
              let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data) else {
            XCTFail("原有WeatherData模型解析失败，兼容性被破坏")
            return
        }

        XCTAssertEqual(weatherData.current.temperature_2m, 25)
        XCTAssertEqual(weatherData.daily.temperature_2m_max[0], 28)
    }

    func testBackwardCompatibility() async throws {
        // 测试旧数据可以正常解析（无 hourly 字段时应仍可解码）
        let oldCityWeatherJSON = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "旧城市",
            "lat": 30.5728,
            "lon": 104.0668,
            "isCurrentLocation": false,
            "weather": {
                "current": {
                    "temperature_2m": 25,
                    "relative_humidity_2m": 60,
                    "apparent_temperature": 27,
                    "weather_code": 100,
                    "wind_speed_10m": 10
                },
                "daily": {
                    "time": ["2026-04-06"],
                    "weather_code": [100],
                    "temperature_2m_max": [28],
                    "temperature_2m_min": [18]
                }
            }
        }
        """

        guard let data = oldCityWeatherJSON.data(using: .utf8),
              let city = try? JSONDecoder().decode(CityWeather.self, from: data) else {
            XCTFail("旧版本CityWeather数据解析失败，向后兼容性被破坏")
            return
        }

        XCTAssertEqual(city.name, "旧城市")
        XCTAssertEqual(city.weather?.current.temperature_2m, 25)
    }
}
