import SwiftUI
import MapKit

struct MapsView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.pharmacies) { pharmacy in
                // Custom annotation with tap and long-press gestures
                MapAnnotation(coordinate: pharmacy.coordinate) {
                    VStack {
                        if viewModel.selectedPharmacy?.id == pharmacy.id {
                            Text(pharmacy.name)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                            .onTapGesture {
                                viewModel.selectedPharmacy = pharmacy
                            }
                            .onLongPressGesture {
                                viewModel.openInAppleMaps(pharmacy: pharmacy)
                            }
                    }
                }
            }
            .ignoresSafeArea()
            .accentColor(Color(.systemPurple))
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
            }
        }
        .navigationBarHidden(true)
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37, longitude: 37),
                                               span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @Published var pharmacies: [Landmark] = []
    @Published var selectedPharmacy: Landmark?
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        } else {
            print("Location services are not enabled")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location use is restricted (e.g., parental controls)")
        case .denied:
            print("You have denied location permissions for this app")
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = locationManager.location {
                region = MKCoordinateRegion(center: location.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                fetchNearbyPharmacies(for: location.coordinate)
            }
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func fetchNearbyPharmacies(for coordinate: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Pharmacy"
        request.region = MKCoordinateRegion(center: coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else {
                print("Error fetching nearby pharmacies: \(String(describing: error))")
                return
            }
            
            self?.pharmacies = response.mapItems.map { item in
                Landmark(name: item.name ?? "Unknown", coordinate: item.placemark.coordinate)
            }
        }
    }
    
    func openInAppleMaps(pharmacy: Landmark) {
        let destination = MKPlacemark(coordinate: pharmacy.coordinate)
        let mapItem = MKMapItem(placemark: destination)
        mapItem.name = pharmacy.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

struct Landmark: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
