import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var isRegistering = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    var isInputValid: Bool {
        if isRegistering {
            return !email.isEmpty && email.contains("@") && password.count >= 6 && !fullName.isEmpty
        } else {
            return !email.isEmpty && email.contains("@") && password.count >= 6
        }
    }
    
    func submit() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            if isRegistering {
                try await authService.register(email: email, password: password, fullName: fullName)
            } else {
                try await authService.login(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
