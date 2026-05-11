import SwiftUI

// MARK: - City List View

struct CityListView: View {
    @Environment(WeatherStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var showingPresets = false
    @State private var showingLocationError = false
    @State private var listAppear = false

    private var backgroundColor: Color {
        colorScheme == .dark ? DTColor.Background.dark : DTColor.Background.light
    }

    var searchResults: [PresetCity] {
        guard !searchText.isEmpty else { return [] }
        return CityDataService.presetCities.filter { $0.name.contains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DTSpacing.md) {
                        // Title
                        Text("简天气")
                            .font(DTFont.title2.font)
                            .fontWeight(.bold)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DTSpacing.lg)

                        // Search pill
                        RedesignedSearchPill(text: $searchText)
                            .padding(.horizontal, DTSpacing.lg)
                            .opacity(listAppear ? 1 : 0)
                            .offset(y: listAppear ? 0 : -12)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: listAppear)

                        if !searchText.isEmpty {
                            searchResultsView
                        } else {
                            cityListView
                        }

                        // Bottom padding for tab bar
                        Color.clear.frame(height: 80)
                    }
                    .padding(.top, DTSpacing.md)
                }
                .scrollContentBackground(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
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
                if let selectedCity = store.selectedCity {
                    if selectedCity.weather == nil ||
                       selectedCity.lastUpdated == nil ||
                       Date().timeIntervalSince(selectedCity.lastUpdated!) > 15 * 60 {
                        await store.fetchWeather(at: store.selectedIndex)
                    }
                }
            }
            .onAppear { listAppear = true }
        }
    }

    // MARK: - Search Results

    @ViewBuilder
    private var searchResultsView: some View {
        if searchResults.isEmpty {
            Text("未找到「\(searchText)」")
                .font(DTFont.body2.font)
                .foregroundStyle(.secondary)
                .padding(.top, DTSpacing.xl)
        } else {
            VStack(spacing: DTSpacing.sm) {
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
                                .font(DTFont.body1.font)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: alreadyAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                                .foregroundStyle(alreadyAdded ? .green : DTColor.Brand.primaryLight)
                        }
                        .padding(.horizontal, DTSpacing.lg)
                        .padding(.vertical, DTSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DTRadius.lg)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
            }
            .padding(.horizontal, DTSpacing.lg)
        }
    }

    // MARK: - City List

    @ViewBuilder
    private var cityListView: some View {
        VStack(spacing: DTSpacing.md) {
            // Section header with plus button
            HStack {
                Text("我的城市")
                    .font(DTFont.title2.font)
                    .fontWeight(.bold)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Spacer()
                Button { showingPresets = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(DTColor.Brand.primaryLight)
                }
            }
            .padding(.horizontal, DTSpacing.lg)
            .padding(.top, DTSpacing.sm)
            .opacity(listAppear ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: listAppear)

            LazyVStack(spacing: DTSpacing.sm) {
                ForEach(Array(store.cities.enumerated()), id: \.element.id) { idx, city in
                    RedesignedCityCard(
                        city: city,
                        isSelected: store.selectedIndex == idx,
                        onSelect: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                store.selectedIndex = idx
                            }
                        },
                        onDelete: {
                            store.removeCity(at: IndexSet(integer: idx))
                        }
                    )
                    .opacity(listAppear ? 1 : 0)
                    .offset(x: listAppear ? 0 : -24)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(idx) * 0.06),
                        value: listAppear
                    )
                }
            }
            .padding(.horizontal, DTSpacing.lg)
        }
    }
}

// MARK: - Redesigned Search Pill

struct RedesignedSearchPill: View {
    @Binding var text: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: DTSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(
                    colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.3)
                )

            TextField("搜索城市...", text: $text)
                .font(DTFont.body2.font)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { text = "" }
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
    let onSelect: () -> Void
    let onDelete: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var weatherTint: Color {
        guard let code = city.weather?.current.weather_code else {
            return colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.02)
        }
        switch code {
        case 0, 1: return Color(hex: "#F59E0B").opacity(colorScheme == .dark ? 0.08 : 0.06)
        case 2: return Color(hex: "#60A5FA").opacity(colorScheme == .dark ? 0.08 : 0.06)
        case 3: return Color(hex: "#94A3B8").opacity(colorScheme == .dark ? 0.06 : 0.04)
        case 45, 48: return Color(hex: "#CBD5E1").opacity(colorScheme == .dark ? 0.04 : 0.03)
        case 51...57: return Color(hex: "#38BDF8").opacity(colorScheme == .dark ? 0.08 : 0.06)
        case 61...65, 80...82: return Color(hex: "#2563EB").opacity(colorScheme == .dark ? 0.08 : 0.06)
        case 71...77, 85, 86: return Color(hex: "#BAE6FD").opacity(colorScheme == .dark ? 0.06 : 0.06)
        case 95...99: return Color(hex: "#A78BFA").opacity(colorScheme == .dark ? 0.08 : 0.06)
        default: return Color(hex: "#94A3B8").opacity(colorScheme == .dark ? 0.04 : 0.03)
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 0) {
                // Left accent bar (visible when selected)
                RoundedRectangle(cornerRadius: DTRadius.full)
                    .fill(isSelected ? DTColor.Brand.primaryLight : .clear)
                    .frame(width: 3, height: 44)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)

                // Card content
                HStack(spacing: DTSpacing.md) {
                    // Left: city info
                    VStack(alignment: .leading, spacing: DTSpacing.xxs) {
                        HStack(spacing: DTSpacing.xs) {
                            if city.isCurrentLocation {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(DTColor.Brand.primaryLight)
                            }
                            Text(city.name)
                                .font(DTFont.body1.font)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)

                            if !city.alerts.isEmpty {
                                AlertCountBadge(count: city.alerts.count)
                            }
                        }

                        if let weather = city.weather {
                            Text(WeatherCode.description(for: weather.current.weather_code))
                                .font(DTFont.body3.font)
                                .foregroundStyle(
                                    colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.4)
                                )
                        } else if city.isLoading {
                            Text("加载中...")
                                .font(DTFont.body3.font)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Right: weather data
                    if city.isLoading {
                        ProgressView().scaleEffect(0.75)
                    } else if let weather = city.weather {
                        HStack(spacing: DTSpacing.xs) {
                            Image(systemName: WeatherCode.icon(for: weather.current.weather_code))
                                .font(.system(size: 20))
                                .foregroundStyle(WeatherCode.color(for: weather.current.weather_code))

                            Text("\(Int(weather.current.temperature_2m))\u{00B0}")
                                .font(DTFont.data3.font)
                                .foregroundStyle(
                                    colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.8)
                                )
                        }
                    }
                }
                .padding(.horizontal, DTSpacing.lg)
                .padding(.vertical, DTSpacing.md)
            }
            .background(cardBackground)
            .scaleEffect(isSelected ? 1.01 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("删除城市", systemImage: "trash")
            }
        }
    }

    @ViewBuilder
    private var cardBackground: some View {
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
                            ? DTColor.Brand.primaryLight.opacity(0.3)
                            : (colorScheme == .dark ? Color.white.opacity(0.06) : Color.clear),
                        lineWidth: isSelected ? 1.5 : 0.5
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

    private let popularCities: [PresetCity] = Array(CityDataService.presetCities.prefix(20))

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
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
