import SwiftUI

// MARK: - 优化版天气动画组件
// 性能改进：使用 Canvas 替代多 View 渲染

// MARK: - 优化版雨天动画
struct OptimizedRainView: View {
    let intensity: RainIntensity
    @State private var phase: Double = 0
    
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
        Canvas { context, size in
            let dropCount = intensity.dropCount
            
            for i in 0..<dropCount {
                // 使用黄金比例伪随机分布，看起来更自然
                let x = (Double(i) * 1.618).truncatingRemainder(dividingBy: 1.0) * size.width
                let y = fmod(
                    phase * intensity.speed * 800 + Double(i) * 30,
                    size.height + 100
                ) - 50
                
                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x, y: y + intensity.length))
                
                context.stroke(
                    path,
                    with: .color(.white.opacity(0.6)),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - 优化版雪天动画
struct OptimizedSnowView: View {
    let intensity: SnowIntensity
    @State private var phase: Double = 0
    
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
        Canvas { context, size in
            for i in 0..<intensity.flakeCount {
                let x = fmod(phase * 50 + Double(i) * 30, size.width)
                let y = fmod(phase * 30 + Double(i) * 25, size.height + 50) - 25
                let xOffset = sin(phase * .pi * 2 + Double(i)) * 30
                
                let flakeSize = 4 + CGFloat.random(in: 0...4)
                
                var circle = Path()
                circle.addEllipse(in: CGRect(
                    x: x + xOffset - flakeSize/2,
                    y: y - flakeSize/2,
                    width: flakeSize,
                    height: flakeSize
                ))
                
                context.fill(circle, with: .color(.white.opacity(0.8)))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - 改进版闪电动画（无内存泄漏）
struct ImprovedLightningView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            Canvas { ctx, size in
                let time = timeline.date.timeIntervalSince1970
                let randomSeed = time.truncatingRemainder(dividingBy: 100)
                
                // 使用更自然的随机触发方式
                let flashIntensity = Self.lightningIntensity(at: randomSeed)
                
                guard flashIntensity > 0 else { return }
                
                // 屏幕闪光效果
                ctx.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(.white.opacity(flashIntensity * 0.3))
                )
                
                // 绘制闪电
                let lightningPath = Self.generateLightningPath(
                    in: size,
                    seed: randomSeed
                )
                
                ctx.stroke(
                    lightningPath,
                    with: .color(.yellow.opacity(flashIntensity)),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
                
                ctx.fill(
                    lightningPath,
                    with: .color(.yellow.opacity(flashIntensity * 0.4))
                )
            }
        }
    }
    
    private static func lightningIntensity(at time: Double) -> Double {
        // 多个正弦波叠加，产生更自然的闪烁
        let wave1 = sin(time * 3)
        let wave2 = sin(time * 5 + 1.5)
        let combined = (wave1 + wave2) / 2
        
        return max(0, combined) > 0.7 ? max(0, combined) : 0
    }
    
    private static func generateLightningPath(in size: CGSize, seed: Double) -> Path {
        var path = Path()
        
        let startX = size.width * (0.6 + sin(seed) * 0.1)
        let startY = size.height * 0.1
        
        path.move(to: CGPoint(x: startX, y: startY))
        
        var currentX = startX
        let segments = 6
        
        for i in 0..<segments {
            let progress = Double(i + 1) / Double(segments)
            let nextY = startY + progress * size.height * 0.6
            let nextX = currentX + (sin(seed + Double(i)) * 30 - 10)
            
            path.addLine(to: CGPoint(x: nextX, y: nextY))
            
            // 随机添加分支
            if i % 2 == 0 && sin(seed + Double(i) * 2) > 0 {
                let branchEndX = nextX + 20
                let branchEndY = nextY + 30
                path.move(to: CGPoint(x: nextX, y: nextY))
                path.addLine(to: CGPoint(x: branchEndX, y: branchEndY))
                path.move(to: CGPoint(x: nextX, y: nextY))
            }
            
            currentX = nextX
        }
        
        return path
    }
}

// MARK: - 天气加载动画
struct WeatherLoadingView: View {
    @State private var rotation = 0.0
    @State private var scale = 0.8
    @State private var iconPhase = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // 旋转外环
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [.blue, .cyan, .teal, .mint, .blue],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(rotation))
                
                // 脉冲内环
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    .frame(width: 55, height: 55)
                    .scaleEffect(1 + iconPhase * 0.3)
                    .opacity(1 - iconPhase)
                
                // 中心天气图标
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 36))
                    .symbolRenderingMode(.multicolor)
                    .scaleEffect(scale)
            }
            
            VStack(spacing: 8) {
                Text("正在获取天气数据...")
                    .font(.headline)
                
                Text("请稍候")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            withAnimation(.spring(duration: 0.8).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
            
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                iconPhase = 1
            }
        }
    }
}

// MARK: - 动态天气图标
struct DynamicWeatherIcon: View {
    let weatherCode: Int
    @State private var phase = 0.0
    
    var body: some View {
        ZStack {
            switch weatherCode {
            case 0, 1:
                AnimatedSunIcon(phase: phase)
            case 2:
                Image(systemName: WeatherCode.icon(for: weatherCode))
                    .font(.system(size: 64))
                    .symbolRenderingMode(.multicolor)
                    .symbolEffect(.bounce, options: .repeating, value: phase)
            case 61...65, 80...82:
                Image(systemName: WeatherCode.icon(for: weatherCode))
                    .font(.system(size: 64))
                    .symbolRenderingMode(.multicolor)
            case 71...75:
                Image(systemName: WeatherCode.icon(for: weatherCode))
                    .font(.system(size: 64))
                    .symbolRenderingMode(.multicolor)
            case 95...99:
                Image(systemName: WeatherCode.icon(for: weatherCode))
                    .font(.system(size: 64))
                    .symbolRenderingMode(.multicolor)
                    .symbolEffect(.pulse, options: .repeating, value: phase)
            default:
                Image(systemName: WeatherCode.icon(for: weatherCode))
                    .font(.system(size: 64))
                    .symbolRenderingMode(.multicolor)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - 动画晴天图标
struct AnimatedSunIcon: View {
    let phase: Double
    
    var body: some View {
        ZStack {
            // 太阳本体 - 使用渐变
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.yellow, .orange],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 50, height: 50)
                .shadow(color: .yellow.opacity(0.5), radius: 20)
            
            // 旋转的光线
            ForEach(0..<12) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.8), .yellow.opacity(0)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3, height: 25)
                    .offset(y: -40)
                    .rotationEffect(.degrees(Double(i) * 30 + phase * 360))
                    .opacity(0.6 + sin(phase * .pi * 2 + Double(i)) * 0.3)
            }
        }
    }
}

// MARK: - 温度动画视图
struct TemperatureView: View {
    let temperature: Double
    @State private var displayedTemp: Double
    
    init(temperature: Double) {
        self.temperature = temperature
        // 直接使用传入的温度作为初始值，避免-1000度的跳变
        self._displayedTemp = State(initialValue: temperature)
    }
    
    var body: some View {
        Text("\(Int(displayedTemp))°C")
            .font(.system(size: 72, weight: .thin))
            .contentTransition(.numericText(value: displayedTemp))
            .onChange(of: temperature) { oldValue, newValue in
                // 温度变化时的动画
                withAnimation(.spring(duration: 0.5)) {
                    displayedTemp = newValue
                }
            }
    }
}



#Preview {
    VStack(spacing: 20) {
        WeatherLoadingView()
            .padding()
            .background(.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        
        TemperatureView(temperature: 25)
            .padding()
            .background(.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        
        DynamicWeatherIcon(weatherCode: 0)
            .padding()
            .background(.blue.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding()
}
