import SwiftUI

@main
struct SimpleWeatherApp: App {
    @State private var store = WeatherStore.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // 注册后台任务
        BackgroundTaskManager.shared.registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(store)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                store.startLocationOnLaunchIfNeeded()
                Task { await store.fetchAllWeather() }
            } else if newPhase == .background {
                // App 进入后台时调度后台任务
                BackgroundTaskManager.shared.applicationDidEnterBackground()
            }
        }
    }
}

struct ContentView: View {
    @Environment(WeatherStore.self) private var store

    var body: some View {
        TabView {
            CityListView()
                .tabItem {
                    Label("城市", systemImage: "list.bullet")
                }

            CityDetailView()
                .tabItem {
                    Label("详情", systemImage: "cloud.sun.fill")
                }
                .badge(alertBadge)

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
    }

    private var alertBadge: Int {
        store.selectedCity?.alerts.filter { $0.severity == .high || $0.severity == .extreme }.count ?? 0
    }
}
