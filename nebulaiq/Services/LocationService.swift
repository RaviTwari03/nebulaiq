import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var monitoredRegions: [CLRegion] = []
    @Published var isMonitoringSupported: Bool = true
    @Published var lastEventMessage: String?
    
    // Callback when exit occurs to trigger backend push pipeline
    var onRegionExit: ((CLCircularRegion) -> Void)?
    var onRegionEnter: ((CLCircularRegion) -> Void)?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10.0
        
        self.authorizationStatus = locationManager.authorizationStatus
        self.isMonitoringSupported = CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
        self.monitoredRegions = Array(locationManager.monitoredRegions)
    }
    
    func requestWhenInUsePermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func registerGeofence(_ geofence: Geofence) {
        guard isMonitoringSupported else {
            lastEventMessage = "Geofence monitoring is not supported on this device."
            return
        }
        
        guard monitoredRegions.count < AppConfig.maxMonitoredRegions else {
            lastEventMessage = "Cannot monitor more than \(AppConfig.maxMonitoredRegions) regions (iOS limit)."
            return
        }
        
        let circularRegion = geofence.makeCircularRegion()
        locationManager.startMonitoring(for: circularRegion)
        refreshMonitoredRegions()
    }
    
    func stopMonitoringGeofence(regionIdentifier: String) {
        for region in locationManager.monitoredRegions {
            if region.identifier == regionIdentifier {
                locationManager.stopMonitoring(for: region)
            }
        }
        refreshMonitoredRegions()
    }
    
    func refreshMonitoredRegions() {
        self.monitoredRegions = Array(locationManager.monitoredRegions)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            self.refreshMonitoredRegions()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        Task { @MainActor in
            self.lastEventMessage = "Exited geofence: \(circularRegion.identifier)"
            self.onRegionExit?(circularRegion)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        Task { @MainActor in
            self.lastEventMessage = "Entered geofence: \(circularRegion.identifier)"
            self.onRegionEnter?(circularRegion)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        Task { @MainActor in
            self.lastEventMessage = "Monitoring failed for region: \(region?.identifier ?? "unknown"). Error: \(error.localizedDescription)"
        }
    }
}
