import SwiftUI

// MARK: - Weather Background View
struct WeatherBackgroundView: View {
    let weatherCode: Int?
    @State private var animationPhase = 0.0
    
    var body: some View {
        ZStack {
            // 基础背景色
            backgroundColor
                .ignoresSafeArea()
            
            // 天气动画层
            if let code = weatherCode {
                weatherAnimation(for: code)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
    }
    
    // MARK: - Background Color
    private var backgroundColor: some View {
        Group {
            if let code = weatherCode {
                switch code {
                case 0, 1: // 晴朗/主要晴朗
                    LinearGradient(
                        colors: [Color(hex: "#87CEEB"), Color(hex: "#E0F6FF")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 2: // 部分多云
                    LinearGradient(
                        colors: [Color(hex: "#B0C4DE"), Color(hex: "#E8F0F8")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 3: // 多云
                    LinearGradient(
                        colors: [Color(hex: "#708090"), Color(hex: "#A8B8C8")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 45, 48: // 雾/雾凇
                    LinearGradient(
                        colors: [Color(hex: "#D3D3D3"), Color(hex: "#F0F0F0")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 51, 53, 55, 56, 57: // 毛毛雨/冻毛毛雨
                    LinearGradient(
                        colors: [Color(hex: "#5F9EA0"), Color(hex: "#B0C4DE")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 61, 63, 65, 66, 67: // 雨/冻雨
                    LinearGradient(
                        colors: [Color(hex: "#4682B4"), Color(hex: "#708090")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 71, 73, 75, 77: // 雪/雪粒
                    LinearGradient(
                        colors: [Color(hex: "#B0E0E6"), Color(hex: "#F0F8FF")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 80, 81, 82: // 阵雨
                    LinearGradient(
                        colors: [Color(hex: "#4169E1"), Color(hex: "#6495ED")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 85, 86: // 阵雪
                    LinearGradient(
                        colors: [Color(hex: "#87CEFA"), Color(hex: "#E0F6FF")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 95, 96, 99: // 雷雨
                    LinearGradient(
                        colors: [Color(hex: "#2F4F4F"), Color(hex: "#4A5568")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                default:
                    LinearGradient(
                        colors: [Color(hex: "#87CEEB"), Color(hex: "#E0F6FF")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            } else {
                LinearGradient(
                    colors: [Color(hex: "#87CEEB"), Color(hex: "#E0F6FF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
    
    // MARK: - Weather Animation
    @ViewBuilder
    private func weatherAnimation(for code: Int) -> some View {
        switch code {
        case 0, 1: // 晴朗 - 阳光射线 + 飘动云朵
            ZStack {
                SunRaysView(phase: animationPhase)
                FloatingCloudsView(phase: animationPhase, density: .low)
            }
        case 2: // 部分多云 - 更多云朵
            FloatingCloudsView(phase: animationPhase, density: .medium)
        case 3: // 多云 - 密集灰色云朵
            ZStack {
                FloatingCloudsView(phase: animationPhase, density: .high)
                    .opacity(0.8)
            }
        case 45, 48: // 雾 - 雾气弥漫
            FogView(phase: animationPhase)
        case 51, 53, 55, 56, 57: // 毛毛雨 - 细雨
            RainView(phase: animationPhase, intensity: .light)
        case 61, 63, 65, 66, 67: // 雨 - 中雨
            RainView(phase: animationPhase, intensity: .medium)
        case 71, 73, 75, 77: // 雪 - 雪花
            SnowView(phase: animationPhase, intensity: .medium)
        case 80, 81, 82: // 阵雨 - 大雨
            RainView(phase: animationPhase, intensity: .heavy)
        case 85, 86: // 阵雪 - 大雪
            SnowView(phase: animationPhase, intensity: .heavy)
        case 95, 96, 99: // 雷雨 - 闪电 + 雨
            ZStack {
                RainView(phase: animationPhase, intensity: .heavy)
                LightningView(phase: animationPhase)
            }
        default:
            FloatingCloudsView(phase: animationPhase, density: .low)
        }
    }
}

// MARK: - Sun Rays View
struct SunRaysView: View {
    let phase: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<8) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.3),
                                    Color.yellow.opacity(0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: geometry.size.height * 0.6)
                        .position(
                            x: geometry.size.width * 0.7 + cos(Double(i) * .pi / 4 + phase * .pi * 2) * 20,
                            y: geometry.size.height * 0.2
                        )
                        .rotationEffect(.degrees(Double(i) * 45 + phase * 10))
                }
            }
        }
    }
}

// MARK: - Floating Clouds View
struct FloatingCloudsView: View {
    let phase: Double
    let density: CloudDensity
    
    enum CloudDensity {
        case low, medium, high
        
        var count: Int {
            switch self {
            case .low: return 3
            case .medium: return 5
            case .high: return 8
            }
        }
        
        var opacity: Double {
            switch self {
            case .low: return 0.6
            case .medium: return 0.7
            case .high: return 0.85
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<density.count, id: \.self) { i in
                    CloudShape()
                        .fill(Color.white.opacity(density.opacity))
                        .frame(width: 120 + Double(i * 20), height: 60 + Double(i * 10))
                        .offset(
                            x: sin(phase * .pi * 2 + Double(i)) * 50 + Double(i * 30) - 100,
                            y: cos(phase * .pi * 2 + Double(i) * 0.5) * 20 + Double(i * 40)
                        )
                        .position(
                            x: geometry.size.width * (0.2 + Double(i) * 0.15),
                            y: geometry.size.height * (0.15 + Double(i % 3) * 0.1)
                        )
                }
            }
        }
    }
}

// MARK: - Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // 简化的云朵形状
        path.addEllipse(in: CGRect(x: 0, y: height * 0.3, width: width * 0.5, height: height * 0.7))
        path.addEllipse(in: CGRect(x: width * 0.25, y: 0, width: width * 0.5, height: height * 0.8))
        path.addEllipse(in: CGRect(x: width * 0.5, y: height * 0.2, width: width * 0.5, height: height * 0.6))
        
        return path
    }
}

// MARK: - Fog View
struct FogView: View {
    let phase: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<5) { i in
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.white.opacity(0.3 + Double(i) * 0.05))
                        .frame(height: 80 + Double(i) * 20)
                        .offset(x: sin(phase * .pi * 2 + Double(i)) * 100)
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height * (0.3 + Double(i) * 0.15)
                        )
                }
            }
        }
    }
}

// MARK: - Rain View
struct RainView: View {
    let phase: Double
    let intensity: RainIntensity
    
    enum RainIntensity {
        case light, medium, heavy
        
        var dropCount: Int {
            switch self {
            case .light: return 30
            case .medium: return 60
            case .heavy: return 100
            }
        }
        
        var speed: Double {
            switch self {
            case .light: return 0.5
            case .medium: return 1.0
            case .heavy: return 1.5
            }
        }
        
        var length: CGFloat {
            switch self {
            case .light: return 15
            case .medium: return 20
            case .heavy: return 25
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<intensity.dropCount, id: \.self) { i in
                    RainDrop(
                        x: Double.random(in: 0...1),
                        delay: Double.random(in: 0...2),
                        speed: intensity.speed
                    )
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    .frame(width: 2, height: intensity.length)
                    .position(
                        x: geometry.size.width * CGFloat(Double.random(in: 0...1)),
                        y: CGFloat(fmod(phase * intensity.speed * 1000 + Double(i) * 20, Double(geometry.size.height + 100)))
                    )
                }
            }
        }
    }
}

// MARK: - Rain Drop
struct RainDrop: View {
    let x: Double
    let delay: Double
    let speed: Double
    
    var body: some View {
        Capsule()
            .fill(Color.white.opacity(0.6))
    }
}

// MARK: - Snow View
struct SnowView: View {
    let phase: Double
    let intensity: SnowIntensity
    
    enum SnowIntensity {
        case medium, heavy
        
        var flakeCount: Int {
            switch self {
            case .medium: return 40
            case .heavy: return 80
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<intensity.flakeCount, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 4 + CGFloat.random(in: 0...4))
                        .position(
                            x: CGFloat(fmod(phase * 50 + Double(i) * 30, Double(geometry.size.width))),
                            y: CGFloat(fmod(phase * 30 + Double(i) * 25, Double(geometry.size.height + 50)))
                        )
                        .offset(
                            x: sin(phase * .pi * 2 + Double(i)) * 30,
                            y: 0
                        )
                }
            }
        }
    }
}

// MARK: - Lightning View
struct LightningView: View {
    let phase: Double
    @State private var flashOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 闪电形状
                LightningShape()
                    .fill(Color.yellow.opacity(flashOpacity))
                    .frame(width: 60, height: 200)
                    .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.3)
                
                // 屏幕闪光效果
                Color.white.opacity(flashOpacity * 0.3)
                    .ignoresSafeArea()
            }
            .onAppear {
                startLightningAnimation()
            }
            .onChange(of: phase) { _ in
                if Int.random(in: 0...100) < 5 { // 5% 概率触发闪电
                    triggerFlash()
                }
            }
        }
    }
    
    private func startLightningAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            if Int.random(in: 0...100) < 30 { // 30% 概率每3秒
                triggerFlash()
            }
        }
    }
    
    private func triggerFlash() {
        withAnimation(.easeOut(duration: 0.1)) {
            flashOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeIn(duration: 0.2)) {
                flashOpacity = 0.0
            }
        }
    }
}

// MARK: - Lightning Shape
struct LightningShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.4))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.4))
        path.addLine(to: CGPoint(x: w * 0.4, y: h))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.5))
        path.closeSubpath()
        
        return path
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