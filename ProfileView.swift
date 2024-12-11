import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var drugSeverityCounts: [DrugSeverityCount] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    private let userID: Int

    init(userID: Int) {
        self.userID = userID
    }

    func fetchSevereInteractions() {
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
    @StateObject private var viewModel: ProfileViewModel

    init(userID: Int) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userID: userID))
    }

    var body: some View {
        VStack {
            if !viewModel.drugSeverityCounts.isEmpty {
                List(viewModel.drugSeverityCounts) { drugSeverityCount in
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
            viewModel.fetchSevereInteractions()
        }
    }
}

