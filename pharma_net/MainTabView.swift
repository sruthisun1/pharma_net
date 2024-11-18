import SwiftUI

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
            
            ProfileView()
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

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
