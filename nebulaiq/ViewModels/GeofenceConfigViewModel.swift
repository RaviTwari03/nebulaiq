import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
final class GeofenceConfigViewModel: ObservableObject {
    let group: TrackingGroup
    
    @Published var name: String
    @Published var centerCoordinate: CLLocationCoordinate2D
    @Published var radiusMeters: Double
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var isSavedSuccessfully: Bool = false
    
    private let groupService = GroupService.shared
    private let locationService = LocationService.shared
    
    init(group: TrackingGroup) {
        self.group = group
        
        if let existing = group.activeGeofence {
            self.name = existing.name
            self.centerCoordinate = existing.coordinate
            self.radiusMeters = existing.radiusMeters
        } else {
            self.name = "\(group.name) Safe Zone"
            let userLoc = locationService.currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            self.centerCoordinate = userLoc
            self.radiusMeters = AppConfig.defaultGeofenceRadiusMeters
        }
    }
    
    func saveGeofence(creatorId: UUID) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        
        let geofence = Geofence(
            id: group.activeGeofence?.id ?? UUID(),
            groupId: group.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: centerCoordinate.latitude,
            longitude: centerCoordinate.longitude,
            radiusMeters: radiusMeters,
            isActive: true,
            createdBy: creatorId,
            createdAt: group.activeGeofence?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        groupService.setGeofence(for: group.id, geofence: geofence)
        locationService.registerGeofence(geofence)
        isSavedSuccessfully = true
        return true
    }
    
    func centerOnUserLocation() {
        if let coord = locationService.currentLocation?.coordinate {
            centerCoordinate = coord
        }
    }
}
