import Foundation
import SwiftUI

// MARK: - Weather Data

struct WeatherData: Codable {
    let current: CurrentWeather
    let daily: DailyForecast
    let hourly: HourlyForecast?
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

struct HourlyForecast: Codable {
    let time: [String]
    let temperature_2m: [Double]
    let weather_code: [Int]
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

// MARK: - Geocoding

struct GeocodingResult: Codable, Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?
    let country_code: String?

    var subtitle: String {
        [admin1, country].compactMap { $0 }.joined(separator: ", ")
    }
}

struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?
}

// MARK: - 和风天气数据模型
struct QWeatherResponse<T: Codable>: Codable {
    let code: String
    let fxLink: String?
    let refer: QWeatherRefer?
    let now: T?
    let daily: [T]?
    let hourly: [T]?
    let location: [T]?
}

struct QWeatherRefer: Codable {
    let sources: [String]?
    let license: [String]?
}

struct QWeatherNow: Codable {
    let temp: String
    let feelsLike: String
    let rh: String
    let text: String
    let icon: String
    let windSpeed: String
    let vis: String?
    let pressure: String?
}

struct QWeatherDaily: Codable {
    let fxDate: String
    let tempMax: String
    let tempMin: String
    let textDay: String
    let iconDay: String
    let windSpeedDay: String
}

struct QWeatherHourly: Codable {
    let fxTime: String
    let temp: String
    let text: String
    let icon: String
}

struct QWeatherAirQuality: Codable {
    let aqi: String
    let pm2p5: String?
    let pm10: String?
    let o3: String?
    let uvIndex: String?
}

struct QWeatherLocation: Codable {
    let name: String
    let lat: String
    let lon: String
    let country: String?
    let adm1: String?
    let adm2: String?
}

// MARK: - 和风天气数据转换扩展
extension WeatherData {
    static func from(qWeatherNow: QWeatherNow, daily: [QWeatherDaily], hourly: [QWeatherHourly]) -> WeatherData {
        let current = CurrentWeather(
            temperature_2m: Double(qWeatherNow.temp) ?? 0,
            relative_humidity_2m: Int(qWeatherNow.rh) ?? 0,
            apparent_temperature: Double(qWeatherNow.feelsLike) ?? 0,
            weather_code: Int(qWeatherNow.icon) ?? 0,
            wind_speed_10m: Double(qWeatherNow.windSpeed) ?? 0,
            visibility: Double(qWeatherNow.vis ?? "0") ?? 0
        )

        let dailyForecast = DailyForecast(
            time: daily.map { $0.fxDate },
            weather_code: daily.map { Int($0.iconDay) ?? 0 },
            temperature_2m_max: daily.map { Double($0.tempMax) ?? 0 },
            temperature_2m_min: daily.map { Double($0.tempMin) ?? 0 }
        )

        let hourlyForecast = HourlyForecast(
            time: hourly.map { $0.fxTime },
            temperature_2m: hourly.map { Double($0.temp) ?? 0 },
            weather_code: hourly.map { Int($0.icon) ?? 0 }
        )

        return WeatherData(
            current: current,
            daily: dailyForecast,
            hourly: hourlyForecast
        )
    }
}

extension AirQualityData {
    static func from(qWeatherAir: QWeatherAirQuality) -> AirQualityData {
        AirQualityData(
            us_aqi: Int(qWeatherAir.aqi) ?? 0,
            pm10: Double(qWeatherAir.pm10 ?? "0") ?? 0,
            pm2_5: Double(qWeatherAir.pm2p5 ?? "0") ?? 0,
            uv_index: Double(qWeatherAir.uvIndex ?? "0") ?? 0
        )
    }
}
