import SwiftUI

@main
struct SimpleWeatherApp: App {
    @State private var store = WeatherStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(store)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.startLocationOnLaunchIfNeeded()
                Task { await store.fetchAllWeather() }
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
        store.cities.reduce(0) { $0 + $1.alerts.filter { $0.severity == .high || $0.severity == .extreme }.count }
    }
}
