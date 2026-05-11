// =============================================================================
// DailyForecast.swift
// SimpleWeatherApp - 7-Day Forecast Component
//
// RedesignedForecastSection displays a 7-day weather forecast with animated
// temperature range bars. All visual tokens come from DesignTokens.swift.
// Uses SectionHeader, WeatherCode helpers, and .glassCard() from the same target.
// =============================================================================

import SwiftUI

// MARK: - ForecastItem

/// A single day's forecast data, parsed from DailyForecast arrays.
struct ForecastItem {
    let date: String
    let code: Int
    let max: Double
    let min: Double
}

// MARK: - RedesignedForecastSection

/// A 7-day forecast card with animated temperature range bars.
///
/// Layout per row: date label | weather icon | min temp | range bar | max temp.
/// The range bar uses a global min/max across all 7 days so every bar is
/// proportionally correct relative to the full temperature spread.
struct RedesignedForecastSection: View {
    let daily: DailyForecast

    @State private var appear = false
    @State private var barsAppear = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.md) {
            SectionHeader(icon: "calendar", title: "7天预报")

            VStack(spacing: 0) {
                let items = forecastItems
                // Compute global min/max across all days for proportional bars.
                let globalMin = items.map(\.min).min() ?? 0
                let globalMax = items.map(\.max).max() ?? 0
                let globalRange = globalMax - globalMin

                ForEach(Array(items.enumerated()), id: \.element.date) { index, item in
                    forecastRow(
                        item: item,
                        index: index,
                        globalMin: globalMin,
                        globalRange: globalRange,
                        isLast: index == items.count - 1
                    )
                }
            }
        }
        .glassCard(cornerRadius: DTRadius.xxl)
        .onAppear {
            appear = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                barsAppear = true
            }
        }
    }

    // MARK: - Forecast Row

    /// Builds a single forecast row with date, icon, min/max temps, and range bar.
    private func forecastRow(
        item: ForecastItem,
        index: Int,
        globalMin: Double,
        globalRange: Double,
        isLast: Bool
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: DTSpacing.md) {
                // 1. Date label
                dateLabel(for: item)

                // 2. Weather icon
                weatherIcon(for: item)

                // 3. Min temperature
                minTempLabel(for: item)

                // 4. Temperature range bar
                temperatureBar(
                    item: item,
                    index: index,
                    globalMin: globalMin,
                    globalRange: globalRange
                )

                // 5. Max temperature
                maxTempLabel(for: item)
            }
            .padding(.vertical, DTSpacing.sm)

            // Divider between rows (not after the last row)
            if !isLast {
                Divider()
                    .background(
                        colorScheme == .dark
                            ? Color.white.opacity(0.06)
                            : Color.black.opacity(0.04)
                    )
            }
        }
    }

    // MARK: - Row Sub-Components

    /// Date label: "今天" is highlighted in brand colour, others show "M/d E".
    private func dateLabel(for item: ForecastItem) -> some View {
        let isToday = item.date == "今天"
        return Text(item.date)
            .font(DTFont.body2.font)
            .fontWeight(isToday ? .semibold : .medium)
            .foregroundStyle(
                isToday
                    ? DTColor.Brand.primaryLight
                    : (colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7))
            )
            .frame(width: 52, alignment: .leading)
    }

    /// SF Symbol weather icon with condition-specific colour.
    private func weatherIcon(for item: ForecastItem) -> some View {
        Image(systemName: WeatherCode.icon(for: item.code))
            .font(.system(size: 18))
            .foregroundStyle(WeatherCode.color(for: item.code))
            .frame(width: 24)
    }

    /// Minimum temperature label (right-aligned).
    private func minTempLabel(for item: ForecastItem) -> some View {
        Text("\(Int(item.min))°")
            .font(DTFont.label1.font)
            .fontWeight(.medium)
            .foregroundStyle(
                colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.35)
            )
            .frame(width: 32, alignment: .trailing)
    }

    /// Maximum temperature label (left-aligned).
    private func maxTempLabel(for item: ForecastItem) -> some View {
        Text("\(Int(item.max))°")
            .font(DTFont.label1.font)
            .fontWeight(.semibold)
            .foregroundStyle(
                colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.8)
            )
            .frame(width: 32, alignment: .leading)
    }

    /// Animated temperature range bar positioned proportionally within the global range.
    private func temperatureBar(
        item: ForecastItem,
        index: Int,
        globalMin: Double,
        globalRange: Double
    ) -> some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            // Normalise positions against the global temperature range.
            // Guard against zero range (all days have identical temps).
            let leadingFraction = globalRange > 0
                ? CGFloat((item.min - globalMin) / globalRange)
                : 0
            let trailingFraction = globalRange > 0
                ? CGFloat((item.max - globalMin) / globalRange)
                : 1
            let barLeading = totalWidth * leadingFraction
            let barWidth = max(totalWidth * (trailingFraction - leadingFraction), 8)

            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: DTRadius.full)
                    .fill(
                        colorScheme == .dark
                            ? Color.white.opacity(0.06)
                            : Color.black.opacity(0.04)
                    )
                    .frame(height: 5)

                // Coloured fill
                RoundedRectangle(cornerRadius: DTRadius.full)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.376, green: 0.647, blue: 0.980),  // #60A5FA
                                Color(red: 0.961, green: 0.620, blue: 0.043)   // #F59E0B
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: barsAppear ? barWidth : 0,
                        height: 5
                    )
                    .offset(x: barsAppear ? barLeading : barLeading)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.7)
                            .delay(0.15 + Double(index) * 0.04),
                        value: barsAppear
                    )
            }
            .frame(height: 5)
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 20)
    }

    // MARK: - Data Parsing

    /// Parses the DailyForecast arrays into a list of ForecastItem.
    ///
    /// - Today's date is displayed as "今天"; subsequent dates use "M/d E"
    ///   format with zh_CN locale (e.g. "5/11 周日").
    /// - Uses the `safe:` subscript for optional access to protect against
    ///   mismatched array lengths.
    var forecastItems: [ForecastItem] {
        let maxCount = min(
            daily.time.count,
            daily.weather_code.count,
            daily.temperature_2m_max.count,
            daily.temperature_2m_min.count
        )

        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"

        let display = DateFormatter()
        display.dateFormat = "M/d E"
        display.locale = Locale(identifier: "zh_CN")

        var items: [ForecastItem] = []
        for i in 0..<maxCount {
            let label: String
            if let date = parser.date(from: daily.time[i]) {
                label = i == 0 ? "今天" : display.string(from: date)
            } else {
                label = daily.time[i]
            }

            guard let maxTemp = daily.temperature_2m_max[safe: i],
                  let minTemp = daily.temperature_2m_min[safe: i],
                  let code = daily.weather_code[safe: i] else {
                continue
            }

            items.append(ForecastItem(
                date: label,
                code: code,
                max: maxTemp,
                min: minTemp
            ))
        }
        return items
    }
}
