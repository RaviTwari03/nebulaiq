import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared
    @ObservedObject private var groupService = GroupService.shared
    
    @State private var groupName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Group Details")) {
                    TextField("Group Name (e.g., Family, Hiking Trip)", text: $groupName)
                }
                
                Section(footer: Text("Once created, an invitation code will be generated for other members to join.")) {
                    Button {
                        guard let user = authService.currentUser else { return }
                        isLoading = true
                        errorMessage = nil
                        
                        Task {
                            do {
                                _ = try await groupService.createGroup(name: groupName, creator: user)
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
                                Text("Create Group")
                                    .fontWeight(.medium)
                            }
                            Spacer()
                        }
                    }
                    .disabled(groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Group")
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
