import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager

    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isAuthorized: Bool = true

    override init() {
        self.locationManager = CLLocationManager()

        // Default location (Champaign, Illinois for example)
        let initialLocation = CLLocationCoordinate2D(latitude: 40.1164, longitude: -88.2434)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        self.region = MKCoordinateRegion(center: initialLocation, span: span)

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
    }

    // Start updating location only when authorized
    public func startUpdatingLocation() {
        // Start location updates after checking the authorization status
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        userLocation = newLocation.coordinate

        // Update region with the new location
        region = MKCoordinateRegion(
            center: newLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    // Handle errors in location updates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // Handle changes in authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            startUpdatingLocation() // Start location updates once authorized
        case .denied, .restricted:
            isAuthorized = false
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
