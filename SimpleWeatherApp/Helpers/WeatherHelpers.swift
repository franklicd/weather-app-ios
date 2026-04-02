import Foundation
import SwiftUI

// MARK: - Theme Colors
struct Theme {
    static func textPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white.opacity(0.95) : .black.opacity(0.9)
    }

    static func textSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6)
    }

    static func textTertiary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4)
    }
}

// MARK: - Safe Array Subscript

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Weather Code Helper

enum WeatherCode {
    static func color(for code: Int) -> Color {
        switch code {
        case 0:          return Color(red: 1.0, green: 0.84, blue: 0.0)  // 晴天 - 明亮金黄色
        case 1:          return Color(red: 1.0, green: 0.76, blue: 0.15) // 大致晴朗 - 暖黄色
        case 2:          return Color(red: 0.53, green: 0.71, blue: 0.89) // 局部多云 - 柔和蓝色
        case 3:          return Color(red: 0.55, green: 0.58, blue: 0.65) // 阴天 - 中性灰色
        case 45, 48:     return Color(red: 0.63, green: 0.66, blue: 0.71) // 雾 - 浅灰蓝色
        case 51...55:    return Color(red: 0.40, green: 0.65, blue: 0.90) // 毛毛雨 - 清新蓝色
        case 61...65:    return Color(red: 0.20, green: 0.50, blue: 0.85) // 小雨/中雨/大雨 - 经典蓝色
        case 71...77:    return Color(red: 0.80, green: 0.90, blue: 0.98) // 雪 - 冰晶蓝白色
        case 80...82:    return Color(red: 0.15, green: 0.40, blue: 0.75) // 阵雨 - 深邃蓝色
        case 85, 86:     return Color(red: 0.70, green: 0.88, blue: 0.98) // 阵雪 - 浅蓝白色
        case 95...99:    return Color(red: 0.55, green: 0.35, blue: 0.75) // 雷雨 - 神秘紫色
        default:         return Color(red: 0.55, green: 0.58, blue: 0.65) // 未知 - 中性灰色
        }
    }

    static func description(for code: Int) -> String {
        switch code {
        case 0:          return "晴天"
        case 1:          return "大致晴朗"
        case 2:          return "局部多云"
        case 3:          return "阴天"
        case 45, 48:     return "有雾"
        case 51:         return "毛毛雨（小）"
        case 53:         return "毛毛雨（中）"
        case 55:         return "毛毛雨（大）"
        case 61:         return "小雨"
        case 63:         return "中雨"
        case 65:         return "大雨"
        case 71:         return "小雪"
        case 73:         return "中雪"
        case 75:         return "大雪"
        case 77:         return "雪粒"
        case 80:         return "阵雨（小）"
        case 81:         return "阵雨（中）"
        case 82:         return "阵雨（强）"
        case 85, 86:     return "阵雪"
        case 95:         return "雷雨"
        case 96, 99:     return "雷雨伴冰雹"
        default:         return "未知天气"
        }
    }

    static func icon(for code: Int) -> String {
        switch code {
        case 0:          return "sun.max.fill"
        case 1:          return "sun.max"
        case 2:          return "cloud.sun.fill"
        case 3:          return "cloud.fill"
        case 45, 48:     return "cloud.fog.fill"
        case 51...55:    return "cloud.drizzle.fill"
        case 61...65:    return "cloud.rain.fill"
        case 71...77:    return "cloud.snow.fill"
        case 80...82:    return "cloud.heavyrain.fill"
        case 85, 86:     return "cloud.snow"
        case 95:         return "cloud.bolt.rain.fill"
        case 96, 99:     return "cloud.bolt.fill"
        default:         return "questionmark.circle"
        }
    }

    static func isRainy(_ code: Int) -> Bool {
        (51...55).contains(code) || (61...65).contains(code) || (80...82).contains(code)
    }

    static func isThunderstorm(_ code: Int) -> Bool {
        code == 95 || code == 96 || code == 99
    }

    static func isFoggy(_ code: Int) -> Bool {
        code == 45 || code == 48
    }
}

// MARK: - Air Quality Helper

enum AirQualityHelper {
    static func aqiLevel(for aqi: Int) -> String {
        switch aqi {
        case 0...50:   return "优"
        case 51...100: return "良"
        case 101...150: return "轻度污染"
        case 151...200: return "中度污染"
        case 201...300: return "重度污染"
        default:        return "严重污染"
        }
    }

    static func aqiColor(for aqi: Int) -> Color {
        switch aqi {
        case 0...50:    return .green
        case 51...100:  return Color(red: 0.6, green: 0.8, blue: 0.2)
        case 101...150: return .yellow
        case 151...200: return .orange
        case 201...300: return .red
        default:        return Color(red: 0.6, green: 0, blue: 0.2)
        }
    }

    static func uvLevel(for uv: Double) -> String {
        switch uv {
        case 0..<3:  return "低"
        case 3..<6:  return "中等"
        case 6..<8:  return "高"
        case 8..<11: return "很高"
        default:     return "极高"
        }
    }

    static func uvColor(for uv: Double) -> Color {
        switch uv {
        case 0..<3:  return .green
        case 3..<6:  return .yellow
        case 6..<8:  return .orange
        case 8..<11: return .red
        default:     return .purple
        }
    }

    static func uvAdvice(for uv: Double) -> String {
        switch uv {
        case 0..<3:  return "无需防护"
        case 3..<6:  return "建议涂抹防晒霜"
        case 6..<8:  return "需防晒，避免长时间户外活动"
        case 8..<11: return "强烈防晒，上午10点至下午4点尽量留在室内"
        default:     return "极端紫外线，避免户外活动"
        }
    }

    static func aqiAdvice(for aqi: Int) -> String {
        switch aqi {
        case 0...50:    return "空气质量良好，适合户外活动"
        case 51...100:  return "空气质量可接受，敏感人群注意"
        case 101...150: return "敏感人群减少户外活动"
        case 151...200: return "所有人减少户外活动，佩戴口罩"
        case 201...300: return "避免户外活动，必须外出请佩戴N95口罩"
        default:        return "严重污染，留在室内，关闭门窗"
        }
    }
}

// MARK: - Alert Generator

enum AlertGenerator {
    static func generate(from weather: WeatherData, airQuality: AirQualityData?) -> [WeatherAlert] {
        var alerts: [WeatherAlert] = []
        let current = weather.current

        // 高温预警
        if current.temperature_2m >= 40 {
            alerts.append(WeatherAlert(
                title: "极端高温预警",
                description: "当前气温 \(Int(current.temperature_2m))°C，请避免户外活动，防止中暑",
                icon: "thermometer.sun.fill",
                severity: .extreme
            ))
        } else if current.temperature_2m >= 35 {
            alerts.append(WeatherAlert(
                title: "高温预警",
                description: "当前气温 \(Int(current.temperature_2m))°C，注意防暑降温",
                icon: "thermometer.sun",
                severity: .high
            ))
        }

        // 低温预警
        if current.temperature_2m <= -15 {
            alerts.append(WeatherAlert(
                title: "极端低温预警",
                description: "当前气温 \(Int(current.temperature_2m))°C，注意防冻，减少外出",
                icon: "thermometer.snowflake",
                severity: .extreme
            ))
        } else if current.temperature_2m <= -5 {
            alerts.append(WeatherAlert(
                title: "低温预警",
                description: "当前气温 \(Int(current.temperature_2m))°C，注意保暖",
                icon: "thermometer.low",
                severity: .high
            ))
        }

        // 降雨提醒
        if WeatherCode.isThunderstorm(current.weather_code) {
            alerts.append(WeatherAlert(
                title: "雷雨预警",
                description: "当前有雷暴天气，请避免户外活动，注意安全",
                icon: "cloud.bolt.rain.fill",
                severity: .extreme
            ))
        } else if WeatherCode.isRainy(current.weather_code) {
            alerts.append(WeatherAlert(
                title: "降雨提醒",
                description: "当前有降雨，出行请携带雨具",
                icon: "cloud.rain.fill",
                severity: .low
            ))
        }

        // 大风预警
        if current.wind_speed_10m >= 30 {
            alerts.append(WeatherAlert(
                title: "大风预警",
                description: "风速 \(Int(current.wind_speed_10m)) km/h，注意防风安全",
                icon: "wind",
                severity: .extreme
            ))
        } else if current.wind_speed_10m >= 20 {
            alerts.append(WeatherAlert(
                title: "大风提醒",
                description: "风速 \(Int(current.wind_speed_10m)) km/h，注意户外安全",
                icon: "wind",
                severity: .medium
            ))
        }

        // 大雾预警
        if WeatherCode.isFoggy(current.weather_code) {
            let vis = current.visibility ?? 10000
            let severity: AlertSeverity = vis < 200 ? .extreme : (vis < 500 ? .high : .medium)
            alerts.append(WeatherAlert(
                title: "大雾预警",
                description: "能见度低，驾车请降速慢行",
                icon: "cloud.fog.fill",
                severity: severity
            ))
        }

        // 紫外线预警
        if let uv = airQuality?.uv_index {
            if uv >= 8 {
                alerts.append(WeatherAlert(
                    title: "高紫外线预警",
                    description: "UV指数 \(Int(uv))，\(AirQualityHelper.uvAdvice(for: uv))",
                    icon: "sun.max.trianglebadge.exclamationmark.fill",
                    severity: uv >= 11 ? .extreme : .high
                ))
            } else if uv >= 6 {
                alerts.append(WeatherAlert(
                    title: "紫外线提醒",
                    description: "UV指数 \(Int(uv))，\(AirQualityHelper.uvAdvice(for: uv))",
                    icon: "sun.max.fill",
                    severity: .medium
                ))
            }
        }

        // 空气质量预警
        if let aqi = airQuality?.us_aqi {
            if aqi >= 200 {
                alerts.append(WeatherAlert(
                    title: "空气质量严重污染",
                    description: "AQI \(aqi)，\(AirQualityHelper.aqiAdvice(for: aqi))",
                    icon: "aqi.high",
                    severity: .extreme
                ))
            } else if aqi >= 150 {
                alerts.append(WeatherAlert(
                    title: "空气质量预警",
                    description: "AQI \(aqi)，\(AirQualityHelper.aqiAdvice(for: aqi))",
                    icon: "aqi.medium",
                    severity: .high
                ))
            }
        }

        return alerts.sorted { $0.severity.rawValue > $1.severity.rawValue }
    }
}
