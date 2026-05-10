import SwiftUI

// MARK: - Weather Background View
/// Lightweight "Ink & Atmosphere" background.
/// Renders a condition-mapped base gradient, subtle ambient particles,
/// and a top vignette for content readability.
struct WeatherBackgroundView: View {
    let weatherCode: Int?
    @State private var particlePhase: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Base gradient per weather condition
            baseGradient
                .ignoresSafeArea()

            // Subtle ambient particles
            if let code = weatherCode {
                AmbientParticleLayer(weatherCode: code)
                    .ignoresSafeArea()
                    .opacity(colorScheme == .dark ? 0.4 : 0.15)
            }

            // Top vignette for readability
            LinearGradient(
                colors: [
                    Color.black.opacity(colorScheme == .dark ? 0.3 : 0.02),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Base Gradient

    /// Returns the condition-appropriate linear gradient.
    @ViewBuilder
    private var baseGradient: some View {
        let isDark = colorScheme == .dark
        if let code = weatherCode {
            switch code {
            // Clear / Mainly Clear
            case 0, 1:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#0A0F1A"), Color(hex: "#111827")]
                        : [Color(hex: "#FFFBEB"), Color(hex: "#FFF7ED"), Color(hex: "#FEF3C7")],
                    startPoint: .top,
                    endPoint: .bottom
                )

            // Partly Cloudy
            case 2:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#0A0F1A"), Color(hex: "#0F172A")]
                        : [Color(hex: "#EFF6FF"), Color(hex: "#F8FAFC")],
                    startPoint: .top,
                    endPoint: .bottom
                )

            // Overcast
            case 3:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#0A0A0F"), Color(hex: "#111115")]
                        : [Color(hex: "#F1F5F9"), Color(hex: "#F8FAFC")],
                    startPoint: .top,
                    endPoint: .bottom
                )

            // Fog / Depositing Rime Fog
            case 45, 48:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#0A0A0A"), Color(hex: "#111111")]
                        : [Color(hex: "#F8FAFC"), Color(hex: "#F1F5F9")],
                    startPoint: .top,
                    endPoint: .bottom
                )

            // Drizzle (51-57)
            case 51...57:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#0A0F18"), Color(hex: "#0F172A")]
                        : [Color(hex: "#E2E8F0"), Color(hex: "#F1F5F9")],
                    startPoint: .top,
                    endPoint: .bottom
                )

            // Rain (61-65, 80-82)
            case 61...65, 80...82:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#050810"), Color(hex: "#0A1020")]
                        : [Color(hex: "#E2E8F0"), Color(hex: "#F1F5F9")],
                    startPoint: .top,
                    endPoint: .bottom
                )

            // Snow (71-77, 85-86)
            case 71...77, 85, 86:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#0A0F18"), Color(hex: "#111827")]
                        : [Color(hex: "#F0F9FF"), Color(hex: "#FAFBFC")],
                    startPoint: .top,
                    endPoint: .bottom
                )

            // Thunderstorm (95-99)
            case 95...99:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#050508"), Color(hex: "#0A0A1A")]
                        : [Color(hex: "#E8E0F0"), Color(hex: "#F1F0F5")],
                    startPoint: .top,
                    endPoint: .bottom
                )

            // Default
            default:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "#0A0A0A"), Color(hex: "#141414")]
                        : [Color(hex: "#FAFAFA"), Color(hex: "#FFFFFF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            // No weather code — default gradient
            LinearGradient(
                colors: isDark
                    ? [Color(hex: "#0A0A0A"), Color(hex: "#141414")]
                    : [Color(hex: "#FAFAFA"), Color(hex: "#FFFFFF")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Ambient Particle Layer

/// Canvas-based particle layer. Uses a single draw call with golden-ratio
/// x-distribution and a gentle vertical drift animation.
struct AmbientParticleLayer: View {
    let weatherCode: Int
    @State private var phase: CGFloat = 0

    /// Number of particles varies by weather condition.
    private var particleCount: Int {
        switch weatherCode {
        case 0, 1:                          return 15
        case 51...57:                       return 35
        case 61...65, 80...82:              return 40
        case 71...77, 85, 86:               return 40
        case 95...99:                       return 50
        default:                            return 20
        }
    }

    var body: some View {
        Canvas { context, size in
            let goldenRatio: CGFloat = 1.618033988749895
            let count = particleCount

            for i in 0..<count {
                // Golden ratio distribution for x positions
                let xNorm = CGFloat((Double(i) * goldenRatio).truncatingRemainder(dividingBy: 1.0))
                let x = size.width * xNorm

                // Animate y based on phase; offset each particle differently
                let yBase = size.height * CGFloat(i) / CGFloat(count)
                let yOffset = phase * size.height
                let y = (yBase + yOffset).truncatingRemainder(dividingBy: size.height)

                // Particle radius: 1-3 pt
                let radius: CGFloat = 1.0 + CGFloat(i % 3)
                // Very low opacity: 0.05-0.15
                let opacity: Double = 0.05 + Double(i % 11) * 0.01

                let rect = CGRect(
                    x: x - radius,
                    y: y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                context.opacity = opacity
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(.white)
                )
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 15)
                .repeatForever(autoreverses: false)
            ) {
                phase = 1.0
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
