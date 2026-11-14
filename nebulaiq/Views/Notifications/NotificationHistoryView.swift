import SwiftUI

struct NotificationHistoryView: View {
    @ObservedObject private var notificationService = NotificationService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if notificationService.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Notifications")
                            .font(.headline)
                        
                        Text("When any member leaves a configured geofence, you will receive an instant notification here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button {
                            notificationService.addLocalAlert(
                                title: "Safe Zone Exit",
                                body: "Demo Member has exited the designated safe zone."
                            )
                        } label: {
                            Label("Simulate Test Notification", systemImage: "bell.badge")
                                .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notificationService.notifications) { item in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(item.isRead ? Color.clear : Color.blue)
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 6)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(item.title)
                                            .font(.headline)
                                        Spacer()
                                        Text(item.createdAt, style: .time)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(item.body)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                if !notificationService.notifications.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Mark Read") {
                            notificationService.markAllAsRead()
                        }
                        .disabled(notificationService.unreadCount == 0)
                    }
                }
            }
        }
    }
}
