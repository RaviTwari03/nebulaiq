import Foundation
import UIKit
import Combine

@MainActor
final class GroupDetailViewModel: ObservableObject {
    @Published var group: TrackingGroup
    @Published var members: [GroupMember] = []
    @Published var geofence: Geofence?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var copiedInviteCode: Bool = false
    
    private let groupService = GroupService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(group: TrackingGroup) {
        self.group = group
        self.geofence = group.activeGeofence
        
        groupService.$membersByGroup
            .map { $0[group.id] ?? [] }
            .receive(on: RunLoop.main)
            .assign(to: \.members, on: self)
            .store(in: &cancellables)
            
        groupService.$geofencesByGroup
            .map { $0[group.id] }
            .receive(on: RunLoop.main)
            .assign(to: \.geofence, on: self)
            .store(in: &cancellables)
    }
    
    func isCreator(currentUserId: UUID) -> Bool {
        group.creatorId == currentUserId
    }
    
    func copyCode() {
        #if canImport(UIKit)
        UIPasteboard.general.string = group.inviteCode
        #endif
        copiedInviteCode = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                self.copiedInviteCode = false
            }
        }
    }
    
    func leaveGroup(currentUserId: UUID) async throws {
        try await groupService.leaveGroup(groupId: group.id, userId: currentUserId)
    }
}
