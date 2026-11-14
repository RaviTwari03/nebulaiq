import SwiftUI

struct MainTabView: View {
    @ObservedObject private var notificationService = NotificationService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Groups", systemImage: "person.3")
                }
                .tag(0)
            
            NotificationHistoryView()
                .tabItem {
                    Label("Alerts", systemImage: "bell")
                }
                .badge(notificationService.unreadCount > 0 ? notificationService.unreadCount : 0)
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
    }
}
