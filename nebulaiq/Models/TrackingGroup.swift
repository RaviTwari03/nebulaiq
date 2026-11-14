import Foundation
import CoreLocation

struct TrackingGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var inviteCode: String
    let creatorId: UUID
    var createdAt: Date
    
    // Optional client-side associations
    var memberCount: Int?
    var activeGeofence: Geofence?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case inviteCode = "invite_code"
        case creatorId = "creator_id"
        case createdAt = "created_at"
    }
    
    static func == (lhs: TrackingGroup, rhs: TrackingGroup) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
