import SwiftUI

// MARK: - SplashPhase
/// Animation phases for the "Unfolding Sky" splash sequence.
enum SplashPhase {
    case hidden, icon, title, tagline, fadeOut
}

// MARK: - SplashScreenView
struct SplashScreenView: View {
    @State private var isActive = false
    @State private var phase: SplashPhase = .hidden

    // MARK: Phase Helpers

    private var iconVisible: Bool { phase != .hidden }
    private var titleVisible: Bool { phase == .title || phase == .tagline || phase == .fadeOut }
    private var taglineVisible: Bool { phase == .tagline || phase == .fadeOut }

    // MARK: Body

    var body: some View {
        if isActive {
            ContentView()
        } else {
            splashContent
                .onAppear { sequence() }
        }
    }

    // MARK: Splash Content

    private var splashContent: some View {
        ZStack {
            // Layer 1: Expanding radial gradient background
            backgroundGradient

            // Layer 2: Drifting particles
            SplashParticles()

            // Layer 3: Center content
            centerContent
        }
    }

    // MARK: Background

    private var backgroundGradient: some View {
        RadialGradient(
            colors: [
                Color(hex: "1A56DB"),
                Color(hex: "111827"),
                Color(hex: "0A0A0A"),
            ],
            center: .center,
            startRadius: iconVisible ? 10 : 0,
            endRadius: iconVisible ? 600 : 200
        )
        .ignoresSafeArea()
        .animation(.easeOut(duration: 1.2), value: iconVisible)
    }

    // MARK: Center Content

    private var centerContent: some View {
        VStack(spacing: DTSpacing.xxl) {
            iconArea
            titleArea
        }
    }

    // MARK: Icon Area

    private var iconArea: some View {
        ZStack {
            // Glow ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            DTColor.Semantic.warning.opacity(0),
                            DTColor.Semantic.warning.opacity(0.6),
                            DTColor.Brand.primaryLight.opacity(0.4),
                            DTColor.Semantic.warning.opacity(0),
                        ],
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: 120, height: 120)
                .scaleEffect(iconVisible ? 1.0 : 0.3)
                .opacity(iconVisible ? 1 : 0)

            // Weather icon
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 72))
                .symbolRenderingMode(.multicolor)
                .shadow(color: DTColor.Semantic.warning.opacity(0.4), radius: 20)
                .scaleEffect(iconVisible ? 1.0 : 0.2)
                .opacity(iconVisible ? 1 : 0)
        }
        .animation(DTAnimation.gentleSpring, value: iconVisible)
    }

    // MARK: Title Area

    private var titleArea: some View {
        VStack(spacing: DTSpacing.sm) {
            // Main title: "简天气"
            Text("简天气")
                .font(DTFont.display3.font)
                .foregroundStyle(.white)
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : 16)
                .animation(.easeOut(duration: 0.5), value: titleVisible)

            // Tagline
            Text("实时天气  ·  智能预警")
                .font(DTFont.body3.font)
                .foregroundStyle(.white.opacity(0.6))
                .tracking(4)
                .opacity(taglineVisible ? 1 : 0)
                .offset(y: taglineVisible ? 0 : 8)
                .animation(.easeOut(duration: 0.4), value: taglineVisible)
        }
    }

    // MARK: Animation Sequence

    private func sequence() {
        // Icon appears at 0.1s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            phase = .icon
        }
        // Title appears at 0.6s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            phase = .title
        }
        // Tagline appears at 1.1s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            phase = .tagline
        }
        // Transition to ContentView at 2.2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                isActive = true
            }
        }
    }
}

// MARK: - SplashParticles
/// Canvas-based particle system: 30 soft dots drifting upward with
/// golden-ratio x-distribution for natural spacing.
private struct SplashParticles: View {
    @State private var phase = 0.0

    var body: some View {
        Canvas { context, size in
            let goldenRatio: Double = 0.618033988749895
            let particleCount = 30

            for i in 0..<particleCount {
                // Golden-ratio distributed x positions
                let xFrac = Double(i) * goldenRatio
                let xFracNorm = xFrac.truncatingRemainder(dividingBy: 1.0)
                let x = xFracNorm * Double(size.width)

                // Vertical position: continuous upward drift using phase
                let yBase = Double(i) * (Double(size.height) / Double(particleCount))
                let yOffset = phase * Double(size.height) * 0.3
                var y = (yBase + yOffset).truncatingRemainder(dividingBy: Double(size.height + 20))
                // Wrap around so particles that drift past the top reappear at the bottom
                if y < -10 {
                    y += Double(size.height + 20)
                }

                // Particle size: 1-3pt based on index
                let particleSize: Double = 1.0 + Double(i % 3)

                // Particle opacity: 0.05-0.15
                let opacity: Double = 0.05 + (Double(i % 11) / 10.0) * 0.10

                let rect = CGRect(
                    x: x - particleSize / 2,
                    y: y - particleSize / 2,
                    width: particleSize,
                    height: particleSize
                )
                context.opacity = opacity
                context.fill(Circle().path(in: rect), with: .color(.white))
            }
        }
        .allowsHitTesting(false)
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
