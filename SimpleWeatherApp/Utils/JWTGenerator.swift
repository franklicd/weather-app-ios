//
//  JWTGenerator.swift
//  SimpleWeatherApp
//
//  Created by Claude on 2026/4/6.
//

import Foundation
import CommonCrypto

enum JWTGenerator {
    /// 生成和风天气API需要的JWT Token
    /// - Parameters:
    ///   - apiKey: 和风天气API Key
    ///   - apiSecret: 和风天气API Secret
    ///   - expiresIn: 过期时间（秒），最长3600秒，推荐300秒
    /// - Returns: JWT Token字符串
    static func generateQWeatherToken(apiKey: String, apiSecret: String, expiresIn: TimeInterval = 300) -> String? {
        // 1. 构建Header
        let header: [String: Any] = [
            "alg": "HS256",
            "typ": "JWT"
        ]

        // 2. 构建Payload
        let now = Date()
        let payload: [String: Any] = [
            "iss": apiKey,                // 签发者：固定为PublicKey(API Key)
            "sub": "qweather-api-request",// 主题：官方2025年更新为固定值"qweather-api-request"
            "iat": Int(now.timeIntervalSince1970),  // 签发时间
            "exp": Int(now.addingTimeInterval(expiresIn).timeIntervalSince1970), // 过期时间，最长300秒
            "jti": UUID().uuidString      // 唯一ID，防重放攻击
        ]

        // 3. 序列化Header和Payload为Base64URL
        guard let headerData = try? JSONSerialization.data(withJSONObject: header),
              let payloadData = try? JSONSerialization.data(withJSONObject: payload) else {
            return nil
        }

        let headerBase64 = headerData.base64URLEncodedString()
        let payloadBase64 = payloadData.base64URLEncodedString()

        // 4. 构建签名内容
        let signatureContent = "\(headerBase64).\(payloadBase64)"

        // 5. 使用HS256签名
        guard let signature = hmacSHA256(message: signatureContent, key: apiSecret) else {
            return nil
        }

        // 6. 组合完整JWT
        return "\(headerBase64).\(payloadBase64).\(signature)"
    }

    /// HMAC-SHA256签名
    private static func hmacSHA256(message: String, key: String) -> String? {
        let messageData = Data(message.utf8)
        let keyData = Data(key.utf8)

        var result = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        result.withUnsafeMutableBytes { resultBytes in
            keyData.withUnsafeBytes { keyBytes in
                messageData.withUnsafeBytes { messageBytes in
                    CCHmac(
                        CCHmacAlgorithm(kCCHmacAlgSHA256),
                        keyBytes.baseAddress, keyData.count,
                        messageBytes.baseAddress, messageData.count,
                        resultBytes.baseAddress
                    )
                }
            }
        }

        return result.base64URLEncodedString()
    }
}

extension Data {
    /// Base64URL编码（替换+为-，/为_，移除末尾=）
    func base64URLEncodedString() -> String {
        let base64 = self.base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: CharacterSet(charactersIn: "="))
    }
}
