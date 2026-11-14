import Foundation

enum GroupRole: String, Codable, Hashable {
    case creator
    case member
}

struct GroupMember: Identifiable, Codable, Hashable {
    let id: UUID
    let groupId: UUID
    let userId: UUID
    var role: GroupRole
    var joinedAt: Date
    
    // Joined profile data
    var profile: UserProfile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case userId = "user_id"
        case role
        case joinedAt = "joined_at"
        case profile
    }
}
