import Foundation

// MARK: - Preset Cities

enum CityDataService {
    static let presetCities: [PresetCity] = [
        PresetCity(name: "成都", lat: 30.5728, lon: 104.0668),
        PresetCity(name: "北京", lat: 39.9042, lon: 116.4074),
        PresetCity(name: "上海", lat: 31.2304, lon: 121.4737),
        PresetCity(name: "深圳", lat: 22.5431, lon: 114.0579),
        PresetCity(name: "杭州", lat: 30.2741, lon: 120.1551),
        PresetCity(name: "广州", lat: 23.1291, lon: 113.2644),
        PresetCity(name: "西安", lat: 34.3416, lon: 108.9398),
        PresetCity(name: "重庆", lat: 29.5630, lon: 106.5516),
        PresetCity(name: "武汉", lat: 30.5928, lon: 114.3055),
        PresetCity(name: "南京", lat: 32.0603, lon: 118.7969),
        PresetCity(name: "天津", lat: 39.3434, lon: 117.3616),
        PresetCity(name: "苏州", lat: 31.2989, lon: 120.5853),
        PresetCity(name: "郑州", lat: 34.7466, lon: 113.6253),
        PresetCity(name: "长沙", lat: 28.2282, lon: 112.9388),
        PresetCity(name: "青岛", lat: 36.0671, lon: 120.3826),
        PresetCity(name: "厦门", lat: 24.4798, lon: 118.0894),
        PresetCity(name: "昆明", lat: 25.0453, lon: 102.7097),
        PresetCity(name: "大连", lat: 38.9140, lon: 121.6147),
        PresetCity(name: "沈阳", lat: 41.8057, lon: 123.4315),
        PresetCity(name: "哈尔滨", lat: 45.8038, lon: 126.5349),
    ]

    // MARK: - Persistence

    private static let storageKey = "saved_cities"

    static func loadCities() -> [CityWeather] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let cities = try? JSONDecoder().decode([CityWeather].self, from: data) else {
            return defaultCities()
        }
        return cities
    }

    static func saveCities(_ cities: [CityWeather]) {
        if let data = try? JSONEncoder().encode(cities) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private static func defaultCities() -> [CityWeather] {
        [
            CityWeather(name: "成都", lat: 30.5728, lon: 104.0668),
            CityWeather(name: "北京", lat: 39.9042, lon: 116.4074),
            CityWeather(name: "上海", lat: 31.2304, lon: 121.4737),
        ]
    }
}
