import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var groups: [TrackingGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showCreateGroupSheet: Bool = false
    @Published var showJoinGroupSheet: Bool = false
    
    private let groupService = GroupService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        groupService.$groups
            .receive(on: RunLoop.main)
            .assign(to: \.groups, on: self)
            .store(in: &cancellables)
    }
    
    func refresh(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await groupService.fetchUserGroups(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
