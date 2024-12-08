//
//  clairemap.swift
//  pharma_net
//
//  Created by Claire on 12/8/24.
//

import Foundation
// YourAppNameApp.swift
import SwiftUI
import GoogleMaps
import GooglePlaces

@main
struct YourAppNameApp: App {
    init() {
        // Set up Google Maps API keys
        GMSServices.provideAPIKey("AIzaSyCNcYUEURD7DSk6qksdKyp63w-ZetdWQZc")
        GMSPlacesClient.provideAPIKey("AIzaSyCNcYUEURD7DSk6qksdKyp63w-ZetdWQZc")
    }

    var body: some Scene {
        WindowGroup {
            MapsView()
        }
    }
}
