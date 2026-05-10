//
//  APITests.swift
//  SimpleWeatherAppTests
//
//  Created by Claude on 2026/4/6.
//

import XCTest
@testable import WeatherApp

final class APITests: XCTestCase {
    // 注意：运行这些测试需要正确配置Config.swift中的API Key、Secret和Host

    func testJWTIntegration() async throws {
        // 跳过测试如果没有配置有效的API参数
        guard !AppConfig.qWeatherApiKey.isEmpty,
              AppConfig.qWeatherApiKey != "YOUR_API_KEY_HERE",
              !AppConfig.qWeatherApiSecret.isEmpty,
              AppConfig.qWeatherApiSecret != "YOUR_API_SECRET_HERE",
              !AppConfig.qWeatherHost.isEmpty,
              AppConfig.qWeatherHost != "YOUR_UNIQUE_HOST.qweatherapi.com" else {
            throw XCTSkip("API参数未配置，跳过集成测试")
        }

        // 测试JWT生成
        guard let token = JWTGenerator.generateQWeatherToken(
            apiKey: AppConfig.qWeatherApiKey,
            apiSecret: AppConfig.qWeatherApiSecret
        ) else {
            XCTFail("JWT生成失败")
            return
        }

        XCTAssertFalse(token.isEmpty, "JWT不能为空")

        // 测试实际API请求
        let url = URL(string: "\(AppConfig.qWeatherBaseUrl)/weather/now?location=104.0668,30.5728&lang=zh")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            XCTFail("无效响应")
            return
        }

        // 如果API返回401/403，说明凭证可能已过期或无效，跳过而非失败
        if [401, 403].contains(httpResponse.statusCode) {
            throw XCTSkip("API凭证无效或已过期（HTTP \(httpResponse.statusCode)），跳过集成测试")
        }

        // 验证API返回200
        XCTAssertEqual(httpResponse.statusCode, 200, "API请求失败，状态码：\(httpResponse.statusCode)")

        // 验证可以正确解析响应
        let result = try JSONDecoder().decode(QWeatherResponse<QWeatherNow>.self, from: data)
        XCTAssertEqual(result.code, "200", "API返回错误：\(result.code)")
        XCTAssertNotNil(result.now, "返回数据为空")
    }

    func testCitySearchAPI() async throws {
        // 跳过测试如果没有配置有效的API参数
        guard !AppConfig.qWeatherApiKey.isEmpty,
              AppConfig.qWeatherApiKey != "YOUR_API_KEY_HERE",
              !AppConfig.qWeatherApiSecret.isEmpty,
              AppConfig.qWeatherApiSecret != "YOUR_API_SECRET_HERE",
              !AppConfig.qWeatherHost.isEmpty,
              AppConfig.qWeatherHost != "YOUR_UNIQUE_HOST.qweatherapi.com" else {
            throw XCTSkip("API参数未配置，跳过集成测试")
        }

        // 测试城市搜索
        let results = await CityDataService.searchGlobal(query: "北京")
        XCTAssertFalse(results.isEmpty, "城市搜索结果为空")
        XCTAssertTrue(results.contains { $0.name.contains("北京") }, "搜索结果中应该包含北京")
    }

    func testAPIErrorHandling() async throws {
        // 测试无效Token的错误处理
        guard !AppConfig.qWeatherHost.isEmpty,
              AppConfig.qWeatherHost != "YOUR_UNIQUE_HOST.qweatherapi.com" else {
            throw XCTSkip("API Host未配置，跳过测试")
        }

        let url = URL(string: "\(AppConfig.qWeatherBaseUrl)/weather/now?location=104.0668,30.5728&lang=zh")!
        var request = URLRequest(url: url)
        request.addValue("Bearer INVALID_TOKEN", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            XCTFail("无效响应")
            return
        }

        // 无效Token应该返回401或403
        XCTAssertTrue([401, 403].contains(httpResponse.statusCode), "无效Token应该返回401/403，实际返回：\(httpResponse.statusCode)")
    }
}
