import SwiftUI

struct MainTabView: View {
    
    let userID: Int
    @StateObject private var graph = AdjacencyList<String>()
    
    
    var body: some View {
        TabView {
            DrugResultsView(userID: String(userID))
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Database")
                }
            
            VisualView(graph: graph, userID:String(userID))
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                    Text("Visual")
                }
            
            SearchView(userID: String(userID))
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            MapsView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Maps")
                            }
            ProfileView(userID: userID)
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

//struct SearchView: View {
//    var body: some View {
//        NavigationView {
//            Text("SearchView")
//        }
//        .navigationBarHidden(true)
//    }
//}

//struct ProfileView: View {
//    var body: some View {
//        NavigationView {
//            Text("User Profile")
//        }
//        .navigationBarHidden(true)
//    }
//}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(userID: 1)
    }
}


