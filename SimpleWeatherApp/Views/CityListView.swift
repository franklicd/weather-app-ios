import SwiftUI

struct CityListView: View {
    @Environment(WeatherStore.self) private var store
    @State private var searchText = ""
    @State private var showingPresets = false
    @State private var showingLocationError = false

    var searchResults: [PresetCity] {
        guard !searchText.isEmpty else { return [] }
        return CityDataService.presetCities.filter { $0.name.contains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                    // 搜索框
                    Section {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("输入城市名称", text: $searchText)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.18))
                    }

                    // 搜索结果（输入时显示）
                    if !searchText.isEmpty {
                        Section {
                            if searchResults.isEmpty {
                                Text("未找到「\(searchText)」")
                                    .foregroundStyle(.secondary)
                                    .listRowBackground(Color.white.opacity(0.18))
                            } else {
                                ForEach(searchResults, id: \.name) { preset in
                                    let alreadyAdded = store.cities.contains { $0.name == preset.name }
                                    Button {
                                        if alreadyAdded {
                                            if let idx = store.cities.firstIndex(where: { $0.name == preset.name }) {
                                                store.selectedIndex = idx
                                            }
                                        } else {
                                            store.addCity(preset)
                                        }
                                        searchText = ""
                                    } label: {
                                        HStack {
                                            Text(preset.name)
                                                .foregroundStyle(.primary)
                                            Spacer()
                                            Image(systemName: alreadyAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                                                .foregroundStyle(alreadyAdded ? .green : .blue)
                                        }
                                    }
                                    .listRowBackground(Color.white.opacity(0.18))
                                }
                            }
                        } header: {
                            Text(searchResults.isEmpty ? "搜索结果" : "点击城市名称可添加")
                        }
                    }

                    // GPS 当前位置
                    Section {
                        Button {
                            store.addCurrentLocation()
                            showingLocationError = store.locationError != nil
                        } label: {
                            Label("使用当前位置", systemImage: "location.fill")
                                .foregroundStyle(.blue)
                        }
                        .listRowBackground(Color.white.opacity(0.18))
                    }

                    // 已添加城市
                    Section {
                        ForEach(Array(store.cities.enumerated()), id: \.element.id) { idx, city in
                            Button {
                                store.selectedIndex = idx
                            } label: {
                                EnhancedCityRowView(city: city, isSelected: store.selectedIndex == idx)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.white.opacity(0.18))
                        }
                        .onDelete { offsets in
                            store.removeCity(at: offsets)
                        }
                    } header: {
                        Text("已添加城市")
                    }
                }
                .scrollContentBackground(.hidden)
            .background {
                WeatherBackgroundView(weatherCode: store.selectedCity?.weather?.current.weather_code)
                    .ignoresSafeArea()
            }
            .navigationTitle("城市")
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingPresets = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                }
                .sheet(isPresented: $showingPresets) {
                    PresetCityPickerView()
                }
                .alert("定位失败", isPresented: $showingLocationError) {
                    Button("确定", role: .cancel) { store.locationError = nil }
                    Button("前往设置") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                } message: {
                    Text(store.locationError ?? "")
                }
                .onChange(of: store.locationError) { _, newValue in
                    showingLocationError = newValue != nil
                }
                .task {
                    if store.cities.allSatisfy({ $0.weather == nil }) {
                        await store.fetchAllWeather()
                    }
                }
        }
    }
}

// MARK: - Enhanced City Row

struct EnhancedCityRowView: View {
    let city: CityWeather
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            // 左侧：城市信息
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if city.isCurrentLocation {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                    Text(city.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    // 告警数量徽章
                    if !city.alerts.isEmpty {
                        ZStack {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.9), Color.yellow.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("\(city.alerts.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                        }
                        .fixedSize()
                        .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                }
                
                if let weather = city.weather {
                    Text(WeatherCode.description(for: weather.current.weather_code))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if city.isLoading {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("加载中...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // 右侧：天气信息
            HStack(spacing: 12) {
                if city.isLoading {
                    ProgressView()
                        .scaleEffect(1.0)
                } else if let weather = city.weather {
                    // 天气图标
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: WeatherCode.icon(for: weather.current.weather_code))
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.orange)
                    }
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // 温度
                    Text("\(Int(weather.current.temperature_2m))°")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                }

                // 选中标识
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    isSelected ?
                    LinearGradient(
                        colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isSelected ? Color.blue.opacity(0.3) : .black.opacity(0.2), radius: isSelected ? 16 : 12, x: 0, y: isSelected ? 8 : 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            isSelected ?
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 1.5
                        )
                )
        )
    }
}

// MARK: - Preset City Picker

struct PresetCityPickerView: View {
    @Environment(WeatherStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var geoResults: [GeocodingResult] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    // 空状态显示常用城市（前20个）
    private let popularCities: [PresetCity] = Array(CityDataService.presetCities.prefix(20))

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    // 空状态：显示常用城市
                    Section {
                        ForEach(popularCities, id: \.name) { preset in
                            cityRow(name: preset.name, subtitle: nil,
                                    lat: preset.lat, lon: preset.lon)
                        }
                    } header: {
                        Text("常用城市")
                    }
                } else if isSearching {
                    Section {
                        HStack(spacing: 10) {
                            ProgressView().scaleEffect(0.85)
                            Text("搜索中...").foregroundStyle(.secondary)
                        }
                    }
                } else if geoResults.isEmpty {
                    Section {
                        Text("未找到「\(searchText)」")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section {
                        ForEach(geoResults) { result in
                            cityRow(name: result.name, subtitle: result.subtitle,
                                    lat: result.latitude, lon: result.longitude)
                        }
                    } header: {
                        Text("搜索结果（全球）")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜索全球城市")
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                geoResults = []
                guard !newValue.trimmingCharacters(in: .whitespaces).isEmpty else {
                    isSearching = false
                    return
                }
                isSearching = true
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(550))
                    guard !Task.isCancelled else { return }
                    let results = await CityDataService.searchGlobal(query: newValue)
                    guard !Task.isCancelled else { return }
                    geoResults = results
                    isSearching = false
                }
            }
            .navigationTitle("添加城市")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func cityRow(name: String, subtitle: String?, lat: Double, lon: Double) -> some View {
        let added = store.cities.contains { $0.name == name }
        Button {
            if !added {
                store.addCity(PresetCity(name: name, lat: lat, lon: lon))
                dismiss()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .foregroundStyle(added ? .secondary : .primary)
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if added {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
    }
}
