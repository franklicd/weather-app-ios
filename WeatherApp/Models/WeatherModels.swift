import Foundation
import SwiftUI

// MARK: - Weather Data

struct WeatherData: Codable {
    let current: CurrentWeather
    let daily: DailyForecast
}

struct CurrentWeather: Codable {
    let temperature_2m: Double
    let relative_humidity_2m: Int
    let apparent_temperature: Double
    let weather_code: Int
    let wind_speed_10m: Double
    let visibility: Double?
}

struct DailyForecast: Codable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
}

// MARK: - Air Quality

struct AirQualityResponse: Codable {
    let current: AirQualityData
}

struct AirQualityData: Codable {
    let us_aqi: Int?
    let pm10: Double?
    let pm2_5: Double?
    let uv_index: Double?
}

// MARK: - Alert Severity

enum AlertSeverity: Int, Codable, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case extreme = 4

    var color: Color {
        switch self {
        case .low:     return .blue
        case .medium:  return .yellow
        case .high:    return .orange
        case .extreme: return .red
        }
    }

    var label: String {
        switch self {
        case .low:     return "提示"
        case .medium:  return "注意"
        case .high:    return "警告"
        case .extreme: return "紧急"
        }
    }
}

// MARK: - Weather Alert

struct WeatherAlert: Codable, Identifiable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let icon: String
    let severity: AlertSeverity
}

// MARK: - City Weather

struct CityWeather: Identifiable {
    var id: UUID = UUID()
    var name: String
    var lat: Double
    var lon: Double
    var isCurrentLocation: Bool = false
    var weather: WeatherData?
    var airQuality: AirQualityData?
    var alerts: [WeatherAlert] = []
    var isLoading: Bool = false
    var lastUpdated: Date?
    var fetchError: String?
}

// MARK: - CityWeather Codable

extension CityWeather: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, lat, lon, isCurrentLocation, weather, airQuality, alerts, lastUpdated
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        lat = try c.decode(Double.self, forKey: .lat)
        lon = try c.decode(Double.self, forKey: .lon)
        isCurrentLocation = (try? c.decode(Bool.self, forKey: .isCurrentLocation)) ?? false
        weather = try? c.decode(WeatherData.self, forKey: .weather)
        airQuality = try? c.decode(AirQualityData.self, forKey: .airQuality)
        alerts = (try? c.decode([WeatherAlert].self, forKey: .alerts)) ?? []
        isLoading = false
        fetchError = nil
        lastUpdated = try? c.decode(Date.self, forKey: .lastUpdated)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(lat, forKey: .lat)
        try c.encode(lon, forKey: .lon)
        try c.encode(isCurrentLocation, forKey: .isCurrentLocation)
        try? c.encode(weather, forKey: .weather)
        try? c.encode(airQuality, forKey: .airQuality)
        try c.encode(alerts, forKey: .alerts)
        try? c.encode(lastUpdated, forKey: .lastUpdated)
    }
}

// MARK: - Preset City

struct PresetCity {
    let name: String
    let lat: Double
    let lon: Double
}
