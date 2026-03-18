import SwiftUI

struct CityListView: View {
    @Environment(WeatherStore.self) private var store
    @State private var searchText = ""
    @State private var showingPresets = false
    @State private var showingLocationError = false

    var filteredPresets: [PresetCity] {
        if searchText.isEmpty { return CityDataService.presetCities }
        return CityDataService.presetCities.filter { $0.name.contains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                // GPS 当前位置
                Section {
                    Button {
                        store.addCurrentLocation()
                        showingLocationError = store.locationError != nil
                    } label: {
                        Label("使用当前位置", systemImage: "location.fill")
                            .foregroundStyle(.blue)
                    }
                }

                // 已添加城市
                Section {
                    ForEach(Array(store.cities.enumerated()), id: \.element.id) { idx, city in
                        Button {
                            store.selectedIndex = idx
                        } label: {
                            CityRowView(city: city, isSelected: store.selectedIndex == idx)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        store.removeCity(at: offsets)
                    }
                } header: {
                    Text("已添加城市")
                }
            }
            .searchable(text: $searchText, prompt: "搜索城市")
            .navigationTitle("城市")
            .onSubmit(of: .search) {
                // 搜索提交时直接添加匹配的城市
                if let matched = filteredPresets.first {
                    if !store.cities.contains(where: { $0.name == matched.name }) {
                        store.addCity(matched)
                        searchText = ""
                    } else {
                        // 城市已存在，选中它
                        if let idx = store.cities.firstIndex(where: { $0.name == matched.name }) {
                            store.selectedIndex = idx
                        }
                        searchText = ""
                    }
                }
            }
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

// MARK: - City Row

struct CityRowView: View {
    let city: CityWeather
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    if city.isCurrentLocation {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    Text(city.name)
                        .font(.headline)
                }
                if let weather = city.weather {
                    Text(WeatherCode.description(for: weather.current.weather_code))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if city.isLoading {
                    Text("加载中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if city.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else if let weather = city.weather {
                HStack(spacing: 6) {
                    Image(systemName: WeatherCode.icon(for: weather.current.weather_code))
                        .foregroundStyle(.orange)
                    Text("\(Int(weather.current.temperature_2m))°")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }

            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.blue.opacity(0.08) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preset City Picker

struct PresetCityPickerView: View {
    @Environment(WeatherStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var filtered: [PresetCity] {
        searchText.isEmpty ? CityDataService.presetCities
            : CityDataService.presetCities.filter { $0.name.contains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.name) { preset in
                let added = store.cities.contains { $0.name == preset.name }
                Button {
                    if !added {
                        store.addCity(preset)
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text(preset.name)
                        Spacer()
                        if added {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .foregroundStyle(added ? .secondary : .primary)
            }
            .searchable(text: $searchText, prompt: "搜索城市")
            .navigationTitle("添加城市")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
