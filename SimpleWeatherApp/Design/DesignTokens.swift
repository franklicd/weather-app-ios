// =============================================================================
// DesignTokens.swift
// 简天气 - "Ink & Atmosphere" Design System
//
// Single source of truth for all design tokens used across the app.
// Every visual constant should flow through these enums so the UI stays
// consistent and theme-aware.
//
// Color(hex:) is defined in WeatherBackgroundView.swift — do not duplicate here.
// =============================================================================

import SwiftUI

// MARK: - DTColor
/// All color tokens for the "Ink & Atmosphere" design system.
/// Organized into nested namespaces: Brand, Semantic, Light, Dark, Atmosphere, Glass, Weather.
enum DTColor {

    // MARK: Brand
    enum Brand {
        static let primaryLight  = Color(hex: "#1A56DB")
        static let primaryDark   = Color(hex: "#5B9CF6")
        static let secondaryLight = Color(hex: "#E8783A")
        static let secondaryDark  = Color(hex: "#F4A261")
    }

    // MARK: Semantic
    enum Semantic {
        static let success = Color(hex: "#22C55E")
        static let warning = Color(hex: "#F59E0B")
        static let error   = Color(hex: "#EF4444")
        static let info    = Color(hex: "#3B82F6")
    }

    // MARK: Light Neutral
    /// 10-step neutral palette for light mode (lightest to darkest).
    enum Light {
        static let gray50  = Color(hex: "#FAFBFC")
        static let gray100 = Color(hex: "#F1F3F5")
        static let gray200 = Color(hex: "#E5E7EB")
        static let gray300 = Color(hex: "#D1D5DB")
        static let gray400 = Color(hex: "#9CA3AF")
        static let gray500 = Color(hex: "#6B7280")
        static let gray600 = Color(hex: "#4B5563")
        static let gray700 = Color(hex: "#374151")
        static let gray800 = Color(hex: "#1F2937")
        static let gray900 = Color(hex: "#111827")
    }

    // MARK: Dark Neutral
    /// 10-step neutral palette for dark mode (lightest to darkest).
    enum Dark {
        static let gray50  = Color(hex: "#1A1B1E")
        static let gray100 = Color(hex: "#25262B")
        static let gray200 = Color(hex: "#2C2E33")
        static let gray300 = Color(hex: "#35373C")
        static let gray400 = Color(hex: "#4A4D54")
        static let gray500 = Color(hex: "#6B7280")
        static let gray600 = Color(hex: "#9CA3AF")
        static let gray700 = Color(hex: "#C4C9D1")
        static let gray800 = Color(hex: "#E5E7EB")
        static let gray900 = Color(hex: "#F1F3F5")
    }

    // MARK: Atmosphere Tints
    /// Subtle background tints that shift with the current weather condition.
    enum Atmosphere {
        // Light mode
        static let clear   = Color(hex: "#FFF8E7")
        static let cloudy  = Color(hex: "#F0F2F5")
        static let rainy   = Color(hex: "#EBF0F5")
        static let snowy   = Color(hex: "#F5F8FC")
        static let stormy  = Color(hex: "#E8E0F0")
        static let foggy   = Color(hex: "#F2F2F2")

        // Dark mode
        static let clearDk  = Color(hex: "#1A1400")
        static let cloudyDk = Color(hex: "#12141A")
        static let rainyDk  = Color(hex: "#0A1018")
        static let snowyDk  = Color(hex: "#101520")
        static let stormyDk = Color(hex: "#0F0A18")
        static let foggyDk  = Color(hex: "#141414")
    }

    // MARK: Glass
    /// Frosted-glass fill and border colors for card overlays.
    enum Glass {
        static let cardFillLight       = Color.white.opacity(0.55)
        static let cardFillDark        = Color.white.opacity(0.08)
        static let elevatedFillLight   = Color.white.opacity(0.72)
        static let elevatedFillDark    = Color.white.opacity(0.12)
        static let overlayFillLight    = Color.white.opacity(0.85)
        static let overlayFillDark     = Color.white.opacity(0.18)
        static let borderLight         = Color.white.opacity(0.35)
        static let borderDark          = Color.white.opacity(0.08)
    }

    // MARK: Weather
    /// Accent colors mapped to weather conditions (used for icons, badges, etc.).
    enum Weather {
        static let sunny        = Color(hex: "#F59E0B")
        static let partlyCloudy = Color(hex: "#60A5FA")
        static let cloudy       = Color(hex: "#94A3B8")
        static let drizzle      = Color(hex: "#38BDF8")
        static let rain         = Color(hex: "#2563EB")
        static let snow         = Color(hex: "#BAE6FD")
        static let thunder      = Color(hex: "#A78BFA")
        static let fog          = Color(hex: "#CBD5E1")
    }

    // MARK: Background
    /// Solid background colours for the main app surface.
    enum Background {
        static let light = Color(hex: "#F8FAFC")
        static let dark  = Color(hex: "#0A0A0A")
    }

    // MARK: Foreground (theme-aware)
    /// Semantic foreground colours that adapt to light / dark mode.
    /// Pass the current `colorScheme` environment value.
    enum Foreground {
        static func primary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? .white.opacity(0.9) : .black.opacity(0.85)
        }
        static func secondary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5)
        }
        static func tertiary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4)
        }
    }
}

// MARK: - DTFont
/// Typography tokens. Each case maps to a specific SwiftUI Font configuration.
enum DTFont {
    case display1    // 96pt, thin
    case display2    // 72pt, thin
    case display3    // 56pt, ultraLight, rounded
    case title1      // 28pt, bold, rounded
    case title2      // 22pt, semibold, rounded
    case title3      // 18pt, medium, rounded
    case body1       // 17pt, medium
    case body2       // 15pt, regular
    case body3       // 14pt, regular
    case label1      // 13pt, medium
    case label2      // 12pt, medium
    case caption1    // 11pt, regular
    case caption2    // 10pt, regular
    case data1       // 36pt, semibold
    case data2       // 24pt, semibold
    case data3       // 20pt, semibold

    /// Returns the corresponding SwiftUI Font.
    var font: Font {
        switch self {
        case .display1:
            return .system(size: 96, weight: .thin)
        case .display2:
            return .system(size: 72, weight: .thin)
        case .display3:
            return .system(size: 56, weight: .ultraLight, design: .rounded)
        case .title1:
            return .system(size: 28, weight: .bold, design: .rounded)
        case .title2:
            return .system(size: 22, weight: .semibold, design: .rounded)
        case .title3:
            return .system(size: 18, weight: .medium, design: .rounded)
        case .body1:
            return .system(size: 17, weight: .medium)
        case .body2:
            return .system(size: 15, weight: .regular)
        case .body3:
            return .system(size: 14, weight: .regular)
        case .label1:
            return .system(size: 13, weight: .medium)
        case .label2:
            return .system(size: 12, weight: .medium)
        case .caption1:
            return .system(size: 11, weight: .regular)
        case .caption2:
            return .system(size: 10, weight: .regular)
        case .data1:
            return .system(size: 36, weight: .semibold)
        case .data2:
            return .system(size: 24, weight: .semibold)
        case .data3:
            return .system(size: 20, weight: .semibold)
        }
    }
}

// MARK: - DTSpacing
/// Spacing scale used for padding, margins, and gaps.
enum DTSpacing {
    static let xxxs: CGFloat = 2
    static let xxs:  CGFloat = 4
    static let xs:   CGFloat = 6
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let xxl:  CGFloat = 24
    static let xxxl: CGFloat = 32
    static let huge: CGFloat = 48
}

// MARK: - DTRadius
/// Corner radius scale used for rounded rectangles and shapes.
enum DTRadius {
    static let none:  CGFloat = 0
    static let xs:    CGFloat = 4
    static let sm:    CGFloat = 8
    static let md:    CGFloat = 12
    static let lg:    CGFloat = 16
    static let xl:    CGFloat = 20
    static let xxl:   CGFloat = 24
    static let xxxl:  CGFloat = 32
    static let full:  CGFloat = 999
}

// MARK: - DTShadow
/// Shadow presets stored as (color, radius, x, y) tuples.
enum DTShadow {
    static let none = (color: Color.clear,              radius: CGFloat(0),  x: CGFloat(0),  y: CGFloat(0))
    static let sm   = (color: Color.black.opacity(0.08), radius: CGFloat(8),  x: CGFloat(0),  y: CGFloat(2))
    static let md   = (color: Color.black.opacity(0.12), radius: CGFloat(16), x: CGFloat(0),  y: CGFloat(4))
    static let lg   = (color: Color.black.opacity(0.16), radius: CGFloat(24), x: CGFloat(0),  y: CGFloat(8))
    static let xl   = (color: Color.black.opacity(0.20), radius: CGFloat(32), x: CGFloat(0),  y: CGFloat(12))
}

// MARK: - DTShadowModifier
/// ViewModifier that applies a shadow preset with automatic dark-mode compensation.
/// In dark mode the shadow color is boosted to Color.black.opacity(0.3) for visibility.
struct DTShadowModifier: ViewModifier {
    let shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.3) : shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - DTAnimation
/// Standardised animation presets and stagger helpers.
enum DTAnimation {
    static let standardSpring = Animation.spring(response: 0.4, dampingFraction: 0.82)
    static let gentleSpring   = Animation.spring(response: 0.6, dampingFraction: 0.85)
    static let snappySpring   = Animation.spring(response: 0.25, dampingFraction: 0.8)

    /// Returns a delay (in seconds) for list-style staggered animations.
    /// - Parameter index: Zero-based item index.
    /// - Returns: `index * 0.05`
    static func staggerDelay(index: Int) -> Double {
        Double(index) * 0.05
    }

    /// Returns a delay (in seconds) for grid-style staggered animations.
    /// - Parameter index: Zero-based cell index.
    /// - Returns: `index * 0.08`
    static func gridStaggerDelay(index: Int) -> Double {
        Double(index) * 0.08
    }
}
