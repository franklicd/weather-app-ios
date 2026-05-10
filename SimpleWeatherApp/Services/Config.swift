//
//  Config.swift
//  SimpleWeatherApp
//
//  Created by Claude on 2026/4/6.
//

import Foundation
import CoreLocation

enum AppConfig {
    // 和风天气API Key - 请替换为你自己申请的Key
    static let qWeatherApiKey = "K9PRE2HXRR"

    // 和风天气API Secret - 与API Key对应，用于JWT签名
    static let qWeatherApiSecret = "MC4CAQAwBQYDK2VwBCIEILBbJ+TK+H4GMmxcj8MBjTH9bMQTmn2vIYQ/3R/zXhrw"

    // 和风天气专属API Host - 请替换为你在控制台获取的Host
    // 获取地址: https://console.qweather.com/setting
    static let qWeatherHost = "k33fc2e8n5.re.qweatherapi.com"

    // 和风天气API地址（使用专属Host）
    static var qWeatherBaseUrl: String { "https://\(qWeatherHost)/v7" }

    // 城市搜索API地址（使用专属Host）
    static var qWeatherGeoUrl: String { "https://\(qWeatherHost)/v2" }

    // JWT Token过期时间（秒）- 官方要求最长300秒(5分钟)，不能超过这个值
    static let jwtExpiresIn: TimeInterval = 300

    // 定位精度设置
    static let locationAccuracy = kCLLocationAccuracyHundredMeters

    // 定位缓存有效期（秒）- 5分钟内不再重复请求定位
    static let locationCacheTTL: TimeInterval = 300
}
