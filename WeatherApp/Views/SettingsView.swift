import SwiftUI

struct SettingsView: View {
    @Environment(WeatherStore.self) private var store
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        Task {
                            isRefreshing = true
                            await store.fetchAllWeather()
                            isRefreshing = false
                        }
                    } label: {
                        HStack {
                            Label("刷新所有城市数据", systemImage: "arrow.clockwise")
                            Spacer()
                            if isRefreshing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isRefreshing)
                } header: {
                    Text("数据")
                }

                Section {
                    HStack {
                        Label("城市数量", systemImage: "building.2")
                        Spacer()
                        Text("\(store.cities.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("有预警城市", systemImage: "exclamationmark.triangle")
                        Spacer()
                        Text("\(store.cities.filter { !$0.alerts.isEmpty }.count)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("统计")
                }

                Section {
                    HStack {
                        Label("天气数据来源", systemImage: "cloud.fill")
                        Spacer()
                        Text("Open-Meteo")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("版本", systemImage: "info.circle")
                        Spacer()
                        Text("v1.2.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("支持 iOS", systemImage: "iphone")
                        Spacer()
                        Text("iOS 26+")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("关于")
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("天气预警说明")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        ForEach(AlertSeverity.allCases, id: \.rawValue) { severity in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(severity.color)
                                    .frame(width: 10, height: 10)
                                Text(severity.label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("图例")
                }
            }
            .navigationTitle("设置")
        }
    }
}
