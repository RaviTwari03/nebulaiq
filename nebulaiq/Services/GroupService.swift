import Foundation
import Combine

@MainActor
final class GroupService: ObservableObject {
    static let shared = GroupService()
    
    @Published var groups: [TrackingGroup] = []
    @Published var membersByGroup: [UUID: [GroupMember]] = [:]
    @Published var geofencesByGroup: [UUID: Geofence] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {}
    
    func generateInviteCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).compactMap { _ in characters.randomElement() })
    }
    
    func fetchUserGroups(userId: UUID) async throws {
        isLoading = true
        defer { isLoading = false }
        // Populated in Phase 3 via Supabase
    }
    
    func createGroup(name: String, creator: UserProfile) async throws -> TrackingGroup {
        isLoading = true
        defer { isLoading = false }
        
        let newGroup = TrackingGroup(
            id: UUID(),
            name: name,
            inviteCode: generateInviteCode(),
            creatorId: creator.id,
            createdAt: Date(),
            memberCount: 1,
            activeGeofence: nil
        )
        
        let creatorMember = GroupMember(
            id: UUID(),
            groupId: newGroup.id,
            userId: creator.id,
            role: .creator,
            joinedAt: Date(),
            profile: creator
        )
        
        groups.insert(newGroup, at: 0)
        membersByGroup[newGroup.id] = [creatorMember]
        return newGroup
    }
    
    func joinGroup(inviteCode: String, user: UserProfile) async throws -> TrackingGroup {
        isLoading = true
        defer { isLoading = false }
        
        let cleanCode = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let group = groups.first(where: { $0.inviteCode == cleanCode }) else {
            throw NSError(domain: "GroupService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group with code \(cleanCode) not found."])
        }
        
        let newMember = GroupMember(
            id: UUID(),
            groupId: group.id,
            userId: user.id,
            role: .member,
            joinedAt: Date(),
            profile: user
        )
        
        var currentMembers = membersByGroup[group.id] ?? []
        if !currentMembers.contains(where: { $0.userId == user.id }) {
            currentMembers.append(newMember)
            membersByGroup[group.id] = currentMembers
        }
        return group
    }
    
    func leaveGroup(groupId: UUID, userId: UUID) async throws {
        groups.removeAll(where: { $0.id == groupId })
        membersByGroup.removeValue(forKey: groupId)
        geofencesByGroup.removeValue(forKey: groupId)
    }
    
    func setGeofence(for groupId: UUID, geofence: Geofence) {
        geofencesByGroup[groupId] = geofence
        if let idx = groups.firstIndex(where: { $0.id == groupId }) {
            groups[idx].activeGeofence = geofence
        }
    }
}
