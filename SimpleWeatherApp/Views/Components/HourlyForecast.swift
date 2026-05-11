// =============================================================================
// HourlyForecast.swift
// SimpleWeatherApp - Redesigned Hourly Forecast Component
//
// A horizontally-scrollable hourly forecast strip built on the
// "Ink & Atmosphere" design system. Uses design tokens from
// DesignTokens.swift and glass-card styling from ContainerStyles.swift.
//
// Components:
//   - RedesignedHourlyForecast: Container with SectionHeader + ScrollView
//   - RedesignedHourlyItem:     Individual hour cell with mini temp bar
// =============================================================================

import SwiftUI

// MARK: - RedesignedHourlyForecast

/// A horizontally-scrollable hourly forecast section wrapped in a glass card.
///
/// Displays each hour as a `RedesignedHourlyItem` with a staggered entrance
/// animation. The "now" item is visually distinct with a blue gradient
/// background. All sizing and spacing uses design-system tokens.
struct RedesignedHourlyForecast: View {
    let items: [HourlyItem]

    /// Tracks whether the entrance animation has been triggered.
    @State private var appear = false
    @Environment(\.colorScheme) private var colorScheme

    // MARK: HourlyItem

    /// A single hour's display data.
    struct HourlyItem: Identifiable {
        let id = UUID()
        let time: String
        let temperature: Double
        let weatherCode: Int
        let isNow: Bool
    }

    // MARK: Computed helpers

    /// The minimum and maximum temperatures across all items.
    /// Used to normalise each item's mini-bar width.
    private var tempRange: (min: Double, max: Double) {
        let temps = items.map(\.temperature)
        guard let minTemp = temps.min(), let maxTemp = temps.max() else {
            return (min: 0, max: 0)
        }
        return (min: minTemp, max: maxTemp)
    }

    /// Returns a 0-1 progress value for a given temperature.
    /// Returns 0.5 when all items share the same temperature (range is zero).
    private func tempProgress(for temp: Double) -> Double {
        let range = tempRange.max - tempRange.min
        guard range > 0 else { return 0.5 }
        return (temp - tempRange.min) / range
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.md) {
            SectionHeader(icon: "clock.fill", title: "逐时预报")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DTSpacing.sm) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        RedesignedHourlyItem(
                            item: item,
                            tempProgress: tempProgress(for: item.temperature)
                        )
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 12)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.85)
                                .delay(Double(index) * 0.025),
                            value: appear
                        )
                    }
                }
                .padding(.horizontal, DTSpacing.xxs)
            }
        }
        .glassCard(cornerRadius: DTRadius.xxl)
        .onAppear { appear = true }
    }
}

// MARK: - RedesignedHourlyItem

/// A single hour cell inside the `RedesignedHourlyForecast` strip.
///
/// Layout (vertical, top to bottom):
/// 1. Time label -- semibold white when "now", medium otherwise.
/// 2. Weather icon -- SF Symbol resolved via `WeatherCode.icon(for:)`.
/// 3. Temperature + mini progress bar.
///
/// Background adapts: "now" gets a blue gradient with shadow; other hours
/// get a subtle neutral gradient.
struct RedesignedHourlyItem: View {
    let item: RedesignedHourlyForecast.HourlyItem

    /// A 0-1 value controlling the mini-bar width. Normalised against the
    /// full temperature range of the parent forecast.
    let tempProgress: Double

    @Environment(\.colorScheme) private var colorScheme

    // MARK: Body

    var body: some View {
        VStack(spacing: DTSpacing.sm) {
            // 1. Time label
            timeLabel

            // 2. Weather icon
            weatherIcon

            // 3. Temperature + mini bar
            temperatureSection
        }
        .padding(.vertical, DTSpacing.md)
        .padding(.horizontal, DTSpacing.sm)
        .frame(minWidth: 64)
        .background(itemBackground)
    }

    // MARK: Subviews

    /// Time label. "Now" is highlighted; other hours are muted.
    private var timeLabel: some View {
        Text(item.isNow ? "现在" : item.time)
            .font(item.isNow ? DTFont.label1.font : DTFont.label2.font)
            .fontWeight(item.isNow ? .semibold : .medium)
            .foregroundStyle(
                item.isNow
                    ? .white
                    : (colorScheme == .dark
                        ? .white.opacity(0.7)
                        : .black.opacity(0.5))
            )
    }

    /// SF Symbol weather icon. "Now" is white; others use `WeatherCode.color`.
    private var weatherIcon: some View {
        Image(systemName: WeatherCode.icon(for: item.weatherCode))
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(
                item.isNow ? .white : WeatherCode.color(for: item.weatherCode)
            )
            .symbolEffect(.bounce, options: .speed(0.5), value: item.isNow)
    }

    /// Temperature text with an optional mini progress bar beneath it.
    /// The bar is hidden for the "now" item.
    private var temperatureSection: some View {
        VStack(spacing: DTSpacing.xxs) {
            Text("\(Int(item.temperature))°")
                .font(item.isNow ? DTFont.data3.font : DTFont.body1.font)
                .fontWeight(.semibold)
                .foregroundStyle(
                        item.isNow
                            ? .white
                            : (colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.8))
                    )

            if !item.isNow {
                miniBar
            }
        }
    }

    /// A tiny progress bar whose width reflects the item's relative
    /// temperature position within the full forecast range.
    private var miniBar: some View {
        RoundedRectangle(cornerRadius: DTRadius.full)
            .fill(
                LinearGradient(
                    colors: [
                        DTColor.Semantic.info.opacity(0.6),
                        DTColor.Brand.secondaryLight.opacity(0.6)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(
                width: max(CGFloat(tempProgress) * 32, 4),
                height: 3
            )
    }

    /// Card background. "Now" gets a blue gradient with a coloured shadow;
    /// other hours get a subtle neutral gradient.
    @ViewBuilder
    private var itemBackground: some View {
        RoundedRectangle(cornerRadius: DTRadius.lg)
            .fill(
                item.isNow
                    ? LinearGradient(
                        colors: [
                            Color(hex: "#1A56DB"),
                            Color(hex: "#3B82F6")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: colorScheme == .dark
                            ? [Color.white.opacity(0.06), Color.white.opacity(0.02)]
                            : [Color.black.opacity(0.03), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
            )
    }
}
