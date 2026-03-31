import SwiftUI

// MARK: - Weather Background System
struct WeatherBackground {
    // 天气状况对应的渐变背景
    static func gradient(for weatherCode: Int, isDark: Bool) -> LinearGradient {
        let colors = colors(for: weatherCode, isDark: isDark)
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // 天气状况对应的颜色
    static func colors(for weatherCode: Int, isDark: Bool) -> [Color] {
        switch weatherCode {
        case 0: // 晴朗
            return isDark 
                ? [Color(red: 0.15, green: 0.20, blue: 0.40), Color(red: 0.05, green: 0.08, blue: 0.15)]
                : [Color(red: 0.40, green: 0.70, blue: 1.00), Color(red: 0.70, green: 0.85, blue: 1.00)]
        case 1, 2, 3: // 多云
            return isDark
                ? [Color(red: 0.20, green: 0.25, blue: 0.35), Color(red: 0.10, green: 0.12, blue: 0.18)]
                : [Color(red: 0.55, green: 0.65, blue: 0.75), Color(red: 0.75, green: 0.82, blue: 0.90)]
        case 45, 48: // 雾
            return isDark
                ? [Color(red: 0.25, green: 0.25, blue: 0.30), Color(red: 0.15, green: 0.15, blue: 0.18)]
                : [Color(red: 0.70, green: 0.72, blue: 0.75), Color(red: 0.85, green: 0.86, blue: 0.88)]
        case 51, 53, 55, 61, 63, 65, 80, 81, 82: // 雨/阵雨
            return isDark
                ? [Color(red: 0.15, green: 0.18, blue: 0.28), Color(red: 0.08, green: 0.10, blue: 0.15)]
                : [Color(red: 0.35, green: 0.45, blue: 0.55), Color(red: 0.55, green: 0.65, blue: 0.75)]
        case 71, 73, 75: // 雪
            return isDark
                ? [Color(red: 0.20, green: 0.25, blue: 0.35), Color(red: 0.12, green: 0.15, blue: 0.22)]
                : [Color(red: 0.65, green: 0.75, blue: 0.85), Color(red: 0.85, green: 0.90, blue: 0.95)]
        case 95, 96, 99: // 雷雨
            return isDark
                ? [Color(red: 0.12, green: 0.10, blue: 0.20), Color(red: 0.05, green: 0.04, blue: 0.08)]
                : [Color(red: 0.25, green: 0.20, blue: 0.35), Color(red: 0.40, green: 0.35, blue: 0.50)]
        default:
            return isDark
                ? [Color(red: 0.15, green: 0.15, blue: 0.20), Color(red: 0.08, green: 0.08, blue: 0.10)]
                : [Color(red: 0.60, green: 0.65, blue: 0.70), Color(red: 0.80, green: 0.83, blue: 0.86)]
        }
    }
    
    // 天气状况对应的主色调
    static func accentColor(for weatherCode: Int) -> Color {
        switch weatherCode {
        case 0: return .yellow
        case 1, 2, 3: return .orange
        case 45, 48: return .gray
        case 51, 53, 55, 61, 63, 65, 80, 81, 82: return .blue
        case 71, 73, 75: return .cyan
        case 95, 96, 99: return .purple
        default: return .gray
        }
    }
}

// MARK: - Weather Animation Effects
struct WeatherAnimationView: View {
    let weatherCode: Int
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // 根据天气状况显示不同的动画效果
            switch weatherCode {
            case 0: // 晴朗 - 阳光脉动
                SunPulseEffect()
            case 1, 2, 3: // 多云 - 云朵飘动
                CloudDriftEffect()
            case 51, 53, 55, 61, 63, 65, 80, 81, 82: // 雨 - 雨滴下落
                RainDropEffect()
            case 71, 73, 75: // 雪 - 雪花飘落
                SnowFlakeEffect()
            case 95, 96, 99: // 雷雨 - 闪电效果
                LightningEffect()
            default:
                EmptyView()
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Sun Pulse Effect (晴朗)
struct SunPulseEffect: View {
    @State private var scale = 1.0
    @State private var opacity = 0.3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(opacity))
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.3
                opacity = 0.1
            }
        }
    }
}

// MARK: - Cloud Drift Effect (多云)
struct CloudDriftEffect: View {
    @State private var offsetX: CGFloat = -100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 云朵1
                CloudShape()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 120, height: 60)
                    .position(x: offsetX + 150, y: geometry.size.height * 0.15)
                
                // 云朵2
                CloudShape()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 100, height: 50)
                    .position(x: offsetX + 300, y: geometry.size.height * 0.25)
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 20.0)
                .repeatForever(autoreverses: false)
            ) {
                offsetX = 200
            }
        }
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // 简单的云朵形状
        path.addEllipse(in: CGRect(x: width * 0.2, y: height * 0.3, width: width * 0.3, height: height * 0.5))
        path.addEllipse(in: CGRect(x: width * 0.4, y: height * 0.1, width: width * 0.4, height: height * 0.7))
        path.addEllipse(in: CGRect(x: width * 0.6, y: height * 0.3, width: width * 0.3, height: height * 0.5))
        
        return path
    }
}

// MARK: - Rain Drop Effect (雨)
struct RainDropEffect: View {
    @State private var drops: [(id: UUID, x: CGFloat, y: CGFloat, speed: Double)] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(drops, id: \.id) { drop in
                    RainDropShape()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: 2, height: 15)
                        .position(x: drop.x, y: drop.y)
                }
            }
            .onAppear {
                // 创建雨滴
                for _ in 0..<30 {
                    drops.append((
                        id: UUID(),
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: -50...geometry.size.height),
                        speed: Double.random(in: 1.5...3.0)
                    ))
                }
                
                // 动画雨滴
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    for i in drops.indices {
                        drops[i].y += drops[i].speed * 5
                        if drops[i].y > geometry.size.height + 20 {
                            drops[i].y = -20
                            drops[i].x = CGFloat.random(in: 0...geometry.size.width)
                        }
                    }
                }
            }
        }
    }
}

struct RainDropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.midY)
        )
        return path
    }
}

// MARK: - Snow Flake Effect (雪)
struct SnowFlakeEffect: View {
    @State private var flakes: [(id: UUID, x: CGFloat, y: CGFloat, speed: Double, size: CGFloat, drift: CGFloat)] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(flakes, id: \.id) { flake in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: flake.size, height: flake.size)
                        .position(x: flake.x, y: flake.y)
                }
            }
            .onAppear {
                // 创建雪花
                for _ in 0..<25 {
                    flakes.append((
                        id: UUID(),
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: -50...geometry.size.height),
                        speed: Double.random(in: 0.8...1.8),
                        size: CGFloat.random(in: 3...8),
                        drift: CGFloat.random(in: -0.5...0.5)
                    ))
                }
                
                // 动画雪花
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    for i in flakes.indices {
                        flakes[i].y += flakes[i].speed * 2
                        flakes[i].x += flakes[i].drift
                        if flakes[i].y > geometry.size.height + 20 {
                            flakes[i].y = -20
                            flakes[i].x = CGFloat.random(in: 0...geometry.size.width)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Lightning Effect (雷雨)
struct LightningEffect: View {
    @State private var showLightning = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showLightning {
                    LightningShape()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 100, height: geometry.size.height * 0.6)
                        .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.3)
                    
                    LightningShape()
                        .fill(Color.yellow.opacity(0.7))
                        .frame(width: 80, height: geometry.size.height * 0.5)
                        .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.25)
                }
            }
        }
        .onAppear {
            // 随机闪电效果
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 3...6), repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    showLightning = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        showLightning = false
                    }
                }
            }
        }
    }
}

struct LightningShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: rect.minY))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.3))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.35))
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.65))
        path.addLine(to: CGPoint(x: width * 0.4, y: rect.maxY))
        
        return path
    }
}
