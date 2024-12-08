//
//  LocationManager.swift
//  pharma_net
//
//  Created by Claire on 12/8/24.
//

import Foundation
// LocationManager.swift
import Foundation
import CoreLocation
import GoogleMaps

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

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
