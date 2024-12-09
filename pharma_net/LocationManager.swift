import Foundation
import CoreLocation

class LocationManagers: NSObject, CLLocationManagerDelegate, ObservableObject {
    private(set) var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D? // Publishes location updates
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Start updating location when authorized
    func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        userLocation = newLocation.coordinate
    }
    
    // Handle changes in authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
}


