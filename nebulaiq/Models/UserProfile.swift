import Foundation

struct UserProfile: Identifiable, Codable, Hashable {
    let id: UUID
    var email: String
    var fullName: String
    var avatarUrl: String?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}
