import SwiftUI
import MapKit

struct MainTabView: View {
    let userID: String
    
    var body: some View {
        TabView {
            DrugResultsView(userID: userID)
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Database")
                }
            
            VisualView()
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
                .navigationBarBackButtonHidden(true)
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

// Add new MapsView
struct MapsView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3361, longitude: -121.8907),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
}

// Keep your existing views
struct VisualView: View {
    var body: some View {
        NavigationView {
            Text("Visual Analytics")
        }
        .navigationBarHidden(true)
    }
}

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
