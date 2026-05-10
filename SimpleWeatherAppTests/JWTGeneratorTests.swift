//
//  JWTGeneratorTests.swift
//  SimpleWeatherAppTests
//
//  Created by Claude on 2026/4/6.
//

import XCTest
@testable import WeatherApp

final class JWTGeneratorTests: XCTestCase {
    let testApiKey = "TEST_API_KEY"
    let testApiSecret = "TEST_API_SECRET_123456789"

    func testJWTGeneration() throws {
        // 测试JWT是否能正常生成
        guard let token = JWTGenerator.generateQWeatherToken(
            apiKey: testApiKey,
            apiSecret: testApiSecret,
            expiresIn: 300
        ) else {
            XCTFail("JWT生成失败")
            return
        }

        // 验证JWT格式：三段式，用.分隔
        let parts = token.components(separatedBy: ".")
        XCTAssertEqual(parts.count, 3, "JWT格式不正确，应该包含3个部分")

        // 验证Header和Payload可以正确解码
        guard let headerData = Data(base64URLEncoded: parts[0]),
              let payloadData = Data(base64URLEncoded: parts[1]),
              let header = try? JSONSerialization.jsonObject(with: headerData) as? [String: Any],
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            XCTFail("JWT解码失败")
            return
        }

        // 验证Header字段
        XCTAssertEqual(header["alg"] as? String, "HS256", "签名算法不正确")
        XCTAssertEqual(header["typ"] as? String, "JWT", "Token类型不正确")

        // 验证Payload字段
        XCTAssertEqual(payload["iss"] as? String, testApiKey, "iss字段不正确")
        XCTAssertEqual(payload["sub"] as? String, "qweather-api-request", "sub字段不正确")
        XCTAssertNotNil(payload["iat"], "缺少iat字段")
        XCTAssertNotNil(payload["exp"], "缺少exp字段")
        XCTAssertNotNil(payload["jti"], "缺少jti字段")

        // 验证过期时间
        guard let iat = payload["iat"] as? TimeInterval,
              let exp = payload["exp"] as? TimeInterval else {
            XCTFail("时间字段格式不正确")
            return
        }
        XCTAssertEqual(exp - iat, 300, "过期时间不正确")
    }

    func testJWTExpiration() throws {
        // 测试不同过期时间
        let testCases: [TimeInterval] = [60, 120, 300]
        for expiresIn in testCases {
            guard let token = JWTGenerator.generateQWeatherToken(
                apiKey: testApiKey,
                apiSecret: testApiSecret,
                expiresIn: expiresIn
            ) else {
                XCTFail("JWT生成失败，过期时间：\(expiresIn)")
                continue
            }

            let parts = token.components(separatedBy: ".")
            guard let payloadData = Data(base64URLEncoded: parts[1]),
                  let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
                  let iat = payload["iat"] as? TimeInterval,
                  let exp = payload["exp"] as? TimeInterval else {
                XCTFail("JWT解码失败，过期时间：\(expiresIn)")
                continue
            }

            XCTAssertEqual(exp - iat, expiresIn, "过期时间设置不正确，期望：\(expiresIn)，实际：\(exp - iat)")
        }
    }

    func testInvalidInput() throws {
        // 测试空Key/Secret仍能生成JWT（签名算法不校验输入内容），
        // 但生成的token在实际API调用时会被服务端拒绝
        let emptyKeyToken = JWTGenerator.generateQWeatherToken(apiKey: "", apiSecret: testApiSecret)
        let emptySecretToken = JWTGenerator.generateQWeatherToken(apiKey: testApiKey, apiSecret: "")
        let bothEmptyToken = JWTGenerator.generateQWeatherToken(apiKey: "", apiSecret: "")

        // JWT格式仍然有效（三段式）
        for token in [emptyKeyToken, emptySecretToken, bothEmptyToken] {
            XCTAssertNotNil(token)
            XCTAssertEqual(token?.components(separatedBy: ".").count, 3, "即使输入为空，JWT格式仍应正确")
        }
    }
}

extension Data {
    init?(base64URLEncoded string: String) {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddingLength = (4 - base64.count % 4) % 4
        base64.append(String(repeating: "=", count: paddingLength))

        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        self = data
    }
}
