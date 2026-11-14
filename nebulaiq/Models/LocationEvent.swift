import Foundation

enum LocationEventType: String, Codable, Hashable {
    case enter
    case exit
}

struct LocationEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let groupId: UUID
    let geofenceId: UUID
    let userId: UUID
    let eventType: LocationEventType
    let latitude: Double?
    let longitude: Double?
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case geofenceId = "geofence_id"
        case userId = "user_id"
        case eventType = "event_type"
        case latitude
        case longitude
        case timestamp
    }
}
