// =============================================================================
// ContainerStyles.swift
// SimpleWeatherApp - "Ink & Atmosphere" Design System
//
// Reusable ViewModifiers for common container patterns: GlassCard, TintedCard,
// and InsetRow. Each modifier consumes tokens from DesignTokens.swift so the
// visual language stays consistent across the entire app.
//
// Usage:
//   someView.glassCard()
//   someView.tintedCard(tint: .blue)
//   someView.insetRow()
// =============================================================================

import SwiftUI

// MARK: - GlassCard

/// A frosted-glass card using `.ultraThinMaterial` with a subtle border.
///
/// - Depth is conveyed through material blur, not shadow.
/// - Border opacity adapts to light / dark mode via `@Environment(\.colorScheme)`.
struct GlassCard: ViewModifier {

    /// Corner radius of the rounded rectangle. Defaults to `DTRadius.xl` (20pt).
    var cornerRadius: CGFloat = DTRadius.xl

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(DTSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        colorScheme == .dark
                            ? Color.white.opacity(0.08)
                            : Color.white.opacity(0.35),
                        lineWidth: 0.5
                    )
            )
    }
}

// MARK: - TintedCard

/// A flat, tinted container with a very light fill and matching stroke.
///
/// - No blur, no shadow. Ideal for inline information blocks.
/// - The tint colour drives both fill (8 % opacity) and stroke (12 % opacity).
struct TintedCard: ViewModifier {

    /// The driving colour for fill and stroke.
    let tint: Color

    /// Corner radius of the rounded rectangle. Defaults to `DTRadius.lg` (16pt).
    var cornerRadius: CGFloat = DTRadius.lg

    func body(content: Content) -> some View {
        content
            .padding(DTSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(tint.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(tint.opacity(0.12), lineWidth: 0.5)
            )
    }
}

// MARK: - InsetRow

/// A minimal inset row used for list-like items inside cards.
///
/// - Barely-visible fill that subtly differentiates the row from its parent.
/// - Fill colour flips between light and dark mode for proper contrast.
struct InsetRow: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, DTSpacing.md)
            .padding(.vertical, DTSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DTRadius.md)
                    .fill(
                        colorScheme == .dark
                            ? Color.white.opacity(0.04)
                            : Color.black.opacity(0.03)
                    )
            )
    }
}

// MARK: - View Convenience Extensions

extension View {

    /// Wraps the view in a frosted-glass card with a subtle border.
    ///
    /// - Parameter cornerRadius: Corner radius. Defaults to `DTRadius.xl` (20pt).
    /// - Returns: The modified view.
    func glassCard(cornerRadius: CGFloat = DTRadius.xl) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }

    /// Wraps the view in a flat, tinted card.
    ///
    /// - Parameters:
    ///   - tint: The colour that drives fill and stroke.
    ///   - cornerRadius: Corner radius. Defaults to `DTRadius.lg` (16pt).
    /// - Returns: The modified view.
    func tintedCard(tint: Color, cornerRadius: CGFloat = DTRadius.lg) -> some View {
        modifier(TintedCard(tint: tint, cornerRadius: cornerRadius))
    }

    /// Applies a minimal inset-row background.
    ///
    /// - Returns: The modified view.
    func insetRow() -> some View {
        modifier(InsetRow())
    }
}
