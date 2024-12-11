import SwiftUI
import CoreData

struct ContentView: View {
    @State private var userID = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to PharmaNet")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Enter User ID", text: $userID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 50)
                    .keyboardType(.numberPad)
                
                NavigationLink(destination: MainTabView(userID: Int(userID) ?? 0)) {
                    Text("View Drug Results")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding()
                }
                .disabled(userID.isEmpty)  
            }
            .navigationBarTitle("PharmaNet", displayMode: .inline)
        }
    }
}
