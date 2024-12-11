import SwiftUI
import Combine

// Model for Search Result
struct SearchResult: Identifiable, Codable {
    let id = UUID()
    let drugName: String
}

// ViewModel for Search Functionality
class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var drugHistory: [DrugHistoryItem] = []
    @Published var isLoading = false
    private var searchTextPublisher = CurrentValueSubject<String, Never>("")
    private var cancellable: AnyCancellable?

    func searchDrugs(_ searchText: String) {
        print("Search triggered with text: \(searchText)")
        searchTextPublisher.send(searchText)

        cancellable?.cancel()

        cancellable = searchTextPublisher
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                print("Debounced text: \(text)")
                self?.isLoading = true
                NetworkManager.searchDrugs(text) { results in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if let results = results {
                            print("Results received (\(results.count) items): \(results.map { $0.drugName })")
                            self?.searchResults = results.unique(by: \SearchResult.drugName)
                        } else {
                            print("No results or error occurred")
                            self?.searchResults = []
                        }
                    }
                }
            }
    }

    func fetchDrugHistory(userID: String) {
        print("Fetching drug history for userID: \(userID)")
        NetworkManager.fetchDrugHistory(userID: userID) { [weak self] history, error in
            if let history = history {
                DispatchQueue.main.async {
                    self?.drugHistory = history
                    print("Drug history fetched: \(history)")
                }
            } else {
                print("Failed to fetch drug history: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func removeDrugFromHistory(historyID: Int, completion: @escaping (Bool) -> Void) {
        print("Removing historyID: \(historyID)")
        NetworkManager.deleteDrugHistoryEntry(historyID: historyID) { success, error in
            if success {
                print("Successfully removed historyID: \(historyID) from the database.")
                completion(true)
            } else {
                print("Failed to remove historyID: \(historyID): \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
    }
}

// Extension to Filter Unique Elements
extension Array {
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return self.filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

// Search Bar Component
struct SearchBar: View {
    @Binding var searchText: String
    let onSearchTextChanged: (String) -> Void

    var body: some View {
        HStack {
            TextField("Drug Search", text: $searchText)
                .onChange(of: searchText) { newValue in
                    onSearchTextChanged(newValue)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    print("Search cleared")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Main Search View
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    let userID: String

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Search Bar
                SearchBar(searchText: $searchText) { text in
                    viewModel.searchDrugs(text)
                }

                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if searchText.isEmpty {
                    Text("Enter a search term to begin.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else if viewModel.searchResults.isEmpty {
                    Text("No results found.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    List(viewModel.searchResults) { result in
                        HStack {
                            Text(result.drugName)
                            Spacer()
                            Button(action: {
                                addDrugToList(result)
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }

                if !viewModel.drugHistory.isEmpty {
                    Text("Drug History")
                        .font(.headline)
                        .padding(.top)

                    List(viewModel.drugHistory) { item in
                        VStack(alignment: .leading, spacing: 12) {
                            // Drug Details Section
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.drugName)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    HStack(spacing: 12) {
                                        Text(item.start)
                                            .frame(width: 100, alignment: .leading)
                                        Text((item.end == "0000-00-00" || item.end == "N/A") ? "Present" : item.end ?? "Unknown")
                                            .frame(width: 100, alignment: .leading)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle()) // Ensure only this part is clickable
                            .onTapGesture {
                                print("Drug details tapped: \(item.drugName)")
                            }

                            // Buttons Section (Discontinue and Remove on the same row)
                            HStack(spacing: 16) {
//                                Spacer()
//                                Push buttons to the right

                                // Discontinue Button
                                Button(action: {
//                                    discontinueDrug(item)
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "xmark.circle")
                                            .foregroundColor(.orange)
                                        Text("Discontinue")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(6)
                                    .onTapGesture {
                                        discontinueDrug(item)
                                    }
                                }
                                .contentShape(Rectangle()) // Ensure only this button is clickable
//                                .onTapGesture {
//                                    discontinueDrug(item)
//                                }

                                // Remove Button
                                HStack {
                                    Spacer() // Push button to the right
                                    Button(action: {
//                                        removeDrugFromList(item)
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(.red)
                                            Text("Remove")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(6)
                                        .onTapGesture {
                                            removeDrugFromList(item)
                                        }
                                    }
                                    .contentShape(Rectangle()) // Ensure only button area is tappable
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .listStyle(PlainListStyle())
                    .padding(.horizontal)




                }
            }
            .padding()
            .navigationTitle("Search Drugs")
            .frame(maxHeight: .infinity, alignment: .top)
            .onAppear {
                viewModel.fetchDrugHistory(userID: userID)
            }
        }
    }

    private func addDrugToList(_ drug: SearchResult) {
        print("Attempting to add drug: \(drug.drugName) for userID: \(userID)")
        NetworkManager.addDrugToDatabase(userID: Int(userID)!, drugName: drug.drugName) { success, error in
            if success {
                print("Successfully added \(drug.drugName) to the database.")
                viewModel.fetchDrugHistory(userID: userID)
            } else {
                print("Failed to add \(drug.drugName): \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func removeDrugFromList(_ item: DrugHistoryItem) {
        viewModel.removeDrugFromHistory(historyID: item.historyID) { success in
            if success {
                viewModel.fetchDrugHistory(userID: userID) // Refresh drug history
            }
        }
    }
    private func discontinueDrug(_ item: DrugHistoryItem) {
        print("Discontinuing drug with historyID: \(item.historyID)")
        NetworkManager.updateEndDate(historyID: item.historyID) { success, error in
            if success {
                print("Successfully updated end date for drug with historyID: \(item.historyID)")
                viewModel.fetchDrugHistory(userID: userID) // Refresh drug history
            } else {
                print("Failed to update end date: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

// Preview for SwiftUI Canvas
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(userID: "1")
    }
}

