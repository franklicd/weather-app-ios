# SimpleWeather Design Mockup

## 1. Design Philosophy

### Direction: "Ink & Atmosphere"

The redesigned visual language draws from two principles:

**Ink** -- Chinese calligraphic minimalism. Every element is deliberate. Negative space is a feature, not a gap. Typography carries the weight of information, with Chinese characters rendered in a deliberate, weighted scale that respects stroke density and optical sizing.

**Atmosphere** -- Weather is not decoration; it is the interface. The entire screen responds to conditions through a unified atmospheric layer: tinted backgrounds, ambient particle density, color temperature shifts, and material opacity modulation. A rainy day feels fundamentally different from a sunny one -- not just in the icon choice, but in the light, depth, and density of every surface.

### Design Principles

1. **Structural clarity over decoration.** Each card serves a distinct data purpose. Visual treatments are differentiated by function, not applied uniformly.
2. **Progressive disclosure.** Primary data is large and immediate. Secondary data is accessible but not competing. Tertiary data requires interaction.
3. **Atmospheric consistency.** Weather condition influences every surface: card opacity, blur intensity, accent color, particle overlay, and background gradient shift together as a system.
4. **Chinese-first typography.** Font sizing accounts for CJK character width and stroke count. Line heights are generous. Font weights use `.medium` and `.bold` for Chinese where Latin might use `.regular` and `.semibold`.
5. **Depth through material, not shadow.** Glassmorphism provides visual hierarchy via blur intensity and opacity, not drop shadows. Shadows are used sparingly for floating elements only.

---

## 2. Design Token System

### 2.1 Color Palette

```swift
// MARK: - Design Tokens: Colors

enum DTColor {
    // MARK: - Brand Colors
    /// Primary accent -- used for interactive elements, selected states, links
    /// Light: deep ocean blue  |  Dark: luminous cerulean
    static let primaryLight  = Color(hex: "1A56DB")
    static let primaryDark   = Color(hex: "5B9CF6")

    /// Secondary accent -- complementary warm tone for alerts, highlights
    static let secondaryLight = Color(hex: "E8783A")
    static let secondaryDark  = Color(hex: "F4A261")

    // MARK: - Semantic Colors
    static let success = Color(hex: "22C55E")   // good conditions, positive states
    static let warning = Color(hex: "F59E0B")   // moderate alerts
    static let error   = Color(hex: "EF4444")   // severe alerts, errors
    static let info    = Color(hex: "3B82F6")   // informational states

    // MARK: - Neutral Scale (Light Mode)
    enum Light {
        static let gray50  = Color(hex: "FAFBFC")
        static let gray100 = Color(hex: "F1F3F5")
        static let gray200 = Color(hex: "E5E7EB")
        static let gray300 = Color(hex: "D1D5DB")
        static let gray400 = Color(hex: "9CA3AF")
        static let gray500 = Color(hex: "6B7280")
        static let gray600 = Color(hex: "4B5563")
        static let gray700 = Color(hex: "374151")
        static let gray800 = Color(hex: "1F2937")
        static let gray900 = Color(hex: "111827")
    }

    // MARK: - Neutral Scale (Dark Mode)
    enum Dark {
        static let gray50  = Color(hex: "1A1B1E")
        static let gray100 = Color(hex: "25262B")
        static let gray200 = Color(hex: "2C2E33")
        static let gray300 = Color(hex: "35373C")
        static let gray400 = Color(hex: "4A4D54")
        static let gray500 = Color(hex: "6B7280")
        static let gray600 = Color(hex: "9CA3AF")
        static let gray700 = Color(hex: "C4C9D1")
        static let gray800 = Color(hex: "E5E7EB")
        static let gray900 = Color(hex: "F1F3F5")
    }

    // MARK: - Atmospheric Tint Colors
    /// Applied to backgrounds and materials based on weather condition
    enum Atmosphere {
        static let clear   = Color(hex: "FFF8E7")   // warm cream tint (light)
        static let cloudy  = Color(hex: "F0F2F5")   // cool neutral tint
        static let rainy   = Color(hex: "EBF0F5")   // steel blue tint
        static let snowy   = Color(hex: "F5F8FC")   // icy white tint
        static let stormy  = Color(hex: "E8E0F0")   // violet undertone
        static let foggy   = Color(hex: "F2F2F2")   // flat gray tint

        // Dark mode tints (subtle overlays)
        static let clearDk   = Color(hex: "1A1400")   // warm dark amber
        static let cloudyDk  = Color(hex: "12141A")   // cool dark slate
        static let rainyDk   = Color(hex: "0A1018")   // deep navy
        static let snowyDk   = Color(hex: "101520")   // icy dark blue
        static let stormyDk  = Color(hex: "0F0A18")   // deep purple
        static let foggyDk   = Color(hex: "141414")   // flat dark
    }

    // MARK: - Glass Material Colors
    /// Opacity levels for glassmorphic surfaces
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

    // MARK: - Weather Accent Colors (for icons, highlights)
    enum Weather {
        static let sunny     = Color(hex: "F59E0B")
        static let partlyCloudy = Color(hex: "60A5FA")
        static let cloudy    = Color(hex: "94A3B8")
        static let drizzle   = Color(hex: "38BDF8")
        static let rain      = Color(hex: "2563EB")
        static let snow      = Color(hex: "BAE6FD")
        static let thunder   = Color(hex: "A78BFA")
        static let fog       = Color(hex: "CBD5E1")
    }
}
```

### 2.2 Typography Scale

```swift
// MARK: - Design Tokens: Typography

enum DTFont {
    /// Chinese-optimized font family fallback chain
    /// SF Pro handles Latin; system rounds for CJK
    static let primaryFont: String = "SF Pro Display"
    static let roundedFont: String = "SF Pro Rounded"
    static let monoFont: String    = "SF Mono"

    // MARK: - Display Scale (Hero numbers, splash screen)
    /// 96pt thin -- temperature hero, splash title
    static let display1 = Font.system(size: 96, weight: .thin, design: .default)
    /// 72pt thin -- large temperature
    static let display2 = Font.system(size: 72, weight: .thin, design: .default)
    /// 56pt ultraLight -- secondary display
    static let display3 = Font.system(size: 56, weight: .ultraLight, design: .rounded)

    // MARK: - Title Scale (Section headers, card titles)
    /// 28pt bold -- page titles
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    /// 22pt semibold -- section headers
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    /// 18pt medium -- card section titles
    static let title3 = Font.system(size: 18, weight: .medium, design: .rounded)

    // MARK: - Body Scale (Content, data values)
    /// 17pt medium -- primary body text (Chinese uses medium for readability)
    static let body1 = Font.system(size: 17, weight: .medium, design: .default)
    /// 15pt regular -- secondary body text
    static let body2 = Font.system(size: 15, weight: .regular, design: .default)
    /// 14pt regular -- tertiary body text
    static let body3 = Font.system(size: 14, weight: .regular, design: .default)

    // MARK: - Label Scale (Tags, badges, metadata)
    /// 13pt medium -- labels
    static let label1 = Font.system(size: 13, weight: .medium, design: .default)
    /// 12pt medium -- small labels
    static let label2 = Font.system(size: 12, weight: .medium, design: .default)
    /// 11pt regular -- captions, footnotes
    static let caption1 = Font.system(size: 11, weight: .regular, design: .default)
    /// 10pt regular -- tiny captions
    static let caption2 = Font.system(size: 10, weight: .regular, design: .default)

    // MARK: - Data Scale (Numbers, measurements)
    /// 36pt semibold monospaced -- large data values
    static let data1 = Font.system(size: 36, weight: .semibold, design: .default)
    /// 24pt semibold -- medium data values
    static let data2 = Font.system(size: 24, weight: .semibold, design: .default)
    /// 20pt semibold -- small data values
    static let data3 = Font.system(size: 20, weight: .semibold, design: .default)
}
```

### 2.3 Spacing System

```swift
// MARK: - Design Tokens: Spacing

enum DTSpacing {
    /// 2pt -- tight gaps between inline elements
    static let xxxs: CGFloat = 2
    /// 4pt -- icon-to-text gaps, badge padding
    static let xxs: CGFloat = 4
    /// 6pt -- minimum touch target inner padding
    static let xs: CGFloat = 6
    /// 8pt -- standard inline spacing
    static let sm: CGFloat = 8
    /// 12pt -- compact vertical rhythm
    static let md: CGFloat = 12
    /// 16pt -- standard vertical rhythm, card internal padding
    static let lg: CGFloat = 16
    /// 20pt -- section internal padding
    static let xl: CGFloat = 20
    /// 24pt -- section gaps
    static let xxl: CGFloat = 24
    /// 32pt -- major section separation
    static let xxxl: CGFloat = 32
    /// 48pt -- hero section breathing room
    static let huge: CGFloat = 48
}
```

### 2.4 Corner Radius

```swift
// MARK: - Design Tokens: Corner Radius

enum DTRadius {
    static let none: CGFloat = 0
    static let xs: CGFloat = 4     // tags, small badges
    static let sm: CGFloat = 8     // buttons, inputs
    static let md: CGFloat = 12    // list rows, inner cards
    static let lg: CGFloat = 16    // primary cards
    static let xl: CGFloat = 20    // large containers
    static let xxl: CGFloat = 24   // hero cards, modals
    static let xxxl: CGFloat = 32  // full-width panels
    static let full: CGFloat = 999 // circles, pills
}
```

### 2.5 Shadow System

```swift
// MARK: - Design Tokens: Shadows

enum DTShadow {
    /// No shadow -- flat surfaces, list items
    static let none: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (.clear, 0, 0, 0)

    /// Subtle lift -- selected cards, active states
    static let sm: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.08), 8, 0, 2)

    /// Standard elevation -- primary cards
    static let md: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.12), 16, 0, 4)

    /// Prominent float -- floating panels, modals
    static let lg: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.16), 24, 0, 8)

    /// Hero float -- hero temperature card
    static let xl: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.20), 32, 0, 12)
}

// MARK: - Shadow Modifier

struct DTShadowModifier: ViewModifier {
    let level: DTShadow.typealias
    @Environment(\.colorScheme) private var colorScheme

    // We use a typealias workaround; see extension below
    init(_ shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)) {
        self.level = shadow
    }

    func body(content: Content) -> some View {
        content.shadow(
            color: colorScheme == .dark
                ? Color.black.opacity(0.3)
                : level.color,
            radius: level.radius,
            x: level.x,
            y: level.y
        )
    }
}
```

### 2.6 Card / Container Styles

Three distinct container types, differentiated by visual weight and function:

```swift
// MARK: - Container Styles

/// Style 1: Glass Card -- Primary content containers
/// Used for: Main weather card, hourly forecast, daily forecast
/// Characteristics: Frosted glass, moderate blur, subtle border
struct GlassCard: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = DTRadius.xl) {
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .padding(DTSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                colorScheme == .dark
                                    ? DTColor.Glass.borderDark
                                    : DTColor.Glass.borderLight,
                                lineWidth: 0.5
                            )
                    )
            )
    }
}

/// Style 2: Tinted Card -- Semantic data containers
/// Used for: Detail grid cells, AQI gauge, alert items
/// Characteristics: Solid color tint, no blur, stronger visual identity
struct TintedCard: ViewModifier {
    let tint: Color
    let cornerRadius: CGFloat

    init(tint: Color, cornerRadius: CGFloat = DTRadius.lg) {
        self.tint = tint
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .padding(DTSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(tint.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(tint.opacity(0.12), lineWidth: 0.5)
                    )
            )
    }
}

/// Style 3: Inset Row -- List items within cards
/// Used for: Individual forecast rows, pollutant rows
/// Characteristics: Minimal background, subtle separator, compact
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

// MARK: - Convenience Extensions

extension View {
    func glassCard(cornerRadius: CGFloat = DTRadius.xl) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }

    func tintedCard(tint: Color, cornerRadius: CGFloat = DTRadius.lg) -> some View {
        modifier(TintedCard(tint: tint, cornerRadius: cornerRadius))
    }

    func insetRow() -> some View {
        modifier(InsetRow())
    }
}
```

---

## 3. Component Library

### 3.1 Redesigned Main Weather Hero Card

The hero card is the visual centerpiece. It uses a large, atmospheric gradient background instead of generic glass material, with the temperature as the dominant element.

```swift
// MARK: - Redesigned Hero Weather Card

struct RedesignedHeroCard: View {
    let weather: CurrentWeather
    let alertCount: Int
    @State private var breathe = false
    @Environment(\.colorScheme) private var colorScheme

    /// Weather-conditioned gradient for the hero card
    private var heroGradient: LinearGradient {
        let code = weather.weather_code
        let isDark = colorScheme == .dark

        switch code {
        case 0, 1:  // Clear
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "1E3A5F").opacity(0.6), Color(hex: "2D1B69").opacity(0.4)]
                    : [Color(hex: "FEF3C7").opacity(0.7), Color(hex: "FDE68A").opacity(0.5), Color(hex: "FBBF24").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2:     // Partly cloudy
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "1E3A5F").opacity(0.5), Color(hex: "374151").opacity(0.4)]
                    : [Color(hex: "DBEAFE").opacity(0.6), Color(hex: "E0F2FE").opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        case 61...65, 80...82:  // Rain
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "0F172A").opacity(0.6), Color(hex: "1E293B").opacity(0.4)]
                    : [Color(hex: "CBD5E1").opacity(0.5), Color(hex: "94A3B8").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 71...77, 85, 86:   // Snow
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "1E293B").opacity(0.5), Color(hex: "334155").opacity(0.3)]
                    : [Color(hex: "F0F9FF").opacity(0.7), Color(hex: "E0F2FE").opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        case 95...99:  // Thunderstorm
            return LinearGradient(
                colors: isDark
                    ? [Color(hex: "1E1B4B").opacity(0.6), Color(hex: "312E81").opacity(0.4)]
                    : [Color(hex: "DDD6FE").opacity(0.5), Color(hex: "C4B5FD").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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

    var body: some View {
        VStack(spacing: DTSpacing.sm) {
            // Top row: icon + alert badge
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

            // Temperature -- the hero number
            Text("\(Int(weather.temperature_2m))°")
                .font(DTFont.display1)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.95)
                        : Color.black.opacity(0.85)
                )
                .contentTransition(.numericText())

            // Weather description
            Text(WeatherCode.description(for: weather.weather_code))
                .font(DTFont.title3)
                .fontWeight(.semibold)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.75)
                        : Color.black.opacity(0.6)
                )

            // Feels-like temperature
            Text("体感 \(Int(weather.apparent_temperature))°")
                .font(DTFont.body3)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.5)
                        : Color.black.opacity(0.4)
                )
                .padding(.bottom, DTSpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // Base material
                RoundedRectangle(cornerRadius: DTRadius.xxxl)
                    .fill(.ultraThinMaterial)

                // Weather-conditioned gradient overlay
                RoundedRectangle(cornerRadius: DTRadius.xxxl)
                    .fill(heroGradient)

                // Subtle inner highlight
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
                radius: 24, x: 0, y: 8
            )
        )
        .onAppear { breathe = true }
    }
}

/// Compact alert badge for the hero card
struct AlertCountBadge: View {
    let count: Int
    @State private var pulse = false

    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [DTColor.error.opacity(0.9), DTColor.warning.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .scaleEffect(pulse ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: pulse
                )

            Text("\(count)")
                .font(DTFont.label2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, DTSpacing.sm)
                .padding(.vertical, DTSpacing.xxs)
        }
        .fixedSize()
        .onAppear { pulse = true }
    }
}
```

### 3.2 Redesigned Hourly Forecast

The hourly section uses a "filmstrip" pattern: a horizontal scroll with items that have a subtle background gradient based on their temperature relative to the day's range.

```swift
// MARK: - Redesigned Hourly Forecast

struct RedesignedHourlyForecast: View {
    let items: [HourlyItem]
    @State private var appear = false
    @Environment(\.colorScheme) private var colorScheme

    struct HourlyItem {
        let time: String
        let temperature: Double
        let weatherCode: Int
        let isNow: Bool
    }

    /// Temperature range for gradient mapping
    private var tempRange: (min: Double, max: Double) {
        let temps = items.map(\.temperature)
        return (temps.min() ?? 0, temps.max() ?? 30)
    }

    /// Map temperature to a 0-1 progress for the gradient bar
    private func tempProgress(_ temp: Double) -> Double {
        let range = tempRange.max - tempRange.min
        guard range > 0 else { return 0.5 }
        return (temp - tempRange.min) / range
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.md) {
            // Section header
            SectionHeader(icon: "clock.fill", title: "逐时预报")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DTSpacing.sm) {
                    ForEach(Array(items.prefix(24).enumerated()), id: \.offset) { index, item in
                        RedesignedHourlyItem(
                            item: item,
                            tempProgress: tempProgress(item.temperature),
                            isNow: item.isNow
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

struct RedesignedHourlyItem: View {
    let item: RedesignedHourlyForecast.HourlyItem
    let tempProgress: Double
    let isNow: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: DTSpacing.sm) {
            // Time label
            Text(item.time)
                .font(isNow ? DTFont.label1 : DTFont.label2)
                .fontWeight(isNow ? .semibold : .medium)
                .foregroundStyle(
                    isNow
                        ? .white
                        : (colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.5))
                )

            // Weather icon
            Image(systemName: WeatherCode.icon(for: item.weatherCode))
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(
                    isNow
                        ? .white
                        : WeatherCode.color(for: item.weatherCode)
                )
                .symbolEffect(.bounce, options: .speed(0.5), value: isNow)

            // Temperature with mini gradient bar
            VStack(spacing: DTSpacing.xxs) {
                Text("\(Int(item.temperature))°")
                    .font(isNow ? DTFont.data3 : DTFont.body1)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        isNow
                            ? .white
                            : (colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.8))
                    )

                // Mini temperature bar
                if !isNow {
                    RoundedRectangle(cornerRadius: DTRadius.full)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DTColor.Info.opacity(0.6),
                                    DTColor.secondaryLight.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(CGFloat(tempProgress) * 32, 4), height: 3)
                }
            }
        }
        .padding(.vertical, DTSpacing.md)
        .padding(.horizontal, DTSpacing.sm)
        .frame(minWidth: 64)
        .background(
            RoundedRectangle(cornerRadius: DTRadius.lg)
                .fill(
                    isNow
                        ? LinearGradient(
                            colors: [
                                Color(hex: "1A56DB"),
                                Color(hex: "3B82F6")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                colorScheme == .dark
                                    ? Color.white.opacity(0.06)
                                    : Color.black.opacity(0.03),
                                colorScheme == .dark
                                    ? Color.white.opacity(0.02)
                                    : Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
        )
    }
}
```

### 3.3 Redesigned Detail Grid

The detail grid uses the TintedCard style -- each cell has a unique semantic color, creating visual variety while maintaining structure.

```swift
// MARK: - Redesigned Detail Grid

struct RedesignedDetailGrid: View {
    let weather: CurrentWeather
    @State private var appear = false
    @Environment(\.colorScheme) private var colorScheme

    private var cells: [(icon: String, label: String, value: String, tint: Color)] {
        var items: [(icon: String, label: String, value: String, tint: Color)] = [
            ("humidity.fill",   "湿度",     "\(weather.relative_humidity_2m)%",     Color(hex: "3B82F6")),
            ("wind",            "风速",     "\(Int(weather.wind_speed_10m)) km/h",  Color(hex: "06B6D4")),
        ]
        if let vis = weather.visibility {
            items.append(("eye.fill", "能见度", "\(Int(vis / 1000)) km", Color(hex: "8B5CF6")))
        }
        items.append(("thermometer.medium", "体感温度", "\(Int(weather.apparent_temperature))°C", Color(hex: "F59E0B")))
        return items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.md) {
            SectionHeader(icon: "square.grid.2x2.fill", title: "详细数据")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DTSpacing.md),
                    GridItem(.flexible(), spacing: DTSpacing.md)
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
                    .scaleEffect(appear ? 1 : 0.85)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(index) * 0.08),
                        value: appear
                    )
                }
            }
        }
        .glassCard(cornerRadius: DTRadius.xxl)
        .onAppear { appear = true }
    }
}

struct DetailDataCell: View {
    let icon: String
    let label: String
    let value: String
    let tint: Color
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.sm) {
            // Icon + Label row
            HStack(spacing: DTSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(tint)
                }

                Text(label)
                    .font(DTFont.label2)
                    .foregroundStyle(
                        colorScheme == .dark
                            ? Color.white.opacity(0.5)
                            : Color.black.opacity(0.4)
                    )
            }

            // Value
            Text(value)
                .font(DTFont.data3)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.9)
                        : Color.black.opacity(0.85)
                )
        }
        .padding(DTSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DTRadius.lg)
                .fill(tint.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: DTRadius.lg)
                        .stroke(tint.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
}
```

### 3.4 Redesigned AQI / UV Visualization

```swift
// MARK: - Redesigned Air Quality & UV Card

struct RedesignedAQIUVCard: View {
    let aq: AirQualityData
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.lg) {
            SectionHeader(icon: "leaf.fill", title: "空气 & 紫外线")

            HStack(spacing: DTSpacing.lg) {
                if let aqi = aq.us_aqi {
                    RedesignedGaugeView(
                        value: aqi,
                        maxValue: 300,
                        label: "AQI",
                        levelText: AirQualityHelper.aqiLevel(for: aqi),
                        tint: AirQualityHelper.aqiColor(for: aqi)
                    )
                }

                if let uv = aq.uv_index {
                    RedesignedGaugeView(
                        value: Int(uv),
                        maxValue: 11,
                        label: "紫外线",
                        levelText: AirQualityHelper.uvLevel(for: uv),
                        tint: AirQualityHelper.uvColor(for: uv)
                    )
                }
            }

            // Pollutant rows
            VStack(spacing: DTSpacing.xs) {
                if let pm25 = aq.pm2_5 {
                    PollutantBar(label: "PM2.5", value: pm25, max: 150, unit: "ug/m3")
                }
                if let pm10 = aq.pm10 {
                    PollutantBar(label: "PM10", value: pm10, max: 200, unit: "ug/m3")
                }
            }
        }
        .glassCard(cornerRadius: DTRadius.xxl)
    }
}

/// Circular gauge with a sweep arc
struct RedesignedGaugeView: View {
    let value: Int
    let maxValue: Int
    let label: String
    let levelText: String
    let tint: Color
    @Environment(\.colorScheme) private var colorScheme

    private var progress: Double {
        min(Double(value) / Double(maxValue), 1.0)
    }

    var body: some View {
        VStack(spacing: DTSpacing.xs) {
            ZStack {
                // Background track
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

                // Value
                VStack(spacing: 0) {
                    Text("\(value)")
                        .font(DTFont.data2)
                        .foregroundStyle(tint)

                    Text(label)
                        .font(DTFont.caption2)
                        .foregroundStyle(
                            colorScheme == .dark
                                ? Color.white.opacity(0.5)
                                : Color.black.opacity(0.4)
                        )
                }
            }

            // Level badge
            Text(levelText)
                .font(DTFont.caption1)
                .fontWeight(.medium)
                .foregroundStyle(tint)
                .padding(.horizontal, DTSpacing.sm)
                .padding(.vertical, DTSpacing.xxs)
                .background(
                    Capsule().fill(tint.opacity(0.12))
                )
        }
        .frame(maxWidth: .infinity)
    }
}

/// Horizontal bar for pollutant values
struct PollutantBar: View {
    let label: String
    let value: Double
    let max: Double
    let unit: String
    @Environment(\.colorScheme) private var colorScheme

    private var progress: Double {
        min(value / max, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.xxs) {
            HStack {
                Text(label)
                    .font(DTFont.body3)
                    .foregroundStyle(
                        colorScheme == .dark
                            ? Color.white.opacity(0.6)
                            : Color.black.opacity(0.5)
                    )

                Spacer()

                Text("\(Int(value)) \(unit)")
                    .font(DTFont.label2)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        colorScheme == .dark
                            ? Color.white.opacity(0.8)
                            : Color.black.opacity(0.7)
                    )
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DTRadius.full)
                        .fill(
                            colorScheme == .dark
                                ? Color.white.opacity(0.06)
                                : Color.black.opacity(0.04)
                        )
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: DTRadius.full)
                        .fill(
                            LinearGradient(
                                colors: [
                                    progress < 0.5
                                        ? DTColor.success
                                        : (progress < 0.75 ? DTColor.warning : DTColor.error),
                                    (progress < 0.5
                                        ? DTColor.success
                                        : (progress < 0.75 ? DTColor.warning : DTColor.error)).opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(progress), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, DTSpacing.xxs)
    }
}
```

### 3.5 Redesigned 7-Day Forecast

```swift
// MARK: - Redesigned 7-Day Forecast

struct RedesignedForecastSection: View {
    let daily: DailyForecast
    @State private var appear = false
    @State private var barsAppear = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: DTSpacing.md) {
            SectionHeader(icon: "calendar", title: "7天预报")

            VStack(spacing: 0) {
                ForEach(Array(forecastItems.enumerated()), id: \.element.date) { index, item in
                    HStack(spacing: DTSpacing.md) {
                        // Date
                        Text(item.date)
                            .font(DTFont.body2)
                            .fontWeight(index == 0 ? .semibold : .medium)
                            .foregroundStyle(
                                index == 0
                                    ? DTColor.primaryLight
                                    : (colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7))
                            )
                            .frame(width: 52, alignment: .leading)

                        // Weather icon -- smaller, inline
                        Image(systemName: WeatherCode.icon(for: item.code))
                            .font(.system(size: 18))
                            .foregroundStyle(WeatherCode.color(for: item.code))
                            .frame(width: 24)

                        // Min temp
                        Text("\(Int(item.min))°")
                            .font(DTFont.label1)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.5)
                                    : Color.black.opacity(0.35)
                            )
                            .frame(width: 32, alignment: .trailing)

                        // Temperature range bar
                        GeometryReader { geo in
                            let globalMin = forecastItems.map(\.min).min() ?? 0
                            let globalMax = forecastItems.map(\.max).max() ?? 30
                            let range = globalMax - globalMin
                            guard range > 0 else { return AnyView(EmptyView()) }

                            let normalizedMin = CGFloat((item.min - globalMin) / range)
                            let normalizedMax = CGFloat((item.max - globalMin) / range)

                            return AnyView(
                                ZStack(alignment: .leading) {
                                    // Background track
                                    RoundedRectangle(cornerRadius: DTRadius.full)
                                        .fill(
                                            colorScheme == .dark
                                                ? Color.white.opacity(0.06)
                                                : Color.black.opacity(0.04)
                                        )
                                        .frame(height: 5)

                                    // Temperature range fill
                                    RoundedRectangle(cornerRadius: DTRadius.full)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "60A5FA"),
                                                    Color(hex: "F59E0B")
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: barsAppear
                                                ? max(geo.size.width * (normalizedMax - normalizedMin), 8)
                                                : 0,
                                            height: 5
                                        )
                                        .offset(x: barsAppear ? geo.size.width * normalizedMin : 0)
                                        .animation(
                                            .spring(response: 0.8, dampingFraction: 0.7)
                                                .delay(0.15 + Double(index) * 0.04),
                                            value: barsAppear
                                        )
                                }
                            )
                        }
                        .frame(height: 5)

                        // Max temp
                        Text("\(Int(item.max))°")
                            .font(DTFont.label1)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.9)
                                    : Color.black.opacity(0.8)
                            )
                            .frame(width: 32, alignment: .leading)
                    }
                    .padding(.vertical, DTSpacing.sm)

                    if index < forecastItems.count - 1 {
                        Divider()
                            .background(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.06)
                                    : Color.black.opacity(0.04)
                            )
                    }
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

    struct ForecastItem {
        let date: String
        let code: Int
        let max: Double
        let min: Double
    }

    var forecastItems: [ForecastItem] {
        // Same logic as existing ForecastSection.forecastItems
        // omitted for brevity; copy from current implementation
        []
    }
}
```

### 3.6 Section Header Component

```swift
// MARK: - Reusable Section Header

struct SectionHeader: View {
    let icon: String
    let title: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: DTSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DTColor.primaryLight)

            Text(title)
                .font(DTFont.title3)
                .fontWeight(.semibold)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.9)
                        : Color.black.opacity(0.8)
                )
        }
    }
}
```

### 3.7 Redesigned Alert Banner

```swift
// MARK: - Redesigned Alert Banner

struct RedesignedAlertBanner: View {
    let alerts: [WeatherAlert]
    @State private var isExpanded = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Collapsed banner
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: DTSpacing.md) {
                    // Icon with severity-tinted background
                    ZStack {
                        Circle()
                            .fill(DTColor.warning.opacity(0.15))
                            .frame(width: 36, height: 36)

                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(DTColor.warning)
                    }

                    VStack(alignment: .leading, spacing: DTSpacing.xxs) {
                        Text("天气警报")
                            .font(DTFont.body1)
                            .foregroundStyle(
                                colorScheme == .dark ? .white : .black
                            )

                        Text("\(alerts.count) 条预警")
                            .font(DTFont.body3)
                            .foregroundStyle(
                                colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.4)
                            )
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(
                            colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.3)
                        )
                }
                .padding(DTSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DTRadius.xl)
                        .fill(DTColor.warning.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: DTRadius.xl)
                                .stroke(DTColor.warning.opacity(0.15), lineWidth: 0.5)
                        )
                )
            }
            .buttonStyle(.plain)

            // Expanded alerts
            if isExpanded {
                VStack(spacing: DTSpacing.sm) {
                    ForEach(alerts) { alert in
                        HStack(spacing: DTSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(alert.severity.color.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Image(systemName: alert.icon)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(alert.severity.color)
                            }

                            VStack(alignment: .leading, spacing: DTSpacing.xxs) {
                                HStack {
                                    Text(alert.title)
                                        .font(DTFont.body1)

                                    Spacer()

                                    Text(alert.severity.label)
                                        .font(DTFont.caption1)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, DTSpacing.sm)
                                        .padding(.vertical, DTSpacing.xxs)
                                        .background(
                                            Capsule().fill(alert.severity.color)
                                        )
                                }

                                Text(alert.description)
                                    .font(DTFont.body3)
                                    .foregroundStyle(
                                        colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.45)
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
                .padding(.top, DTSpacing.sm)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
```

---

## 4. Screen-by-Screen Mockups

### 4.1 Splash Screen

**Concept:** "Unfolding sky" -- The app name emerges from a single point of light that expands into a weather gradient. The sun/cloud icon materializes with a soft particle burst, and the tagline fades in with a letter-spacing animation.

```swift
// MARK: - Redesigned Splash Screen

struct RedesignedSplashScreen: View {
    @State private var isActive = false
    @State private var phase: SplashPhase = .hidden

    enum SplashPhase {
        case hidden, icon, title, tagline, fadeOut
    }

    var body: some View {
        if isActive {
            ContentView()
        } else {
            splashContent
                .onAppear {
                    sequence()
                }
        }
    }

    private var splashContent: some View {
        ZStack {
            // Background: radial gradient expanding outward
            RadialGradient(
                colors: [
                    Color(hex: "1A56DB"),
                    Color(hex: "111827"),
                    Color(hex: "0A0A0A")
                ],
                center: .center,
                startRadius: iconVisible ? 10 : 0,
                endRadius: iconVisible ? 600 : 200
            )
            .ignoresSafeArea()
            .animation(.easeOut(duration: 1.2), value: iconVisible)

            // Ambient particles
            if phase != .hidden {
                SplashParticles()
                    .opacity(taglineVisible ? 0.6 : 0.3)
                    .animation(.easeIn(duration: 0.8), value: taglineVisible)
            }

            VStack(spacing: DTSpacing.xxl) {
                // Weather icon -- emerges from center
                ZStack {
                    // Glow ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(hex: "F59E0B").opacity(0.0),
                                    Color(hex: "F59E0B").opacity(0.6),
                                    Color(hex: "60A5FA").opacity(0.4),
                                    Color(hex: "F59E0B").opacity(0.0)
                                ],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(iconVisible ? 1.0 : 0.3)
                        .opacity(iconVisible ? 1 : 0)

                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 72))
                        .symbolRenderingMode(.multicolor)
                        .shadow(color: Color(hex: "F59E0B").opacity(0.4), radius: 20)
                        .scaleEffect(iconVisible ? 1.0 : 0.2)
                        .opacity(iconVisible ? 1 : 0)
                }
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: iconVisible)

                // Title
                VStack(spacing: DTSpacing.sm) {
                    Text("简天气")
                        .font(DTFont.display3)
                        .foregroundStyle(.white)
                        .opacity(titleVisible ? 1 : 0)
                        .offset(y: titleVisible ? 0 : 16)
                        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: titleVisible)

                    Text("实时天气  ·  智能预警")
                        .font(DTFont.body3)
                        .foregroundStyle(.white.opacity(0.6))
                        .tracking(4)
                        .opacity(taglineVisible ? 1 : 0)
                        .offset(y: taglineVisible ? 0 : 8)
                        .animation(.easeOut(duration: 0.5), value: taglineVisible)
                }
            }
        }
    }

    // Phase helpers
    private var iconVisible: Bool { phase != .hidden }
    private var titleVisible: Bool { phase == .title || phase == .tagline || phase == .fadeOut }
    private var taglineVisible: Bool { phase == .tagline || phase == .fadeOut }

    private func sequence() {
        // Icon emerges at 0.0s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            phase = .icon
        }
        // Title fades in at 0.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            phase = .title
        }
        // Tagline at 1.0s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            phase = .tagline
        }
        // Transition to main app at 2.2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                isActive = true
            }
        }
    }
}

/// Soft particle overlay for splash
struct SplashParticles: View {
    @State private var phase = 0.0

    var body: some View {
        Canvas { ctx, size in
            for i in 0..<30 {
                let x = (Double(i) * 1.618).truncatingRemainder(dividingBy: 1.0) * size.width
                let y = fmod(phase * 20 + Double(i) * 40, size.height + 40) - 20
                let radius = 1.5 + CGFloat(i % 3)

                var path = Path()
                path.addEllipse(in: CGRect(
                    x: x - radius, y: y - radius,
                    width: radius * 2, height: radius * 2
                ))
                ctx.fill(path, with: .color(.white.opacity(0.15 + Double(i % 4) * 0.05)))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}
```

### 4.2 City List (Tab 1)

**Concept:** Each city row is a compact, atmospheric card. The row uses a subtle weather-tinted gradient that feels distinct per condition. Selected state uses the primary blue as an accent line on the left edge, not a border. Search is a floating pill, not a list section.

```swift
// MARK: - Redesigned City List

struct RedesignedCityListView: View {
    @Environment(WeatherStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var listAppear = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background
                (colorScheme == .dark
                    ? Color(hex: "0A0A0A")
                    : Color(hex: "F8FAFC"))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DTSpacing.md) {
                        // Floating search pill
                        RedesignedSearchPill(
                            text: $searchText,
                            isSearching: $isSearching
                        )
                        .padding(.horizontal, DTSpacing.lg)
                        .opacity(listAppear ? 1 : 0)
                        .offset(y: listAppear ? 0 : -12)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: listAppear)

                        // Search results (when searching)
                        if !searchText.isEmpty {
                            RedesignedSearchResults(query: searchText)
                                .padding(.horizontal, DTSpacing.lg)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // "My Cities" header
                        HStack {
                            Text("我的城市")
                                .font(DTFont.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    colorScheme == .dark ? .white : .black
                                )

                            Spacer()

                            Button {
                                // Show add city sheet
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(DTColor.primaryLight)
                            }
                        }
                        .padding(.horizontal, DTSpacing.lg)
                        .padding(.top, DTSpacing.sm)
                        .opacity(listAppear ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: listAppear)

                        // City cards
                        LazyVStack(spacing: DTSpacing.sm) {
                            ForEach(Array(store.cities.enumerated()), id: \.element.id) { idx, city in
                                RedesignedCityCard(
                                    city: city,
                                    isSelected: store.selectedIndex == idx
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        store.selectedIndex = idx
                                    }
                                }
                                .padding(.horizontal, DTSpacing.lg)
                                .opacity(listAppear ? 1 : 0)
                                .offset(x: listAppear ? 0 : -24)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.8)
                                        .delay(Double(idx) * 0.06),
                                    value: listAppear
                                )
                            }
                        }

                        // Bottom padding for tab bar
                        Color.clear.frame(height: 80)
                    }
                    .padding(.top, DTSpacing.md)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("简天气")
                        .font(DTFont.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear { listAppear = true }
        }
    }
}

// MARK: - Floating Search Pill

struct RedesignedSearchPill: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: DTSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(
                    colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.3)
                )

            TextField("搜索城市...", text: $text)
                .font(DTFont.body2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(
                            colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.2)
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(DTSpacing.md)
        .background(
            Capsule()
                .fill(
                    colorScheme == .dark
                        ? Color.white.opacity(0.06)
                        : Color.black.opacity(0.04)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            colorScheme == .dark
                                ? Color.white.opacity(0.08)
                                : Color.black.opacity(0.06),
                            lineWidth: 0.5
                        )
                )
        )
    }
}

// MARK: - Redesigned City Card

struct RedesignedCityCard: View {
    let city: CityWeather
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    /// Weather-conditioned tint for the card background
    private var weatherTint: Color {
        guard let code = city.weather?.current.weather_code else {
            return colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.02)
        }
        switch code {
        case 0, 1:     return Color(hex: "F59E0B").opacity(colorScheme == .dark ? 0.08 : 0.06)
        case 2:         return Color(hex: "60A5FA").opacity(colorScheme == .dark ? 0.08 : 0.06)
        case 3:         return Color(hex: "94A3B8").opacity(colorScheme == .dark ? 0.06 : 0.04)
        case 61...65:   return Color(hex: "2563EB").opacity(colorScheme == .dark ? 0.08 : 0.06)
        case 71...77:   return Color(hex: "BAE6FD").opacity(colorScheme == .dark ? 0.06 : 0.06)
        case 95...99:   return Color(hex: "A78BFA").opacity(colorScheme == .dark ? 0.08 : 0.06)
        default:        return Color(hex: "94A3B8").opacity(colorScheme == .dark ? 0.04 : 0.03)
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DTSpacing.md) {
                // Left accent bar (selected state)
                RoundedRectangle(cornerRadius: DTRadius.full)
                    .fill(isSelected ? DTColor.primaryLight : .clear)
                    .frame(width: 3, height: 44)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)

                // City info
                VStack(alignment: .leading, spacing: DTSpacing.xxs) {
                    HStack(spacing: DTSpacing.xs) {
                        if city.isCurrentLocation {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(DTColor.primaryLight)
                        }

                        Text(city.name)
                            .font(DTFont.body1)
                            .foregroundStyle(
                                colorScheme == .dark ? .white : .black
                            )

                        if !city.alerts.isEmpty {
                            AlertCountBadge(count: city.alerts.count)
                        }
                    }

                    if let weather = city.weather {
                        Text(WeatherCode.description(for: weather.current.weather_code))
                            .font(DTFont.body3)
                            .foregroundStyle(
                                colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.4)
                            )
                    }
                }

                Spacer()

                // Temperature
                if city.isLoading {
                    ProgressView()
                        .scaleEffect(0.75)
                } else if let weather = city.weather {
                    HStack(spacing: DTSpacing.xs) {
                        Image(systemName: WeatherCode.icon(for: weather.current.weather_code))
                            .font(.system(size: 20))
                            .foregroundStyle(WeatherCode.color(for: weather.current.weather_code))

                        Text("\(Int(weather.current.temperature_2m))°")
                            .font(DTFont.data3)
                            .foregroundStyle(
                                colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.8)
                            )
                    }
                }
            }
            .padding(.horizontal, DTSpacing.lg)
            .padding(.vertical, DTSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DTRadius.lg)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DTRadius.lg)
                            .fill(weatherTint)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DTRadius.lg)
                            .stroke(
                                isSelected
                                    ? DTColor.primaryLight.opacity(0.3)
                                    : (colorScheme == .dark ? Color.white.opacity(0.06) : Color.clear),
                                lineWidth: isSelected ? 1.5 : 0.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Search Results (placeholder)

struct RedesignedSearchResults: View {
    let query: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: DTSpacing.xs) {
            // Results would be populated from search
            Text("搜索 \"\(query)\"...")
                .font(DTFont.body2)
                .foregroundStyle(
                    colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.4)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DTSpacing.md)
        }
    }
}
```

### 4.3 Weather Detail (Tab 2)

The detail page is a unified scroll composition. All sections use the shared GlassCard and TintedCard components, but differentiated by section-level styling choices.

```swift
// MARK: - Redesigned Weather Detail

struct RedesignedCityDetailView: View {
    let city: CityWeather
    let onRefresh: () async -> Void
    @State private var appear = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: DTSpacing.lg) {
                if let weather = city.weather {
                    // Hero card
                    RedesignedHeroCard(
                        weather: weather.current,
                        alertCount: city.alerts.count
                    )
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 24)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appear)

                    // Error banner
                    if let err = city.fetchError {
                        Label(err, systemImage: "wifi.exclamationmark")
                            .font(DTFont.body3)
                            .foregroundStyle(DTColor.warning)
                            .padding(DTSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: DTRadius.md)
                                    .fill(DTColor.warning.opacity(0.08))
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Alert banner
                    if !city.alerts.isEmpty {
                        RedesignedAlertBanner(alerts: city.alerts)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 16)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8).delay(0.2),
                                value: appear
                            )
                    }

                    // Hourly forecast
                    RedesignedHourlyForecast(items: hourlyItems)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8).delay(0.3),
                            value: appear
                        )

                    // Detail grid
                    RedesignedDetailGrid(weather: weather.current)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 16)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8).delay(0.4),
                            value: appear
                        )

                    // AQI / UV
                    if let aq = city.airQuality {
                        RedesignedAQIUVCard(aq: aq)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 16)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8).delay(0.5),
                                value: appear
                            )
                    }

                    // 7-day forecast
                    RedesignedForecastSection(daily: weather.daily)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8).delay(0.6),
                            value: appear
                        )

                    // Last updated
                    if let updated = city.lastUpdated {
                        Text("更新于 \(updated.formatted(.dateTime.hour().minute()))")
                            .font(DTFont.caption2)
                            .foregroundStyle(
                                colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.25)
                            )
                            .padding(.bottom, DTSpacing.lg)
                    }
                }
            }
            .padding(.horizontal, DTSpacing.lg)
            .padding(.top, DTSpacing.sm)
        }
        .background(.clear)
        .refreshable { await onRefresh() }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                appear = true
            }
        }
    }

    // Convert to hourly items for the redesigned component
    private var hourlyItems: [RedesignedHourlyForecast.HourlyItem] {
        var items: [RedesignedHourlyForecast.HourlyItem] = []
        if let current = city.weather?.current {
            items.append(.init(time: "现在", temperature: current.temperature_2m, weatherCode: current.weather_code, isNow: true))
        }
        // Add hourly items from weather data (same logic as current)
        return items
    }
}
```

### 4.4 Settings (Tab 3)

**Concept:** Custom-styled grouped sections with tinted icons, not a plain iOS List. Each section has a subtle background card.

```swift
// MARK: - Redesigned Settings

struct RedesignedSettingsView: View {
    @Environment(WeatherStore.self) private var store
    @State private var isRefreshing = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                (colorScheme == .dark
                    ? Color(hex: "0A0A0A")
                    : Color(hex: "F8FAFC"))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DTSpacing.xl) {
                        // App identity header
                        SettingsAppHeader()

                        // Data section
                        SettingsGroupCard {
                            SettingsRow(
                                icon: "arrow.clockwise",
                                iconTint: DTColor.Info,
                                title: "刷新所有城市数据",
                                trailing: .activity(isRefreshing)
                            ) {
                                Task {
                                    isRefreshing = true
                                    await store.fetchAllWeather()
                                    isRefreshing = false
                                }
                            }

                            SettingsRow(
                                icon: "building.2",
                                iconTint: Color(hex: "8B5CF6"),
                                title: "城市数量",
                                trailing: .text("\(store.cities.count)")
                            )

                            SettingsRow(
                                icon: "exclamationmark.triangle",
                                iconTint: DTColor.warning,
                                title: "有预警城市",
                                trailing: .text("\(store.cities.filter { !$0.alerts.isEmpty }.count)")
                            )
                        }
                        .labeled("数据")

                        // About section
                        SettingsGroupCard {
                            SettingsRow(
                                icon: "cloud.fill",
                                iconTint: Color(hex: "60A5FA"),
                                title: "天气数据来源",
                                trailing: .text("Open-Meteo")
                            )

                            SettingsRow(
                                icon: "info.circle",
                                iconTint: DTColor.Info,
                                title: "版本",
                                trailing: .text(
                                    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "v1.0.0"
                                )
                            )

                            SettingsRow(
                                icon: "iphone",
                                iconTint: Color(hex: "374151"),
                                title: "支持 iOS",
                                trailing: .text("iOS 16+")
                            )
                        }
                        .labeled("关于")

                        // Legend section
                        SettingsGroupCard {
                            VStack(alignment: .leading, spacing: DTSpacing.sm) {
                                Text("天气预警说明")
                                    .font(DTFont.body1)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)

                                ForEach(AlertSeverity.allCases, id: \.rawValue) { severity in
                                    HStack(spacing: DTSpacing.sm) {
                                        Circle()
                                            .fill(severity.color)
                                            .frame(width: 8, height: 8)

                                        Text(severity.label)
                                            .font(DTFont.body3)
                                            .foregroundStyle(
                                                colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.5)
                                            )
                                    }
                                }
                            }
                            .padding(.vertical, DTSpacing.xs)
                        }
                        .labeled("图例")

                        // Footer
                        Text("简天气 -- 实时天气，智能预警")
                            .font(DTFont.caption2)
                            .foregroundStyle(
                                colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)
                            )
                            .padding(.top, DTSpacing.xxxl)
                    }
                    .padding(.horizontal, DTSpacing.lg)
                    .padding(.top, DTSpacing.lg)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("设置")
                        .font(DTFont.title1)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Settings Components

struct SettingsAppHeader: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: DTSpacing.md) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 48))
                .symbolRenderingMode(.multicolor)

            Text("简天气")
                .font(DTFont.title1)
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DTSpacing.xxl)
    }
}

struct SettingsGroupCard<Content: View>: View {
    let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(DTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DTRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DTRadius.xl)
                        .stroke(
                            colorScheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.5),
                            lineWidth: 0.5
                        )
                )
        )
    }
}

enum SettingsTrailing {
    case text(String)
    case activity(Bool)
}

struct SettingsRow: View {
    let icon: String
    let iconTint: Color
    let title: String
    let trailing: SettingsTrailing
    let action: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    init(
        icon: String,
        iconTint: Color,
        title: String,
        trailing: SettingsTrailing,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.trailing = trailing
        self.action = action
    }

    var body: some View {
        Group {
            if action != nil {
                Button(action: { action?() }) {
                    rowContent
                }
                .buttonStyle(.plain)
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: DTSpacing.md) {
            // Tinted icon
            ZStack {
                Circle()
                    .fill(iconTint.opacity(0.12))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(iconTint)
            }

            // Title
            Text(title)
                .font(DTFont.body1)
                .foregroundStyle(colorScheme == .dark ? .white : .black)

            Spacer()

            // Trailing
            switch trailing {
            case .text(let text):
                Text(text)
                    .font(DTFont.body3)
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

// MARK: - Section Label Modifier

extension View {
    func labeled(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: DTSpacing.xs) {
            Text(title.uppercased())
                .font(DTFont.caption1)
                .fontWeight(.semibold)
                .foregroundStyle(
                    Color(hex: "6B7280")
                )
                .tracking(1)

            self
        }
    }
}
```

### 4.5 Tab Bar

The tab bar uses a custom floating design with a glass material background and reduced opacity when scrolling.

```swift
// MARK: - Redesigned Tab Bar Container

struct RedesignedTabContainer: View {
    @Environment(WeatherStore.self) private var store
    @State private var selectedTab = 0
    @Environment(\.colorScheme) private var colorScheme

    private var alertBadge: Int {
        store.selectedCity?.alerts.filter { $0.severity == .high || $0.severity == .extreme }.count ?? 0
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                CityListView()
                    .tag(0)

                CityDetailView()
                    .tag(1)

                SettingsView()
                    .tag(2)
            }

            // Custom floating tab bar
            HStack(spacing: 0) {
                TabBarItem(
                    icon: "list.bullet",
                    label: "城市",
                    isSelected: selectedTab == 0
                ) { selectedTab = 0 }

                TabBarItem(
                    icon: "cloud.sun.fill",
                    label: "详情",
                    badge: alertBadge,
                    isSelected: selectedTab == 1
                ) { selectedTab = 1 }

                TabBarItem(
                    icon: "gearshape.fill",
                    label: "设置",
                    isSelected: selectedTab == 2
                ) { selectedTab = 2 }
            }
            .padding(.horizontal, DTSpacing.xl)
            .padding(.vertical, DTSpacing.sm)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.4),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
                        radius: 16, x: 0, y: 4
                    )
            )
            .padding(.bottom, 4)
            // Hide default tab bar
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    var badge: Int = 0
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: DTSpacing.xxs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected
                                ? DTColor.primaryLight
                                : (colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                        )
                        .symbolEffect(.bounce, value: isSelected)

                    if badge > 0 {
                        Circle()
                            .fill(DTColor.error)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Text("\(badge)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .offset(x: 8, y: -4)
                    }
                }

                Text(label)
                    .font(DTFont.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(
                        isSelected
                            ? DTColor.primaryLight
                            : (colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
```

---

## 5. Atmospheric Background System

The redesigned background system uses a full-screen gradient that shifts color temperature based on weather conditions, plus a subtle ambient particle layer that varies in density.

```swift
// MARK: - Redesigned Atmospheric Background

struct RedesignedAtmosphericBackground: View {
    let weatherCode: Int?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Base gradient
            baseGradient
                .ignoresSafeArea()

            // Ambient particles (density varies by condition)
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

    @ViewBuilder
    private var baseGradient: some View {
        let isDark = colorScheme == .dark

        if let code = weatherCode {
            switch code {
            case 0, 1:   // Clear
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "0A0F1A"), Color(hex: "111827")]
                        : [Color(hex: "FFFBEB"), Color(hex: "FFF7ED"), Color(hex: "FEF3C7")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case 2:       // Partly cloudy
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "0A0F1A"), Color(hex: "0F172A")]
                        : [Color(hex: "EFF6FF"), Color(hex: "F8FAFC")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case 3:       // Overcast
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "0A0A0F"), Color(hex: "111115")]
                        : [Color(hex: "F1F5F9"), Color(hex: "F8FAFC")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case 61...65, 80...82:   // Rain
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "050810"), Color(hex: "0A1020")]
                        : [Color(hex: "E2E8F0"), Color(hex: "F1F5F9")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case 71...77, 85, 86:    // Snow
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "0A0F18"), Color(hex: "111827")]
                        : [Color(hex: "F0F9FF"), Color(hex: "FAFBFC")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case 95...99: // Thunderstorm
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "050508"), Color(hex: "0A0A1A")]
                        : [Color(hex: "E8E0F0"), Color(hex: "F1F0F5")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            default:
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "0A0A0A"), Color(hex: "141414")]
                        : [Color(hex: "FAFAFA"), Color(hex: "FFFFFF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            LinearGradient(
                colors: isDark
                    ? [Color(hex: "0A0A0A"), Color(hex: "141414")]
                    : [Color(hex: "FAFAFA"), Color(hex: "FFFFFF")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

/// Subtle ambient particles that shift density based on weather
struct AmbientParticleLayer: View {
    let weatherCode: Int
    @State private var phase = 0.0

    /// Number of particles based on condition
    private var particleCount: Int {
        switch weatherCode {
        case 0, 1:      return 15   // sparse, warm
        case 61...65:    return 40   // dense, falling
        case 71...77:    return 35   // dense, drifting
        case 95...99:    return 50   // very dense
        default:         return 20
        }
    }

    var body: some View {
        Canvas { ctx, size in
            for i in 0..<particleCount {
                let x = (Double(i) * 1.618).truncatingRemainder(dividingBy: 1.0) * size.width
                let speed = Double(weatherCode >= 61 && weatherCode <= 82 ? 800 : 1500)
                let y = fmod(phase * speed + Double(i) * 25, size.height + 40) - 20

                let radius: CGFloat = 1 + CGFloat(i % 3)
                let alpha = 0.05 + Double(i % 5) * 0.02

                var path = Path()
                path.addEllipse(in: CGRect(
                    x: x - radius, y: y - radius,
                    width: radius * 2, height: radius * 2
                ))
                ctx.fill(path, with: .color(.white.opacity(alpha)))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}
```

---

## 6. Animation Tokens

```swift
// MARK: - Design Tokens: Animation

enum DTAnimation {
    /// Standard spring for most transitions
    static let standardSpring = Animation.spring(response: 0.4, dampingFraction: 0.82)

    /// Gentle spring for page-level transitions
    static let gentleSpring = Animation.spring(response: 0.6, dampingFraction: 0.85)

    /// Snappy spring for button taps and toggles
    static let snappySpring = Animation.spring(response: 0.25, dampingFraction: 0.8)

    /// Stagger delay between list items (seconds)
    static func staggerDelay(index: Int) -> Double {
        return Double(index) * 0.05
    }

    /// Stagger delay for grid items (slower)
    static func gridStaggerDelay(index: Int) -> Double {
        return Double(index) * 0.08
    }
}
```

---

## 7. Design-to-Implementation Mapping

### Summary of Key Changes from Current to New Design

| Aspect | Current | New |
|--------|---------|-----|
| **Card material** | Uniform `.ultraThinMaterial` everywhere | Three styles: GlassCard (frosted), TintedCard (semantic), InsetRow (minimal) |
| **Corner radius** | Fixed 24pt on all cards | Tokenized: xs(4) through xxxl(32) per container type |
| **Card borders** | White 0.15-0.2 stroke on every card | 0.5pt subtle strokes, or no border; selected state uses accent line |
| **Shadows** | Dual heavy shadows on all cards | Minimal; only hero card uses shadow; depth via material opacity |
| **Typography** | System fonts, scattered sizes | Named scale: display/title/body/label/data with Chinese-optimized weights |
| **Color system** | Ad-hoc RGB values, generic blues | Semantic tokens: primary, semantic, atmospheric tints, weather accents |
| **City list rows** | Complex weather backgrounds with particle effects | Clean glass material + weather-tinted overlay; left accent bar for selection |
| **Search** | Inline list section | Floating pill above the list |
| **Detail grid** | 2x2 uniform grid inside a glass card | Tinted cells with per-metric semantic colors inside a glass card |
| **AQI/UV** | Circular gauges with heavy gradients | Clean arc gauges with thin strokes + horizontal pollutant bars |
| **7-day forecast** | Full-width card, gradient temp bars | Streamlined: icon inline, thinner gradient bars with global min/max normalization |
| **Settings** | Plain iOS List | Custom grouped cards with tinted icon circles |
| **Tab bar** | Default iOS TabView | Custom floating glass capsule |
| **Background** | Weather animations overlay on gradient | Atmospheric gradient + subtle ambient particles (much lighter weight) |
| **Splash** | Gradient + icon + text | "Unfolding sky" phased animation with radial gradient expansion |

### Performance Considerations

1. **Ambient particles use `Canvas`** -- single draw call, no view hierarchy overhead
2. **Weather effects reduced** -- city list rows no longer run full particle systems; only the detail page background runs ambient particles
3. **Material usage** -- `.ultraThinMaterial` is retained but used more selectively; cells within cards use flat color fills (no blur)
4. **Animation staggering** -- delays are kept to 50ms increments, never exceeding 0.6s total cascade time
5. **Symbol effects** -- SF Symbol `.bounce` and `.pulse` are used instead of custom animation loops where possible

### Accessibility Notes

1. All color-only indicators have text labels alongside them (AQI level text, severity labels)
2. Minimum touch target of 44pt maintained on all interactive elements
3. Dynamic type support: font tokens should be wrapped in `FontMetrics` scaling for user-adjusted sizes
4. Contrast ratios: primary text meets WCAG AA (4.5:1 minimum) against card backgrounds in both modes
5. Reduce Motion: all continuous animations should check `@Environment(\.accessibilityReduceMotion)` and disable particle/continuous effects
