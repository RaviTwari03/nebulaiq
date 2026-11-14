import SwiftUI
import CoreLocation
import UserNotifications

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @ObservedObject private var locationService = LocationService.shared
    @ObservedObject private var notificationService = NotificationService.shared
    
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Text(String(viewModel.currentUser?.fullName.prefix(1) ?? "U"))
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentUser?.fullName ?? "User")
                                .font(.headline)
                            Text(viewModel.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Location Authorization"), footer: Text("iOS requires 'Always' authorization to monitor geofences and wake the app when you exit a safe zone while the app is in the background or closed.")) {
                    HStack {
                        Text("Permission Status")
                        Spacer()
                        Text(locationStatusString)
                            .foregroundColor(locationStatusColor)
                            .font(.subheadline.weight(.medium))
                    }
                    
                    if viewModel.locationStatus != .authorizedAlways {
                        Button {
                            viewModel.requestLocationPermission()
                        } label: {
                            Label("Request 'Always' Permission", systemImage: "location.badge.checkmark")
                        }
                    }
                }
                
                Section(header: Text("Push Notifications"), footer: Text("Push notifications are used to alert group members when someone exits a geofence.")) {
                    HStack {
                        Text("APNs Notification Status")
                        Spacer()
                        Text(notificationStatusString)
                            .foregroundColor(notificationStatusColor)
                            .font(.subheadline.weight(.medium))
                    }
                    
                    HStack {
                        Text("Device Token")
                        Spacer()
                        if let token = notificationService.deviceToken {
                            Text("\(token.prefix(8))...")
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                        } else {
                            Text("Not registered")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if viewModel.notificationStatus != .authorized {
                        Button {
                            viewModel.requestNotificationPermission()
                        } label: {
                            Label("Enable Push Notifications", systemImage: "bell.badge")
                        }
                    }
                }
                
                Section(header: Text("Device Capabilities & Limits")) {
                    HStack {
                        Text("Region Monitoring Support")
                        Spacer()
                        Text(locationService.isMonitoringSupported ? "Supported" : "Unsupported")
                            .foregroundColor(locationService.isMonitoringSupported ? .green : .red)
                    }
                    
                    HStack {
                        Text("Active Monitored Regions")
                        Spacer()
                        Text("\(viewModel.monitoredRegionsCount) / \(AppConfig.maxMonitoredRegions) max")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showSignOutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile & Settings")
            .confirmationDialog("Sign Out", isPresented: $showSignOutAlert, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    viewModel.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out of GeoCircle?")
            }
        }
    }
    
    private var locationStatusString: String {
        switch viewModel.locationStatus {
        case .authorizedAlways: return "Always Authorized"
        case .authorizedWhenInUse: return "When In Use"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }
    
    private var locationStatusColor: Color {
        switch viewModel.locationStatus {
        case .authorizedAlways: return .green
        case .authorizedWhenInUse: return .orange
        case .denied, .restricted: return .red
        case .notDetermined: return .secondary
        @unknown default: return .secondary
        }
    }
    
    private var notificationStatusString: String {
        switch viewModel.notificationStatus {
        case .authorized: return "Enabled"
        case .denied: return "Denied"
        case .notDetermined: return "Not Determined"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
    
    private var notificationStatusColor: Color {
        switch viewModel.notificationStatus {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .secondary
        default: return .orange
        }
    }
}
