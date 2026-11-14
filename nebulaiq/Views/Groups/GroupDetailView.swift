import SwiftUI

struct GroupDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GroupDetailViewModel
    @ObservedObject private var authService = AuthService.shared
    
    @State private var showGeofenceConfig = false
    @State private var showLeaveConfirmation = false
    
    init(group: TrackingGroup) {
        _viewModel = StateObject(wrappedValue: GroupDetailViewModel(group: group))
    }
    
    var body: some View {
        List {
            Section(header: Text("Invite Code")) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.group.inviteCode)
                            .font(.system(.title2, design: .monospaced).weight(.bold))
                        Text("Share this code with members you want to invite.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.copyCode()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.copiedInviteCode ? "checkmark" : "doc.on.doc")
                            Text(viewModel.copiedInviteCode ? "Copied" : "Copy")
                        }
                        .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Geofence Boundary")) {
                if let geofence = viewModel.geofence {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label(geofence.name, systemImage: "circle.circle.fill")
                                .font(.headline)
                                .foregroundColor(.green)
                            Spacer()
                            Text("Active")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .clipShape(Capsule())
                        }
                        
                        Text("Radius: \(Int(geofence.radiusMeters)) meters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Coordinates: \(String(format: "%.4f", geofence.latitude)), \(String(format: "%.4f", geofence.longitude))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    NavigationLink(destination: GeofenceDetailView(geofence: geofence, group: viewModel.group)) {
                        Label("Inspect Geofence on Map", systemImage: "map")
                    }
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("No Geofence Configured")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Set up a geographical boundary to receive alerts when members exit the area.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                if let user = authService.currentUser, viewModel.isCreator(currentUserId: user.id) {
                    Button {
                        showGeofenceConfig = true
                    } label: {
                        Label(viewModel.geofence == nil ? "Configure Geofence" : "Edit Geofence", systemImage: "slider.horizontal.3")
                    }
                }
            }
            
            Section(header: Text("Members (\(viewModel.members.count))")) {
                if viewModel.members.isEmpty {
                    Text("No members listed.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.members) { member in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text(String(member.profile?.fullName.prefix(1) ?? "U"))
                                        .font(.subheadline.weight(.semibold))
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(member.profile?.fullName ?? "Member")
                                    .font(.body)
                                Text(member.profile?.email ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if member.role == .creator {
                                Text("Creator")
                                    .font(.caption2.weight(.medium))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showLeaveConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Leave Group")
                        Spacer()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.group.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showGeofenceConfig) {
            GeofenceConfigView(group: viewModel.group)
        }
        .confirmationDialog("Leave Group", isPresented: $showLeaveConfirmation, titleVisibility: .visible) {
            Button("Leave Group", role: .destructive) {
                if let user = authService.currentUser {
                    Task {
                        try? await viewModel.leaveGroup(currentUserId: user.id)
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will no longer receive location notifications for this group.")
        }
    }
}
