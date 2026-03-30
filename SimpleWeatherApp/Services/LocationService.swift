import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, @unchecked Sendable, @preconcurrency LocationServiceProtocol {
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationName: String = "当前位置"

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // 优化位置精度策略，平衡精度和电量
        manager.distanceFilter = 1000 // 至少移动 1000 米才更新
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        manager.requestLocation()
    }

    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
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
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.manager.requestLocation()
            }
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
    }
}
