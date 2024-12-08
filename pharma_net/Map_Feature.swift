//
//  Map_Feature.swift
//  pharma_net
//
//  Created by Claire on 12/7/24.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isAuthorized: Bool = false

    override init() {
        self.locationManager = CLLocationManager()

        // Set default region (around San Jose, CA in this case)
        let initialLocation = CLLocationCoordinate2D(latitude: 37.3361, longitude: -121.8907)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        self.region = MKCoordinateRegion(center: initialLocation, span: span)

        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()  // Request permission to use location while app is in use
    }

    // Start updating location
    func startUpdatingLocation() {
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

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            startUpdatingLocation()  // Start location updates once authorized
        case .denied, .restricted:
            isAuthorized = false
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

//struct MapsView: View {
//    @StateObject private var locationManager = LocationManager()  // Initialize the LocationManager
//    @State private var userLocation = CLLocationCoordinate2D()  // Track user location
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                if locationManager.isAuthorized {
//                    Map(coordinateRegion: $locationManager.region, showsUserLocation: true)  // Enable the blue dot
//                        .edgesIgnoringSafeArea(.all)  // Make the map fill the screen
//                        .onAppear {
//                            locationManager.startUpdatingLocation()  // Start location updates
//                        }
//                } else {
//                    Text("Please enable location services in Settings.")  // Display message when permission is denied
//                        .padding()
//                }
//            }
//        }
//        .navigationBarHidden(true)  // Optional: Hide the navigation bar if you don't need it
//    }
//}
