//
//  GoogleMapView.swift
//  pharma_net
//
//  Created by Claire on 12/8/24.
//
//
//import Foundation
//// GoogleMapView.swift
//import SwiftUI
//import GoogleMaps
//import CoreLocation
//
//struct GoogleMapView: UIViewRepresentable {
//    var cameraPosition: GMSCameraPosition
//    var isMyLocationEnabled: Bool
//    var myLocationButton: Bool
//
//    // Create GMSMapView
//    func makeUIView(context: Context) -> GMSMapView {
//        let mapView = GMSMapView(frame: .zero)
//        mapView.camera = cameraPosition
//        mapView.isMyLocationEnabled = isMyLocationEnabled
//        mapView.settings.myLocationButton = myLocationButton
//        return mapView
//    }
//
//    // Update the GMSMapView if any changes occur
//    func updateUIView(_ uiView: GMSMapView, context: Context) {
//        uiView.camera = cameraPosition
//        uiView.isMyLocationEnabled = isMyLocationEnabled
//        uiView.settings.myLocationButton = myLocationButton
//    }
//}
