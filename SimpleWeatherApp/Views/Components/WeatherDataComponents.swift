// =============================================================================
// WeatherDataComponents.swift
// SimpleWeatherApp - Detail Grid, AQI/UV Gauges, and Pollutant Bars
//
// Components built on the "Ink & Atmosphere" design system:
//   - RedesignedDetailGrid:  2-column grid of weather detail cells
//   - DetailDataCell:        Individual metric cell (humidity, wind, etc.)
//   - RedesignedAQIUVCard:   Air quality and UV index card with gauges
//   - RedesignedGaugeView:   Circular progress gauge for AQI/UV
//   - PollutantBar:          Horizontal progress bar for PM2.5/PM10
//
// Design tokens are in DesignTokens.swift (same target, no import needed).
// ContainerStyles.swift provides .glassCard().
// SectionComponents.swift provides SectionHeader.
// WeatherHelpers.swift provides AirQualityHelper, WeatherCode, Theme.
// WeatherModels.swift provides CurrentWeather, AirQualityData.
// =============================================================================

import SwiftUI

// MARK: - RedesignedDetailGrid

/// A two-column grid of weather detail cells wrapped in a glass card.
/// Displays humidity, wind speed, visibility, and feels-like temperature.
/// Cells appear with a staggered spring entrance animation.
struct RedesignedDetailGrid: View {
    let weather: CurrentWeather

    @State private var appear = false
    @Environment(\.colorScheme) private var colorScheme

    /// Ordered list of (icon, label, value, tint) tuples for the grid cells.
    private var cells: [(icon: String, label: String, value: String, tint: Color)] {
        var items: [(icon: String, label: String, value: String, tint: Color)] = [
            (
                icon: "humidity.fill",
                label: "湿度",
                value: "\(weather.relative_humidity_2m)%",
                tint: DTColor.Semantic.info
            ),
            (
                icon: "wind",
                label: "风速",
                value: "\(Int(weather.wind_speed_10m)) km/h",
                tint: DTColor.Brand.primaryLight
            ),
        ]

        // Visibility cell: only shown when data is available
        if let vis = weather.visibility {
            items.append((
                icon: "eye.fill",
                label: "能见度",
                value: "\(Int(vis / 1000)) km",
                tint: DTColor.Weather.thunder
            ))
        }

        items.append((
            icon: "thermometer.medium",
            label: "体感温度",
            value: "\(Int(weather.apparent_temperature))\u{00B0}C",
            tint: DTColor.Semantic.warning
        ))

        return items
    }

    var body: some View {
        VStack(spacing: DTSpacing.md) {
            SectionHeader(icon: "square.grid.2x2.fill", title: "详细数据")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DTSpacing.md),
                    GridItem(.flexible(), spacing: DTSpacing.md),
                ],
                spacing: DTSpacing.md
            ) {
                ForEach(Array(cells.enumerated()), id: \.offset) { index, cell in
                    DetailDataCell(
                        icon: cell.icon,
                        label: cell.label,
                        value: cell.value,
                        tint: cell.tint
                    )
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 12)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.78)
                            .delay(DTAnimation.gridStaggerDelay(index: index)),
                        value: appear
                    )
                }
            }
        }
        .padding(DTSpacing.md)
        .glassCard(cornerRadius: DTRadius.xxl)
        .onAppear {
            appear = true
        }
    }
}

// MARK: - DetailDataCell

/// A single metric cell displaying an icon, label, and value with a tinted background.
struct DetailDataCell: View {
    let icon: String
    let label: String
    let value: String
    let tint: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.sm) {
            // Icon + label row
            HStack(spacing: DTSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.15))
                        .frame(width: 30, height: 30)

                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(tint)
                }

                Text(label)
                    .font(DTFont.label2.font)
                    .foregroundStyle(DTColor.Foreground.tertiary(colorScheme))
            }

            // Value text
            Text(value)
                .font(DTFont.data3.font)
                .foregroundStyle(DTColor.Foreground.primary(colorScheme))
        }
        .padding(DTSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DTRadius.lg)
                .fill(tint.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DTRadius.lg)
                .strokeBorder(tint.opacity(0.1), lineWidth: 0.5)
        )
    }
}

// MARK: - RedesignedAQIUVCard

/// A card displaying air quality index and UV index gauges side by side,
/// with PM2.5 and PM10 pollutant bars below.
struct RedesignedAQIUVCard: View {
    let aq: AirQualityData

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: DTSpacing.md) {
            SectionHeader(icon: "leaf.fill", title: "空气 & 紫外线")

            // AQI + UV gauges side by side
            HStack(spacing: DTSpacing.lg) {
                if let aqiValue = aq.us_aqi {
                    RedesignedGaugeView(
                        value: aqiValue,
                        maxValue: 500,
                        label: "AQI",
                        levelText: AirQualityHelper.aqiLevel(for: aqiValue),
                        tint: AirQualityHelper.aqiColor(for: aqiValue)
                    )
                }

                if let uvValue = aq.uv_index {
                    RedesignedGaugeView(
                        value: Int(uvValue),
                        maxValue: 12,
                        label: "UV",
                        levelText: AirQualityHelper.uvLevel(for: uvValue),
                        tint: AirQualityHelper.uvColor(for: uvValue)
                    )
                }
            }

            // Pollutant bars
            VStack(spacing: DTSpacing.xs) {
                if let pm25 = aq.pm2_5 {
                    PollutantBar(
                        label: "PM2.5",
                        value: pm25,
                        maxValue: 150,
                        unit: "\u{00B5}g/m\u{00B3}"
                    )
                }

                if let pm10Value = aq.pm10 {
                    PollutantBar(
                        label: "PM10",
                        value: pm10Value,
                        maxValue: 200,
                        unit: "\u{00B5}g/m\u{00B3}"
                    )
                }
            }
        }
        .padding(DTSpacing.md)
        .glassCard(cornerRadius: DTRadius.xxl)
    }
}

// MARK: - RedesignedGaugeView

/// A circular gauge that shows a value relative to a maximum, with a level badge.
struct RedesignedGaugeView: View {
    let value: Int
    let maxValue: Int
    let label: String
    let levelText: String
    let tint: Color

    @Environment(\.colorScheme) private var colorScheme

    /// Progress clamped to 0...1.
    private var progress: CGFloat {
        CGFloat(max(0, min(value, maxValue))) / CGFloat(maxValue)
    }

    var body: some View {
        VStack(spacing: DTSpacing.sm) {
            ZStack {
                // Track circle
                Circle()
                    .stroke(
                        colorScheme == .dark
                            ? Color.white.opacity(0.08)
                            : Color.black.opacity(0.06),
                        lineWidth: 6
                    )
                    .frame(width: 72, height: 72)

                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        tint,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))

                // Center value + label
                VStack(spacing: 2) {
                    Text("\(value)")
                        .font(DTFont.data2.font)
                        .foregroundStyle(DTColor.Foreground.primary(colorScheme))

                    Text(label)
                        .font(DTFont.caption2.font)
                        .foregroundStyle(DTColor.Foreground.tertiary(colorScheme))
                }
            }

            // Level badge
            Text(levelText)
                .font(DTFont.caption1.font)
                .fontWeight(.medium)
                .foregroundStyle(tint)
                .padding(.horizontal, DTSpacing.sm)
                .padding(.vertical, DTSpacing.xxxs)
                .background(
                    Capsule()
                        .fill(tint.opacity(0.12))
                )
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - PollutantBar

/// A horizontal progress bar displaying a pollutant concentration value.
/// Fill color shifts from green to yellow to red based on progress level.
struct PollutantBar: View {
    let label: String
    let value: Double
    let maxValue: Double
    let unit: String

    @Environment(\.colorScheme) private var colorScheme

    /// Progress clamped to 0...1.
    private var progress: CGFloat {
        CGFloat(Swift.max(0, min(value / maxValue, 1.0)))
    }

    /// Fill color determined by progress threshold.
    private var fillColor: Color {
        if progress < 0.5 {
            return .green
        } else if progress < 0.75 {
            return .yellow
        } else {
            return .red
        }
    }

    var body: some View {
        VStack(spacing: DTSpacing.xxs) {
            // Label + value row
            HStack {
                Text(label)
                    .font(DTFont.body3.font)
                    .foregroundStyle(DTColor.Foreground.secondary(colorScheme))

                Spacer()

                Text(String(format: "%.1f ", value) + unit)
                    .font(DTFont.label2.font)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        colorScheme == .dark
                            ? Color.white.opacity(0.7)
                            : Color.black.opacity(0.6)
                    )
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            colorScheme == .dark
                                ? Color.white.opacity(0.06)
                                : Color.black.opacity(0.04)
                        )
                        .frame(height: 4)

                    // Fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(fillColor)
                        .frame(
                            width: progress * geometry.size.width,
                            height: 4
                        )
                }
            }
            .frame(height: 4)
        }
    }
}
