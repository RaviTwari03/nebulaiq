import Foundation
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: UserProfile?
    @Published var accessToken: String?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let tokenKey = "geocircle_access_token"
    private let userKey = "geocircle_current_user"
    
    init() {
        restoreSession()
    }
    
    func restoreSession() {
        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(UserProfile.self, from: userData) {
            self.accessToken = token
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func register(email: String, password: String, fullName: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // In Phase 2, this will call Supabase Auth /auth/v1/signup
        // Creating a local stub session for Phase 1 verification
        let newUserId = UUID()
        let profile = UserProfile(
            id: newUserId,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarUrl: nil,
            createdAt: Date()
        )
        let token = "mock_token_\(UUID().uuidString)"
        
        saveSession(token: token, user: profile)
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // In Phase 2, this will call Supabase Auth /auth/v1/token?grant_type=password
        let existingUserId = UUID()
        let profile = UserProfile(
            id: existingUserId,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            fullName: "Demo User",
            avatarUrl: nil,
            createdAt: Date()
        )
        let token = "mock_token_\(UUID().uuidString)"
        
        saveSession(token: token, user: profile)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        self.accessToken = nil
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    func saveSession(token: String, user: UserProfile) {
        self.accessToken = token
        self.currentUser = user
        self.isAuthenticated = true
        
        UserDefaults.standard.set(token, forKey: tokenKey)
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
}
