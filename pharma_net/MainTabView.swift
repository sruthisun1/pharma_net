import SwiftUI

struct MainTabView: View {
    
    let userID: String
    @StateObject private var graph = AdjacencyList<String>()
    
    
    
    
    var body: some View {
        TabView {
            DrugResultsView(userID: userID)
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Database")
                }
            
            VisualView(graph: graph)
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                    Text("Visual")
                }
            
            ScannerView()
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scanner")
                }
            MapsView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Maps")
                            }
            ProfileView()
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

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
// Keep your existing views




struct ScannerView: View {
    var body: some View {
        NavigationView {
            Text("Scanner")
        }
        .navigationBarHidden(true)
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("User Profile")
        }
        .navigationBarHidden(true)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(userID: "1")
    }
}
