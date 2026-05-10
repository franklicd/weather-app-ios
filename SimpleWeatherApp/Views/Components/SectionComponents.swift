// =============================================================================
// SectionComponents.swift
// 简天气 - Section Header & Alert Banner Components
//
// Reusable components built on the "Ink & Atmosphere" design system:
//   - SectionHeader:      Icon + title row for section headers
//   - AlertCountBadge:    Pulsing capsule badge for alert counts
//   - RedesignedAlertBanner: Expandable weather alert banner
//
// Design tokens are in DesignTokens.swift (same target, no import needed).
// WeatherAlert and AlertSeverity are defined in WeatherModels.swift.
// =============================================================================

import SwiftUI

// MARK: - SectionHeader

/// A compact section header with an SF Symbol icon and a title label.
/// Uses design-system tokens for typography, spacing, and color.
struct SectionHeader: View {
    let icon: String
    let title: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: DTSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DTColor.Brand.primaryLight)

            Text(title)
                .font(DTFont.title3.font)
                .fontWeight(.semibold)
                .foregroundStyle(
                    colorScheme == .dark
                        ? .white.opacity(0.9)
                        : .black.opacity(0.8)
                )
        }
    }
}

// MARK: - AlertCountBadge

/// A capsule-shaped badge that displays an alert count with a pulsing
/// gradient background (error -> warning). Designed to draw attention
/// to active weather alerts.
struct AlertCountBadge: View {
    let count: Int

    /// Tracks whether the pulse animation is active.
    @State private var isPulsing = false

    var body: some View {
        Text("\(count)")
            .font(DTFont.label2.font)
            .bold()
            .foregroundStyle(.white)
            .padding(.horizontal, DTSpacing.sm)
            .padding(.vertical, DTSpacing.xxs)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [DTColor.Semantic.error, DTColor.Semantic.warning],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(isPulsing ? 1.08 : 1.0)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
            .fixedSize()
    }
}

// MARK: - RedesignedAlertBanner

/// An expandable banner that displays weather alerts.
/// - Collapsed state shows a summary row with alert count.
/// - Expanded state lists each alert with severity coloring.
/// All visual tokens are sourced from DesignTokens.swift.
struct RedesignedAlertBanner: View {
    let alerts: [WeatherAlert]

    @State private var isExpanded = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // -- Collapsed banner button --
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                collapsedContent
            }
            .buttonStyle(PlainButtonStyle())

            // -- Expanded alert list --
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: Collapsed

    /// The collapsed banner row: icon, title, count badge, and chevron.
    private var collapsedContent: some View {
        HStack(spacing: DTSpacing.md) {
            // Warning icon in a tinted circle
            ZStack {
                Circle()
                    .fill(DTColor.Semantic.warning.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DTColor.Semantic.warning)
            }

            // Title + count subtitle
            VStack(alignment: .leading, spacing: DTSpacing.xxxs) {
                Text("天气警报")
                    .font(DTFont.body1.font)
                    .foregroundStyle(DTColor.Foreground.primary(colorScheme))

                Text("\(alerts.count) 条预警")
                    .font(DTFont.body3.font)
                    .foregroundStyle(DTColor.Foreground.secondary(colorScheme))
            }

            Spacer()

            // Alert count badge + expand chevron
            AlertCountBadge(count: alerts.count)

            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DTColor.Foreground.tertiary(colorScheme))
        }
        .padding(.horizontal, DTSpacing.lg)
        .padding(.vertical, DTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DTRadius.xl)
                .fill(DTColor.Semantic.warning.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: DTRadius.xl)
                        .stroke(DTColor.Semantic.warning.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: Expanded

    /// The expanded list of individual alert cards.
    private var expandedContent: some View {
        VStack(spacing: DTSpacing.sm) {
            ForEach(alerts) { alert in
                alertRow(alert)
            }
        }
        .padding(.top, DTSpacing.sm)
    }

    /// Builds a single alert row for the expanded state.
    private func alertRow(_ alert: WeatherAlert) -> some View {
        HStack(alignment: .top, spacing: DTSpacing.md) {
            // Severity-colored icon circle
            ZStack {
                Circle()
                    .fill(alert.severity.color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: alert.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(alert.severity.color)
            }

            // Title + severity badge, then description
            VStack(alignment: .leading, spacing: DTSpacing.xxs) {
                HStack(spacing: DTSpacing.xs) {
                    Text(alert.title)
                        .font(DTFont.body1.font)
                        .foregroundStyle(DTColor.Foreground.primary(colorScheme))

                    // Severity label capsule
                    Text(alert.severity.label)
                        .font(DTFont.label2.font)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, DTSpacing.sm)
                        .padding(.vertical, DTSpacing.xxxs)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            alert.severity.color,
                                            alert.severity.color.opacity(0.75)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .fixedSize()
                }

                Text(alert.description)
                    .font(DTFont.body3.font)
                    .foregroundStyle(
                        colorScheme == .dark
                            ? .white.opacity(0.6)
                            : .black.opacity(0.55)
                    )
                    .lineLimit(2)
            }
        }
        .padding(DTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DTRadius.lg)
                .fill(alert.severity.color.opacity(0.04))
        )
    }
}
