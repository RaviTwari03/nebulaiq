import SwiftUI

struct JoinGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared
    @ObservedObject private var groupService = GroupService.shared
    
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Invitation Code")) {
                    TextField("Enter 6-character code", text: $inviteCode)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .font(.system(.title3, design: .monospaced))
                }
                
                Section(footer: Text("Ask the group creator to share their 6-character group invite code with you.")) {
                    Button {
                        guard let user = authService.currentUser else { return }
                        isLoading = true
                        errorMessage = nil
                        
                        Task {
                            do {
                                _ = try await groupService.joinGroup(inviteCode: inviteCode, user: user)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                            isLoading = false
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Join Group")
                                    .fontWeight(.medium)
                            }
                            Spacer()
                        }
                    }
                    .disabled(inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 || isLoading)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
