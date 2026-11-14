import Foundation
import CoreLocation
import UserNotifications
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published var monitoredRegionsCount: Int = 0
    
    private let authService = AuthService.shared
    private let locationService = LocationService.shared
    private let notificationService = NotificationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        authService.$currentUser
            .receive(on: RunLoop.main)
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
            
        locationService.$authorizationStatus
            .receive(on: RunLoop.main)
            .assign(to: \.locationStatus, on: self)
            .store(in: &cancellables)
            
        locationService.$monitoredRegions
            .map { $0.count }
            .receive(on: RunLoop.main)
            .assign(to: \.monitoredRegionsCount, on: self)
            .store(in: &cancellables)
            
        notificationService.$authorizationStatus
            .receive(on: RunLoop.main)
            .assign(to: \.notificationStatus, on: self)
            .store(in: &cancellables)
    }
    
    func requestLocationPermission() {
        locationService.requestAlwaysPermission()
    }
    
    func requestNotificationPermission() {
        Task {
            _ = await notificationService.requestPermissions()
        }
    }
    
    func logout() {
        authService.logout()
    }
}
