import SwiftUI

struct DrugResultsView: View {
    let userID: String
    @State private var drugResults: [DrugResult] = []
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView { 
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Text("Current Drug")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.8))
                        )
                    
                    Text("Safer Alternative")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.8))
                        )
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)
                
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(drugResults, id: \.CurrentDrug) { drug in
                        HStack {
                            Text(drug.CurrentDrug)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.body)
                            
                            Divider()
                            
                            Text(drug.SaferAlternative)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .onAppear {
            fetchDrugResults(forUserID: userID)
        }
    }
    
    func fetchDrugResults(forUserID: String) {
        NetworkManager.fetchDrugResults(userID: forUserID) { results, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            if let results = results {
                DispatchQueue.main.async {
                    self.drugResults = results
                }
            }
        }
    }
}
