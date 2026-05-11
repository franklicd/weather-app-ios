import SwiftUI

// MARK: - Settings Row Trailing Content

/// Describes what appears on the trailing side of a settings row.
private enum SettingsRowTrailing {
    case text(String)
    case activity(Bool)
}

// MARK: - Settings Group Card

/// A frosted-glass card container used to group related settings rows.
private struct SettingsGroupCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(DTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DTRadius.xl)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DTRadius.xl)
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.06)
                        : Color.white.opacity(0.5),
                    lineWidth: 0.5
                )
        )
    }
}

// MARK: - Settings Row

/// A single row inside a settings group: tinted icon circle + title + trailing content.
private struct SettingsRow: View {
    let iconName: String
    let tint: Color
    let title: String
    let trailing: SettingsRowTrailing

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: DTSpacing.md) {
            // Tinted icon circle (32x32)
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(tint)
            }

            // Title
            Text(title)
                .font(DTFont.body1.font)
                .foregroundStyle(colorScheme == .dark ? .white : .black)

            Spacer()

            // Trailing content
            switch trailing {
            case .text(let value):
                Text(value)
                    .font(DTFont.body3.font)
                    .foregroundStyle(
                        colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.35)
                    )
            case .activity(let isActive):
                if isActive {
                    ProgressView()
                        .scaleEffect(0.75)
                }
            }
        }
        .padding(.vertical, DTSpacing.sm)
    }
}

// MARK: - View Extension: Labeled

struct LabeledModifier: ViewModifier {
    let label: String
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: DTSpacing.xs) {
            Text(label.uppercased())
                .font(DTFont.caption1.font)
                .fontWeight(.semibold)
                .tracking(1)
                .foregroundStyle(colorScheme == .dark ? DTColor.Dark.gray500 : DTColor.Light.gray500)
                .padding(.leading, DTSpacing.md)
            content
        }
    }
}

extension View {
    /// Places an uppercase section label above this view.
    func labeled(_ label: String) -> some View {
        modifier(LabeledModifier(label: label))
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(WeatherStore.self) private var store
    @State private var isRefreshing = false
    @Environment(\.colorScheme) private var colorScheme

    /// App version string from the bundle.
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "v1.0.0"
    }

    /// Count of cities that have at least one active alert.
    private var alertCityCount: Int {
        store.cities.filter { !$0.alerts.isEmpty }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Solid background
                (colorScheme == .dark
                    ? DTColor.Background.dark
                    : DTColor.Background.light)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DTSpacing.xl) {
                        appIdentityHeader
                        dataSection
                        aboutSection
                        legendSection
                        footer
                    }
                    .padding(.horizontal, DTSpacing.lg)
                    .padding(.bottom, DTSpacing.xxxl)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("设置")
                        .font(DTFont.title1.font)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: - App Identity Header

    private var appIdentityHeader: some View {
        VStack(spacing: DTSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1A56DB"), Color(hex: "#0A0F1E")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.78, blue: 0.2),
                                Color(red: 1.0, green: 0.55, blue: 0.15),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Text("简天气")
                .font(DTFont.title1.font)
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DTSpacing.xxl)
    }

    // MARK: - Data Section

    private var dataSection: some View {
        SettingsGroupCard {
            VStack(spacing: 0) {
                // Refresh all cities
                Button {
                    Task {
                        isRefreshing = true
                        await store.fetchAllWeather()
                        isRefreshing = false
                    }
                } label: {
                    SettingsRow(
                        iconName: "arrow.clockwise",
                        tint: DTColor.Semantic.info,
                        title: "刷新所有城市数据",
                        trailing: .activity(isRefreshing)
                    )
                }
                .disabled(isRefreshing)

                SettingsRow(
                    iconName: "building.2",
                    tint: Color(hex: "#8B5CF6"),
                    title: "城市数量",
                    trailing: .text("\(store.cities.count)")
                )

                SettingsRow(
                    iconName: "exclamationmark.triangle",
                    tint: DTColor.Semantic.warning,
                    title: "有预警城市",
                    trailing: .text("\(alertCityCount)")
                )
            }
        }
        .labeled("数据")
    }

    // MARK: - About Section

    private var aboutSection: some View {
        SettingsGroupCard {
            VStack(spacing: 0) {
                SettingsRow(
                    iconName: "cloud.fill",
                    tint: Color(hex: "#60A5FA"),
                    title: "天气数据来源",
                    trailing: .text("Open-Meteo")
                )

                SettingsRow(
                    iconName: "info.circle",
                    tint: DTColor.Semantic.info,
                    title: "版本",
                    trailing: .text(appVersion)
                )

                SettingsRow(
                    iconName: "iphone",
                    tint: Color(hex: "#374151"),
                    title: "支持 iOS",
                    trailing: .text("iOS 16+")
                )
            }
        }
        .labeled("关于")
    }

    // MARK: - Legend Section

    private var legendSection: some View {
        SettingsGroupCard {
            VStack(alignment: .leading, spacing: DTSpacing.sm) {
                Text("天气预警说明")
                    .font(DTFont.body1.font)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)

                ForEach(AlertSeverity.allCases, id: \.rawValue) { severity in
                    HStack(spacing: DTSpacing.sm) {
                        Circle()
                            .fill(severity.color)
                            .frame(width: 8, height: 8)
                        Text(severity.label)
                            .font(DTFont.body3.font)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, DTSpacing.xs)
        }
        .labeled("图例")
    }

    // MARK: - Footer

    private var footer: some View {
        Text("简天气 — 实时天气，智能预警")
            .font(DTFont.caption2.font)
            .foregroundStyle(
                colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)
            )
            .frame(maxWidth: .infinity)
            .padding(.top, DTSpacing.xxxl)
    }
}
