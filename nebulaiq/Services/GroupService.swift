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
    
    init() {
        seedSampleData()
    }
    
    func generateInviteCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).compactMap { _ in characters.randomElement() })
    }
    
    func fetchUserGroups(userId: UUID) async throws {
        if groups.isEmpty {
            seedSampleData()
        }
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
    
    // MARK: - Initial Mock / Demo Data
    
    func seedSampleData() {
        let user1Id = UUID()
        let user2Id = UUID()
        let user3Id = UUID()
        let currentUserId = AuthService.shared.currentUser?.id ?? UUID()
        
        let profileCurrent = AuthService.shared.currentUser ?? UserProfile(
            id: currentUserId,
            email: "ravi@nebulaiq.dev",
            fullName: "Ravi Tiwari",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 30)
        )
        
        let profileSarah = UserProfile(
            id: user1Id,
            email: "sarah.c@example.com",
            fullName: "Sarah Connor",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 20)
        )
        
        let profileAlex = UserProfile(
            id: user2Id,
            email: "alex.chen@example.com",
            fullName: "Alex Chen",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 15)
        )
        
        let profileJordan = UserProfile(
            id: user3Id,
            email: "jordan.s@example.com",
            fullName: "Jordan Smith",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 10)
        )
        
        // Group 1: Family Safe Zone
        let group1Id = UUID()
        let geofence1 = Geofence(
            id: UUID(),
            groupId: group1Id,
            name: "Home Perimeter",
            latitude: 37.7749,
            longitude: -122.4194,
            radiusMeters: 250.0,
            isActive: true,
            createdBy: currentUserId,
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: nil
        )
        
        let group1 = TrackingGroup(
            id: group1Id,
            name: "Family Safe Zone",
            inviteCode: "FAM892",
            creatorId: currentUserId,
            createdAt: Date().addingTimeInterval(-86400 * 7),
            memberCount: 3,
            activeGeofence: geofence1
        )
        
        let members1 = [
            GroupMember(id: UUID(), groupId: group1Id, userId: currentUserId, role: .creator, joinedAt: Date().addingTimeInterval(-86400 * 7), profile: profileCurrent),
            GroupMember(id: UUID(), groupId: group1Id, userId: user1Id, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 5), profile: profileSarah),
            GroupMember(id: UUID(), groupId: group1Id, userId: user2Id, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 4), profile: profileAlex)
        ]
        
        // Group 2: Weekend Hiking Team
        let group2Id = UUID()
        let geofence2 = Geofence(
            id: UUID(),
            groupId: group2Id,
            name: "Basecamp Circle",
            latitude: 37.7891,
            longitude: -122.4014,
            radiusMeters: 500.0,
            isActive: true,
            createdBy: user2Id,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            updatedAt: nil
        )
        
        let group2 = TrackingGroup(
            id: group2Id,
            name: "Weekend Hiking Team",
            inviteCode: "HIKE45",
            creatorId: user2Id,
            createdAt: Date().addingTimeInterval(-86400 * 3),
            memberCount: 3,
            activeGeofence: geofence2
        )
        
        let members2 = [
            GroupMember(id: UUID(), groupId: group2Id, userId: user2Id, role: .creator, joinedAt: Date().addingTimeInterval(-86400 * 3), profile: profileAlex),
            GroupMember(id: UUID(), groupId: group2Id, userId: currentUserId, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 2), profile: profileCurrent),
            GroupMember(id: UUID(), groupId: group2Id, userId: user3Id, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 1), profile: profileJordan)
        ]
        
        // Group 3: Downtown Office
        let group3Id = UUID()
        let group3 = TrackingGroup(
            id: group3Id,
            name: "Downtown Office",
            inviteCode: "OFFICE",
            creatorId: currentUserId,
            createdAt: Date().addingTimeInterval(-86400 * 1),
            memberCount: 2,
            activeGeofence: nil
        )
        
        let members3 = [
            GroupMember(id: UUID(), groupId: group3Id, userId: currentUserId, role: .creator, joinedAt: Date().addingTimeInterval(-86400 * 1), profile: profileCurrent),
            GroupMember(id: UUID(), groupId: group3Id, userId: user1Id, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 1), profile: profileSarah)
        ]
        
        self.groups = [group1, group2, group3]
        self.geofencesByGroup = [
            group1Id: geofence1,
            group2Id: geofence2
        ]
        self.membersByGroup = [
            group1Id: members1,
            group2Id: members2,
            group3Id: members3
        ]
    }
}
