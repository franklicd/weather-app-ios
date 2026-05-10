import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, @unchecked Sendable {
    var currentLocation: CLLocation? {
        didSet {
            // 保存定位时间
            lastLocationUpdateTime = Date()
        }
    }
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationName: String = "当前位置"
    var lastLocationUpdateTime: Date?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationRetryCount = 0
    private let maxRetryCount = 3

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = AppConfig.locationAccuracy
        manager.distanceFilter = 100 // 位置变化超过100米才更新
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        // 如果已有缓存且未过期，直接使用
        if let lastUpdate = lastLocationUpdateTime,
           let currentLoc = currentLocation,
           Date().timeIntervalSince(lastUpdate) < AppConfig.locationCacheTTL {
            #if DEBUG
            print("使用缓存定位: \(currentLoc)")
            #endif
            return
        }

        #if os(iOS)
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        #elseif os(macOS)
        guard authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        #endif

        locationRetryCount = 0
        manager.requestLocation()
    }

    private func reverseGeocode(_ location: CLLocation) {
        Task {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    locationName = placemark.locality
                        ?? placemark.administrativeArea
                        ?? placemark.country
                        ?? "当前位置"
                }
            } catch {
                #if DEBUG
                print("Reverse geocode error: \(error)")
                #endif
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            #if os(iOS)
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.manager.requestLocation()
            }
            #elseif os(macOS)
            if status == .authorizedAlways {
                self.manager.requestLocation()
            }
            #endif
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
            self.reverseGeocode(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
        print("Location error: \(error.localizedDescription)")
        #endif

        Task { @MainActor in
            // 定位失败重试
            if self.locationRetryCount < self.maxRetryCount {
                self.locationRetryCount += 1
                #if DEBUG
                print("定位重试第 \(self.locationRetryCount) 次")
                #endif
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self = self else { return }
                    self.manager.requestLocation()
                }
            }
        }
    }
}
