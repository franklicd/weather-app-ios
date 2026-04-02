
import Foundation
import UserNotifications
import SwiftUI
import UIKit

@MainActor
@Observable
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private let userDefaults = UserDefaults.standard
    private let sentAlertsKey = "sentWeatherAlerts"
    
    // 存储已发送的警报: [城市ID: [警报ID]]
    private var sentAlerts: [UUID: Set<UUID>] {
        get {
            guard let data = userDefaults.data(forKey: sentAlertsKey),
                  let decoded = try? JSONDecoder().decode([UUID: [UUID]].self, from: data) else {
                return [:]
            }
            return decoded.mapValues { Set($0) }
        }
        set {
            let encodable = newValue.mapValues { Array($0) }
            if let data = try? JSONEncoder().encode(encodable) {
                userDefaults.set(data, forKey: sentAlertsKey)
            }
        }
    }
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // 请求通知权限
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 通知权限已获取")
            } else if let error = error {
                print("❌ 通知权限获取失败: \(error)")
            }
        }
    }
    
    // 检查是否已发送过该警报
    private func hasSentAlert(cityId: UUID, alertId: UUID) -> Bool {
        return sentAlerts[cityId]?.contains(alertId) ?? false
    }
    
    // 标记警报为已发送
    private func markAlertAsSent(cityId: UUID, alertId: UUID) {
        var current = sentAlerts
        if current[cityId] == nil {
            current[cityId] = []
        }
        current[cityId]?.insert(alertId)
        sentAlerts = current
    }
    
    // 发送天气警报通知
    func sendWeatherAlertIfNeeded(cityId: UUID, cityName: String, alert: WeatherAlert) {
        guard !hasSentAlert(cityId: cityId, alertId: alert.id) else {
            return // 已发送过，跳过
        }

        let currentBadge = UIApplication.shared.applicationIconBadgeNumber

        Task { @MainActor in
            let content = UNMutableNotificationContent()
            content.title = "\(cityName): \(alert.title)"
            content.body = alert.description
            content.sound = .default
            content.badge = NSNumber(value: currentBadge + 1)

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: alert.id.uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { [weak self] error in
                Task { @MainActor in
                    if let error = error {
                        print("❌ 发送通知失败: \(error)")
                    } else {
                        print("✅ 通知已发送: \(alert.title)")
                        self?.markAlertAsSent(cityId: cityId, alertId: alert.id)
                    }
                }
            }
        }
    }
    
    // 清除所有已发送警报记录（用于测试）
    func clearSentAlerts() {
        sentAlerts.removeAll()
        userDefaults.removeObject(forKey: sentAlertsKey)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
