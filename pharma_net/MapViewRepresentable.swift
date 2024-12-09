import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var locationManager = LocationManagers() // Use your existing LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator // Set the delegate to the Coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow // Keeps the user centered
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // When user location changes, update the map region
        if let location = locationManager.userLocation {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            uiView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator to handle MKMapViewDelegate events
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
    }
}
