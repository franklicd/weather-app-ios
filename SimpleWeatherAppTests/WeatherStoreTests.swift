import XCTest
@testable import WeatherApp

@MainActor
final class WeatherStoreTests: XCTestCase {
    var store: WeatherStore!

    override func setUp() async throws {
        store = WeatherStore()
        store.cities = []
    }

    override func tearDown() async throws {
        store = nil
    }

    // MARK: - addCity

    func testAddCity_appendsNewCity() {
        let preset = PresetCity(name: "测试城市", lat: 30.0, lon: 120.0)
        store.addCity(preset)
        XCTAssertEqual(store.cities.count, 1)
        XCTAssertEqual(store.cities.first?.name, "测试城市")
    }

    func testAddCity_preventsDuplicates() {
        let preset = PresetCity(name: "测试城市", lat: 30.0, lon: 120.0)
        store.addCity(preset)
        store.addCity(preset)
        XCTAssertEqual(store.cities.count, 1)
    }

    func testAddCity_allowsDifferentCities() {
        store.addCity(PresetCity(name: "北京", lat: 39.9, lon: 116.4))
        store.addCity(PresetCity(name: "上海", lat: 31.2, lon: 121.5))
        XCTAssertEqual(store.cities.count, 2)
    }

    // MARK: - removeCity

    func testRemoveCity_reducesCount() {
        store.cities = [
            CityWeather(name: "北京", lat: 39.9, lon: 116.4),
            CityWeather(name: "上海", lat: 31.2, lon: 121.5),
        ]
        store.removeCity(at: IndexSet([0]))
        XCTAssertEqual(store.cities.count, 1)
        XCTAssertEqual(store.cities.first?.name, "上海")
    }

    func testRemoveCity_clampsSelectedIndexWhenOutOfBounds() {
        store.cities = [
            CityWeather(name: "北京", lat: 39.9, lon: 116.4),
            CityWeather(name: "上海", lat: 31.2, lon: 121.5),
        ]
        store.selectedIndex = 1
        store.removeCity(at: IndexSet([1]))
        XCTAssertLessThan(store.selectedIndex, store.cities.count + 1)
        XCTAssertEqual(store.selectedIndex, 0)
    }

    // MARK: - selectedCity

    func testSelectedCity_returnsCorrectCity() {
        let cityA = CityWeather(name: "北京", lat: 39.9, lon: 116.4)
        let cityB = CityWeather(name: "上海", lat: 31.2, lon: 121.5)
        store.cities = [cityA, cityB]
        store.selectedIndex = 1
        XCTAssertEqual(store.selectedCity?.name, "上海")
    }

    func testSelectedCity_returnsNilWhenEmpty() {
        store.cities = []
        XCTAssertNil(store.selectedCity)
    }

    func testSelectedCity_returnsNilWhenIndexOutOfBounds() {
        store.cities = [CityWeather(name: "北京", lat: 39.9, lon: 116.4)]
        store.selectedIndex = 99
        XCTAssertNil(store.selectedCity)
    }

    func testSelectedCity_returnsFirstByDefault() {
        let city = CityWeather(name: "成都", lat: 30.6, lon: 104.1)
        store.cities = [city]
        store.selectedIndex = 0
        XCTAssertEqual(store.selectedCity?.name, "成都")
    }

    // MARK: - locationError

    func testLocationError_initiallyNil() {
        XCTAssertNil(store.locationError)
    }

    func testLocationError_setWhenDenied() {
        store.locationError = "位置权限被拒绝"
        XCTAssertNotNil(store.locationError)
    }

    func testLocationError_clearedManually() {
        store.locationError = "某错误"
        store.locationError = nil
        XCTAssertNil(store.locationError)
    }
}
