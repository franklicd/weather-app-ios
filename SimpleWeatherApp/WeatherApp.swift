import SwiftUI

@main
struct SimpleWeatherApp: App {
    @State private var store = WeatherStore.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
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
                BackgroundTaskManager.shared.applicationDidEnterBackground()
            }
        }
    }
}

// MARK: - Tab Enum

enum AppTab: Int, CaseIterable {
    case cities = 0
    case detail = 1
    case settings = 2

    var icon: String {
        switch self {
        case .cities: return "list.bullet"
        case .detail: return "cloud.sun.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var label: String {
        switch self {
        case .cities: return "城市"
        case .detail: return "详情"
        case .settings: return "设置"
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @Environment(WeatherStore.self) private var store
    @State private var selectedTab: AppTab = .cities

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content views stacked, only selected is visible
            ZStack {
                CityListView()
                    .opacity(selectedTab == .cities ? 1 : 0)

                CityDetailView()
                    .opacity(selectedTab == .detail ? 1 : 0)

                SettingsView()
                    .opacity(selectedTab == .settings ? 1 : 0)
            }

            // Custom floating tab bar
            TabBarView(selectedTab: $selectedTab, alertBadge: alertBadge)
        }
    }

    private var alertBadge: Int {
        store.selectedCity?.alerts.filter { $0.severity == .high || $0.severity == .extreme }.count ?? 0
    }
}

// MARK: - Tab Bar View

struct TabBarView: View {
    @Binding var selectedTab: AppTab
    let alertBadge: Int
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: DTSpacing.xxxl) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    badge: tab == .detail ? alertBadge : 0
                ) {
                    withAnimation(DTAnimation.snappySpring) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, DTSpacing.xxl)
        .padding(.vertical, DTSpacing.sm)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(
                            colorScheme == .dark
                                ? Color.white.opacity(0.08)
                                : Color.white.opacity(0.35),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: colorScheme == .dark
                        ? Color.black.opacity(0.4)
                        : Color.black.opacity(0.1),
                    radius: 20, x: 0, y: 8
                )
        )
        .padding(.bottom, 4)
    }
}

// MARK: - Tab Bar Item

struct TabBarItem: View {
    let tab: AppTab
    let isSelected: Bool
    let badge: Int
    let action: () -> Void

    @State private var bounced = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: {
            action()
            bounced = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                bounced = false
            }
        }) {
            VStack(spacing: DTSpacing.xxxs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected
                                ? DTColor.Brand.primaryLight
                                : (colorScheme == .dark ? Color.white : Color.black).opacity(0.35)
                        )
                        .scaleEffect(bounced ? 1.2 : 1.0)
                        .animation(DTAnimation.snappySpring, value: bounced)

                    if badge > 0 {
                        Circle()
                            .fill(DTColor.Semantic.error)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }

                Text(tab.label)
                    .font(DTFont.caption2.font)
                    .foregroundStyle(
                        isSelected
                            ? DTColor.Brand.primaryLight
                            : (colorScheme == .dark ? Color.white : Color.black).opacity(0.35)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
