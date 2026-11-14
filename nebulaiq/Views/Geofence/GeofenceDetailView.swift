import SwiftUI
import MapKit
import CoreLocation

struct GeofenceDetailView: View {
    let geofence: Geofence
    let group: TrackingGroup
    
    @State private var cameraPosition: MapCameraPosition
    
    init(geofence: Geofence, group: TrackingGroup) {
        self.geofence = geofence
        self.group = group
        
        let region = MKCoordinateRegion(
            center: geofence.coordinate,
            latitudinalMeters: max(geofence.radiusMeters * 3, 1000),
            longitudinalMeters: max(geofence.radiusMeters * 3, 1000)
        )
        _cameraPosition = State(initialValue: .region(region))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Map(position: $cameraPosition) {
                MapCircle(center: geofence.coordinate, radius: geofence.radiusMeters)
                    .foregroundStyle(Color.green.opacity(0.2))
                    .stroke(Color.green, lineWidth: 2)
                
                Annotation(geofence.name, coordinate: geofence.coordinate) {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 32, height: 32)
                        Image(systemName: "location.fill")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .frame(maxHeight: .infinity)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(geofence.name)
                            .font(.title3.weight(.bold))
                        Text("Group: \(group.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Label("Active", systemImage: "antenna.radiowaves.left.and.right")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .clipShape(Capsule())
                }
                
                Divider()
                
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Radius")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(geofence.radiusMeters)) meters")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monitoring")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Background")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trigger")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Exit Alert")
                            .font(.headline)
                    }
                }
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .navigationTitle(geofence.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
