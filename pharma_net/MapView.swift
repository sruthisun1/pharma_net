//
//  MapView.swift
//  pharma_net
//
//  Created by Claire on 12/7/24.
//

import Foundation
// MapsView.swift
import SwiftUI
import GoogleMaps

struct MapsView: View {
    @StateObject private var locationManager = LocationManager()
    
    // Default camera position (in case we don't have a location)
    private var defaultCameraPosition = GMSCameraPosition(latitude: 40.1164, longitude: -88.2434, zoom: 15, bearing: 0, viewingAngle: 0)

    var body: some View {
        VStack {
            if let userLocation = locationManager.userLocation {
                GoogleMapView(
                    cameraPosition: GMSCameraPosition(target: userLocation, zoom: 15, bearing: 0, viewingAngle: 0),
                    isMyLocationEnabled: true,
                    myLocationButton: true
                )
                .onAppear {
                    locationManager.startUpdatingLocation()
                }
            } else {
                Text("Waiting for location...")
            }
        }
        .edgesIgnoringSafeArea(.all)  // Ensure the map fills the screen
    }
}
