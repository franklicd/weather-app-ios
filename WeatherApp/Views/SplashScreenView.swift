import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0

    var body: some View {
        if isActive {
            ContentView()
        } else {
            splashContent
                .onAppear {
                    withAnimation(.spring(duration: 0.6)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                    Task {
                        try? await Task.sleep(for: .seconds(1.8))
                        withAnimation(.easeOut(duration: 0.25)) {
                            isActive = true
                        }
                    }
                }
        }
    }

    private var splashContent: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.48, blue: 0.92),
                    Color(red: 0.04, green: 0.22, blue: 0.62),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 88))
                    .symbolRenderingMode(.multicolor)
                    .shadow(color: .white.opacity(0.3), radius: 24, x: 0, y: 8)

                VStack(spacing: 10) {
                    Text("天气")
                        .font(.system(size: 54, weight: .ultraLight, design: .rounded))
                        .foregroundStyle(.white)

                    Text("实时天气 · 智能预警")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                        .tracking(3)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
    }
}
