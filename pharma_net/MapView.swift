//
//  MapView.swift
//  pharma_net
//
//  Created by Claire on 12/7/24.
//

import Foundation

import SwiftUI
import MapKit

//struct MapsView: View {
//    @StateObject private var locationManager = LocationManager()  // Initialize the LocationManager
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
