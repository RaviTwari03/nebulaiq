import Foundation

struct AppNotification: Identifiable, Codable, Hashable {
    let id: UUID
    let recipientUserId: UUID
    let triggeringUserId: UUID?
    let groupId: UUID?
    let title: String
    let body: String
    let eventType: String
    var isRead: Bool
    let createdAt: Date
    
    // Optional associated model data
    var groupName: String?
    var memberName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipientUserId = "recipient_user_id"
        case triggeringUserId = "triggering_user_id"
        case groupId = "group_id"
        case title
        case body
        case eventType = "event_type"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}
