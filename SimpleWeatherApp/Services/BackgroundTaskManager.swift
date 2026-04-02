import Foundation
import BackgroundTasks

@MainActor
class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()

    // 后台任务标识符
    static let refreshTaskIdentifier = "com.lyc.weatherapp.ios.refresh"
    static let weatherCheckTaskIdentifier = "com.lyc.weatherapp.ios.weathercheck"

    private let notificationManager = NotificationManager.shared

    private init() {}

    // 注册后台任务
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.refreshTaskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                await self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.weatherCheckTaskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                await self.handleWeatherCheck(task: task as! BGProcessingTask)
            }
        }
    }

    // 调度后台刷新任务
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15分钟后

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ 后台刷新任务已调度")
        } catch {
            print("❌ 后台刷新任务调度失败: \(error)")
        }
    }

    // 调度天气检查任务（更长间隔）
    func scheduleWeatherCheck() {
        let request = BGProcessingTaskRequest(identifier: Self.weatherCheckTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60) // 30分钟后

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ 天气检查任务已调度")
        } catch {
            print("❌ 天气检查任务调度失败: \(error)")
        }
    }

    // 处理应用刷新任务
    private func handleAppRefresh(task: BGAppRefreshTask) async {
        print("🔄 开始后台应用刷新...")

        // 调度下一次刷新
        scheduleAppRefresh()

        // 加载 WeatherStore 并刷新选中城市的天气
        let store = WeatherStore.shared
        if let selectedCity = store.selectedCity,
           let index = store.cities.firstIndex(where: { $0.id == selectedCity.id }) {
            // 后台刷新时也要发送通知（因为是用户主动查看的城市）
            await store.fetchWeather(at: index, sendNotification: true)
        }

        task.setTaskCompleted(success: true)
    }

    // 处理天气检查任务（后台处理）
    private func handleWeatherCheck(task: BGProcessingTask) async {
        print("🌤️ 开始后台天气检查...")

        // 调度下一次检查
        scheduleWeatherCheck()

        let store = WeatherStore.shared

        // 刷新所有城市的天气数据
        await store.fetchAllWeatherBackground()

        // 检查是否有新的告警并发送通知
        await checkAndSendAlerts(for: store)

        task.setTaskCompleted(success: true)
    }

    // 检查并发送告警通知
    private func checkAndSendAlerts(for store: WeatherStore) async {
        // 只对用户选中的城市发送通知
        guard let selectedCity = store.selectedCity else { return }

        let alerts = selectedCity.alerts
        for alert in alerts {
            notificationManager.sendWeatherAlertIfNeeded(
                cityId: selectedCity.id,
                cityName: selectedCity.name,
                alert: alert
            )
        }
    }

    // App 进入后台时调用
    func applicationDidEnterBackground() {
        scheduleAppRefresh()
        scheduleWeatherCheck()
    }
}