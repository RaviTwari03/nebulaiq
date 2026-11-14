import Foundation
import CoreLocation

struct Geofence: Identifiable, Codable, Hashable {
    let id: UUID
    let groupId: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var radiusMeters: Double
    var isActive: Bool
    let createdBy: UUID
    var createdAt: Date
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case name
        case latitude
        case longitude
        case radiusMeters = "radius_meters"
        case isActive = "is_active"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var regionIdentifier: String {
        "geocircle.region.\(groupId.uuidString).\(id.uuidString)"
    }
    
    func makeCircularRegion() -> CLCircularRegion {
        let region = CLCircularRegion(
            center: coordinate,
            radius: min(radiusMeters, AppConfig.maxGeofenceRadiusMeters),
            identifier: regionIdentifier
        )
        region.notifyOnExit = true
        region.notifyOnEntry = true
        return region
    }
    
    static func == (lhs: Geofence, rhs: Geofence) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
