import SwiftUI


class ProfileViewModel: ObservableObject {
    @Published var drugSeverityCounts: [DrugSeverityCount] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func fetchSevereInteractions(userID: Int) {
        isLoading = true
        NetworkManager.countSevereInteractions(userID: userID) { results, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error fetching severe interactions: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                } else if let results = results {
                    print("Fetched severe interactions: \(results)")
                    self.drugSeverityCounts = results
                }
            }
        }
    }
}

struct ProfileView: View {
    @State private var drugSeverityCounts: [DrugSeverityCount] = []

    var body: some View {
        VStack {
            if !drugSeverityCounts.isEmpty {
                List(drugSeverityCounts) { drugSeverityCount in
                    HStack {
                        Text(drugSeverityCount.drug)
                        Spacer()
                        Text("\(drugSeverityCount.interactionCount) severe interactions")
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            NetworkManager.countSevereInteractions(userID: 54) { results, error in
                if let results = results {
                    self.drugSeverityCounts = results
                } else if let error = error {
                    print("Error fetching severe interactions: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

