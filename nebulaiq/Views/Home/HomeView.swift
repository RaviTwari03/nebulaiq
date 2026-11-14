import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var authService = AuthService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.groups.isEmpty {
                    ProgressView("Loading groups...")
                } else if viewModel.groups.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3.sequence")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Tracking Groups")
                            .font(.headline)
                        
                        Text("Create a tracking group or join one with an invite code to start geofence monitoring.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        HStack(spacing: 12) {
                            Button {
                                viewModel.showCreateGroupSheet = true
                            } label: {
                                Label("Create Group", systemImage: "plus")
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button {
                                viewModel.showJoinGroupSheet = true
                            } label: {
                                Label("Join Group", systemImage: "person.badge.plus")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            ForEach(viewModel.groups) { group in
                                NavigationLink(destination: GroupDetailView(group: group)) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(group.activeGeofence != nil ? Color.green.opacity(0.15) : Color.secondary.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: group.activeGeofence != nil ? "location.circle.fill" : "person.3.fill")
                                                    .foregroundColor(group.activeGeofence != nil ? .green : .secondary)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(group.name)
                                                .font(.headline)
                                            
                                            HStack(spacing: 6) {
                                                Text("Code: \(group.inviteCode)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text("•")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                if let geofence = group.activeGeofence {
                                                    Text("\(Int(geofence.radiusMeters))m zone")
                                                        .font(.caption)
                                                        .foregroundColor(.green)
                                                } else {
                                                    Text("No geofence")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if let count = group.memberCount {
                                            Label("\(count)", systemImage: "person.2")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        } header: {
                            Text("Active Groups (\(viewModel.groups.count))")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            viewModel.showCreateGroupSheet = true
                        } label: {
                            Label("Create Group", systemImage: "plus")
                        }
                        
                        Button {
                            viewModel.showJoinGroupSheet = true
                        } label: {
                            Label("Join with Code", systemImage: "person.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateGroupSheet) {
                CreateGroupView()
            }
            .sheet(isPresented: $viewModel.showJoinGroupSheet) {
                JoinGroupView()
            }
            .task {
                if let user = authService.currentUser {
                    await viewModel.refresh(for: user.id)
                }
            }
        }
    }
}
