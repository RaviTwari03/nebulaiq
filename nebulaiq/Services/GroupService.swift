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
    
    // MARK: - Initial Mock / Human Names
    
    func seedSampleData() {
        let user1Id = UUID()
        let user2Id = UUID()
        let user3Id = UUID()
        let user4Id = UUID()
        let currentUserId = AuthService.shared.currentUser?.id ?? UUID()
        
        let profileCurrent = AuthService.shared.currentUser ?? UserProfile(
            id: currentUserId,
            email: "ravirkt0@gmail.com",
            fullName: "Ravi",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 30)
        )
        
        let profileNeha = UserProfile(
            id: user1Id,
            email: "neha.t@gmail.com",
            fullName: "Neha Tiwari",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 20)
        )
        
        let profileAarav = UserProfile(
            id: user2Id,
            email: "aarav.t@gmail.com",
            fullName: "Aarav Tiwari",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 15)
        )
        
        let profileRohan = UserProfile(
            id: user3Id,
            email: "rohan.mehta@gmail.com",
            fullName: "Rohan Mehta",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 10)
        )
        
        let profilePooja = UserProfile(
            id: user4Id,
            email: "pooja.v@gmail.com",
            fullName: "Pooja Verma",
            avatarUrl: nil,
            createdAt: Date().addingTimeInterval(-86400 * 8)
        )
        
        // Group 1: Our Family
        let group1Id = UUID()
        let geofence1 = Geofence(
            id: UUID(),
            groupId: group1Id,
            name: "Home (Baridih)",
            latitude: 22.802772,
            longitude: 86.256396,
            radiusMeters: 200.0,
            isActive: true,
            createdBy: currentUserId,
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: nil
        )
        
        let group1 = TrackingGroup(
            id: group1Id,
            name: "Our Family",
            inviteCode: "HOME01",
            creatorId: currentUserId,
            createdAt: Date().addingTimeInterval(-86400 * 7),
            memberCount: 3,
            activeGeofence: geofence1
        )
        
        let members1 = [
            GroupMember(id: UUID(), groupId: group1Id, userId: currentUserId, role: .creator, joinedAt: Date().addingTimeInterval(-86400 * 7), profile: profileCurrent),
            GroupMember(id: UUID(), groupId: group1Id, userId: user1Id, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 5), profile: profileNeha),
            GroupMember(id: UUID(), groupId: group1Id, userId: user2Id, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 4), profile: profileAarav)
        ]
        
        // Group 2: College Friends
        let group2Id = UUID()
        let geofence2 = Geofence(
            id: UUID(),
            groupId: group2Id,
            name: "Jubilee Park",
            latitude: 22.8050,
            longitude: 86.1950,
            radiusMeters: 400.0,
            isActive: true,
            createdBy: user3Id,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            updatedAt: nil
        )
        
        let group2 = TrackingGroup(
            id: group2Id,
            name: "College Friends",
            inviteCode: "TRIP24",
            creatorId: user3Id,
            createdAt: Date().addingTimeInterval(-86400 * 3),
            memberCount: 3,
            activeGeofence: geofence2
        )
        
        let members2 = [
            GroupMember(id: UUID(), groupId: group2Id, userId: user3Id, role: .creator, joinedAt: Date().addingTimeInterval(-86400 * 3), profile: profileRohan),
            GroupMember(id: UUID(), groupId: group2Id, userId: currentUserId, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 2), profile: profileCurrent),
            GroupMember(id: UUID(), groupId: group2Id, userId: user4Id, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 1), profile: profilePooja)
        ]
        
        // Group 3: Office Team
        let group3Id = UUID()
        let group3 = TrackingGroup(
            id: group3Id,
            name: "Office Team",
            inviteCode: "WORK42",
            creatorId: currentUserId,
            createdAt: Date().addingTimeInterval(-86400 * 1),
            memberCount: 2,
            activeGeofence: nil
        )
        
        let members3 = [
            GroupMember(id: UUID(), groupId: group3Id, userId: currentUserId, role: .creator, joinedAt: Date().addingTimeInterval(-86400 * 1), profile: profileCurrent),
            GroupMember(id: UUID(), groupId: group3Id, userId: user1Id, role: .member, joinedAt: Date().addingTimeInterval(-86400 * 1), profile: profileNeha)
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
