import SwiftUI

struct AlertBannerView: View {
    let alerts: [WeatherAlert]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部横幅
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // 左侧图标
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    // 中间文字
                    VStack(alignment: .leading, spacing: 4) {
                        Text("天气警报")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("\(alerts.count) 条警报")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // 右侧展开/收起箭头
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.25),
                                    Color.orange.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.orange.opacity(0.3), radius: 16, x: 0, y: 8)
                        .shadow(color: Color.yellow.opacity(0.2), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.yellow.opacity(0.5),
                                            Color.orange.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 展开的详细告警列表
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(alerts) { alert in
                        HStack(spacing: 16) {
                            // 左侧图标和渐变背景
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [alert.severity.color.opacity(0.8), alert.severity.color.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: alert.icon)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .shadow(color: alert.severity.color.opacity(0.4), radius: 6, x: 0, y: 3)

                            // 右侧文字内容
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(alert.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(alert.severity.label)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [alert.severity.color, alert.severity.color.opacity(0.7)],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                        )
                                        .foregroundStyle(.white)
                                }
                                Text(alert.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            alert.severity.color.opacity(0.12),
                                            alert.severity.color.opacity(0.04)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: alert.severity.color.opacity(0.15), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    alert.severity.color.opacity(0.3),
                                                    alert.severity.color.opacity(0.08)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.2
                                        )
                                )
                        )
                    }
                }
                .padding(.top, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
