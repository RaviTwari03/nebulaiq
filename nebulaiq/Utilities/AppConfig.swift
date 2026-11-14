import Foundation

enum AppConfig {
    static let appName = "GeoCircle"
    static let appVersion = "1.0.0"
    
    // Supabase Configuration
    // In production, these can also be loaded from Info.plist or environment
    static var supabaseURL: URL {
        URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://placeholder-project.supabase.co")!
    }
    
    static var supabaseAnonKey: String {
        ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "placeholder-anon-key"
    }
    
    // CoreLocation limits
    static let maxMonitoredRegions = 20
    static let defaultGeofenceRadiusMeters: Double = 150.0
    static let minGeofenceRadiusMeters: Double = 50.0
    static let maxGeofenceRadiusMeters: Double = 2000.0
}
