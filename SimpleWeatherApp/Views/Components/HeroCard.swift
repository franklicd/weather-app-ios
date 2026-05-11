// =============================================================================
// HeroCard.swift
// 简天气 - RedesignedHeroCard Component
//
// Primary weather display card with animated icon, temperature, description,
// and feels-like info. Uses a multi-layered background with weather-conditioned
// gradients over ultra-thin material, plus a subtle inner highlight stroke.
//
// Dependencies (same target, no import needed):
//   - DesignTokens.swift: DTColor, DTFont, DTSpacing, DTRadius, DTAnimation
//   - ContainerStyles.swift: .glassCard() ViewModifier
//   - SectionComponents.swift: AlertCountBadge
//   - WeatherHelpers.swift: WeatherCode (icon, description, color helpers)
//   - ImprovedWeatherAnimations.swift: DynamicWeatherIcon
//   - WeatherModels.swift: CurrentWeather
// =============================================================================

import SwiftUI

// MARK: - RedesignedHeroCard

/// The hero card displayed at the top of city detail view.
/// Shows animated weather icon, temperature (with numeric transition),
/// weather description, and feels-like temperature on a weather-conditioned
/// gradient background.
struct RedesignedHeroCard: View {
    let weather: CurrentWeather
    let alertCount: Int

    @State private var breathe = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: DTSpacing.sm) {
            // -- 1. Top row: animated icon + optional alert badge --
            HStack(alignment: .top) {
                Spacer()

                DynamicWeatherIcon(weatherCode: weather.weather_code)
                    .scaleEffect(breathe ? 1.05 : 1.0)
                    .animation(
                        .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                        value: breathe
                    )

                Spacer()
            }
            .overlay(alignment: .topTrailing) {
                if alertCount > 0 {
                    AlertCountBadge(count: alertCount)
                        .offset(x: DTSpacing.xxs, y: -DTSpacing.xxs)
                }
            }
            .padding(.top, DTSpacing.lg)

            // -- 2. Temperature --
            Text("\(Int(weather.temperature_2m))\u{00B0}")
                .font(DTFont.display1.font)
                .contentTransition(.numericText())
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.95)
                        : Color.black.opacity(0.85)
                )

            // -- 3. Weather description --
            Text(WeatherCode.description(for: weather.weather_code))
                .font(DTFont.title3.font)
                .fontWeight(.semibold)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.75)
                        : Color.black.opacity(0.6)
                )

            // -- 4. Feels-like --
            Text("\u{4F53}\u{611F} \(Int(weather.apparent_temperature))\u{00B0}")
                .font(DTFont.body3.font)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.5)
                        : Color.black.opacity(0.4)
                )
                .padding(.bottom, DTSpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DTSpacing.xxl)
        .padding(.horizontal, DTSpacing.xl)
        .background(cardBackground)
        .onAppear {
            breathe = true
        }
    }

    // MARK: - Background

    /// Multi-layered card background:
    /// 1. Ultra-thin material base
    /// 2. Weather-conditioned gradient overlay
    /// 3. Subtle inner highlight stroke
    @ViewBuilder
    private var cardBackground: some View {
        ZStack {
            // Layer 1: material base
            RoundedRectangle(cornerRadius: DTRadius.xxxl)
                .fill(.ultraThinMaterial)

            // Layer 2: weather-conditioned gradient
            RoundedRectangle(cornerRadius: DTRadius.xxxl)
                .fill(heroGradient)

            // Layer 3: inner highlight stroke
            RoundedRectangle(cornerRadius: DTRadius.xxxl)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.1 : 0.4),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .center
                    ),
                    lineWidth: 0.5
                )
        }
        .shadow(
            color: colorScheme == .dark
                ? Color.black.opacity(0.3)
                : Color.black.opacity(0.08),
            radius: 24,
            x: 0,
            y: 8
        )
    }

    // MARK: - Hero Gradient

    /// Returns a linear gradient conditioned on the current weather code
    /// and color scheme. Covers 8 weather categories.
    private var heroGradient: LinearGradient {
        let code = weather.weather_code
        let isDark = colorScheme == .dark

        switch code {
        // Clear
        case 0, 1:
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "#1E3A5F").opacity(0.6), Color(hex: "#2D1B69").opacity(0.4)]
                    : [Color(hex: "#FEF3C7").opacity(0.7), Color(hex: "#FDE68A").opacity(0.5), Color(hex: "#FBBF24").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        // Partly Cloudy
        case 2:
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "#1E3A5F").opacity(0.5), Color(hex: "#374151").opacity(0.4)]
                    : [Color(hex: "#DBEAFE").opacity(0.6), Color(hex: "#E0F2FE").opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )

        // Drizzle
        case 51...57:
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "#0F172A").opacity(0.6), Color(hex: "#1E293B").opacity(0.4)]
                    : [Color(hex: "#E0F2FE").opacity(0.5), Color(hex: "#BAE6FD").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        // Rain
        case 61...65, 80...82:
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "#0F172A").opacity(0.6), Color(hex: "#1E293B").opacity(0.4)]
                    : [Color(hex: "#CBD5E1").opacity(0.5), Color(hex: "#94A3B8").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        // Snow
        case 71...77, 85, 86:
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "#1E293B").opacity(0.5), Color(hex: "#334155").opacity(0.3)]
                    : [Color(hex: "#F0F9FF").opacity(0.7), Color(hex: "#E0F2FE").opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )

        // Thunderstorm
        case 95...99:
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "#1E1B4B").opacity(0.6), Color(hex: "#312E81").opacity(0.4)]
                    : [Color(hex: "#DDD6FE").opacity(0.5), Color(hex: "#C4B5FD").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        // Fog
        case 45, 48:
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "#1E293B").opacity(0.4), Color(hex: "#0F172A").opacity(0.3)]
                    : [Color(hex: "#F1F5F9").opacity(0.5), Color(hex: "#E2E8F0").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        // Default (overcast / unknown)
        default:
            return LinearGradient(
                colors: isDark
                    ? [Color.white.opacity(0.06), Color.white.opacity(0.02)]
                    : [Color.white.opacity(0.5), Color.white.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Preview

#Preview("Hero Card - Clear") {
    RedesignedHeroCard(
        weather: CurrentWeather(
            temperature_2m: 28,
            relative_humidity_2m: 55,
            apparent_temperature: 30,
            weather_code: 0,
            wind_speed_10m: 12,
            visibility: 10000
        ),
        alertCount: 2
    )
    .padding()
}

#Preview("Hero Card - Rain") {
    RedesignedHeroCard(
        weather: CurrentWeather(
            temperature_2m: 15,
            relative_humidity_2m: 80,
            apparent_temperature: 12,
            weather_code: 63,
            wind_speed_10m: 25,
            visibility: 5000
        ),
        alertCount: 0
    )
    .padding()
}
