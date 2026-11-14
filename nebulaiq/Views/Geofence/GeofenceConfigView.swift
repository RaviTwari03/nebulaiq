import SwiftUI
import MapKit
import CoreLocation

struct GeofenceConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared
    @StateObject private var viewModel: GeofenceConfigViewModel
    
    @State private var cameraPosition: MapCameraPosition
    
    init(group: TrackingGroup) {
        let vm = GeofenceConfigViewModel(group: group)
        _viewModel = StateObject(wrappedValue: vm)
        
        let initialRegion = MKCoordinateRegion(
            center: vm.centerCoordinate,
            latitudinalMeters: max(vm.radiusMeters * 3, 1000),
            longitudinalMeters: max(vm.radiusMeters * 3, 1000)
        )
        _cameraPosition = State(initialValue: .region(initialRegion))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Interactive Map View with Circle Overlay
                ZStack {
                    Map(position: $cameraPosition) {
                        MapCircle(center: viewModel.centerCoordinate, radius: viewModel.radiusMeters)
                            .foregroundStyle(Color.blue.opacity(0.2))
                            .stroke(Color.blue, lineWidth: 2)
                        
                        Annotation(viewModel.name, coordinate: viewModel.centerCoordinate) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "mappin")
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
                    
                    // User location center button
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                viewModel.centerOnUserLocation()
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: viewModel.centerCoordinate,
                                    latitudinalMeters: max(viewModel.radiusMeters * 3, 1000),
                                    longitudinalMeters: max(viewModel.radiusMeters * 3, 1000)
                                ))
                            } label: {
                                Image(systemName: "location.fill")
                                    .padding(10)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 16)
                        }
                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Configuration Controls
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Zone Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Name", text: $viewModel.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Boundary Radius")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(viewModel.radiusMeters)) meters")
                                .font(.subheadline.weight(.semibold))
                        }
                        
                        Slider(
                            value: $viewModel.radiusMeters,
                            in: AppConfig.minGeofenceRadiusMeters...AppConfig.maxGeofenceRadiusMeters,
                            step: 25
                        )
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Center Coordinates")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.4f", viewModel.centerCoordinate.latitude)), \(String(format: "%.4f", viewModel.centerCoordinate.longitude))")
                                .font(.caption.monospaced())
                        }
                        
                        Spacer()
                        
                        Button {
                            guard let user = authService.currentUser else { return }
                            Task {
                                let success = await viewModel.saveGeofence(creatorId: user.id)
                                if success {
                                    dismiss()
                                }
                            }
                        } label: {
                            if viewModel.isSaving {
                                ProgressView()
                            } else {
                                Text("Save Geofence")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSaving)
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemBackground))
            }
            .navigationTitle("Configure Geofence")
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
