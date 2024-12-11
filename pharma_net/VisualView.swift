import SwiftUI

struct VisualView: View {
    @ObservedObject var graph: AdjacencyList<String>
    @State private var newVertexName: String = ""
    @State private var errorMessage: String? = nil
    @State private var showSeverityAlert: Bool = false
    @State private var severityMessage: String = ""
    let userID: String
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar at top
                HStack {
                    TextField("Enter drug name", text: $newVertexName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: addVertex) {
                        Text("Add Drug")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // Graph view
                GeometryReader { geometry in
                    let layout = generateLayout(for: graph.adjacencyDict.keys.map { $0 }, in: geometry.size)

                    ZStack {
                        // Draw edges
                        ForEach(graph.edges(), id: \.self) { edge in
                            if let sourcePosition = layout[edge.source],
                               let destinationPosition = layout[edge.destination] {
                                // Determine the line color based on the weight
                                let lineColor: Color = {
                                    if let weight = edge.weight {
                                        return weight > 1.5 ? .red : .orange
                                    } else {
                                        return .black // Default color if weight is missing
                                    }
                                }()

                                Path { path in
                                    path.move(to: sourcePosition)
                                    path.addLine(to: destinationPosition)
                                }
                                .stroke(lineColor, lineWidth: 2)

                                if let weight = edge.weight {
                                    Text(weight > 1.5 ? "Major" : "Moderate")
                                        .font(.caption)
                                        .foregroundColor(weight > 1.5 ? .red : .orange) // Match text color with line color
                                        .position(midpoint(from: sourcePosition, to: destinationPosition))
                                }
                            }
                        }

                        // Draw vertices
                        ForEach(graph.vertices(), id: \.self) { vertex in
                            if let position = layout[vertex] {
                                Circle()
                                    .fill(Color.blue.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                    .position(position)
                                
                                Text(vertex.data)
                                    .foregroundColor(.black)
                                    .font(.caption)
                                    .position(position)
                            }
                        }
                    }
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                // Save Drug Combination Button
                Button(action: saveDrugCombination) {
                    Text("Save Drug Combination")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .alert(isPresented: $showSeverityAlert) {
            Alert(
                title: Text("Drug Interaction Alert"),
                message: Text(severityMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarHidden(true)
    }
    
    private func addVertex() {
        guard !newVertexName.isEmpty else { return }
        
        // Add the new drug vertex to the graph
        graph.createVertex(data: newVertexName)
        
        // Call checkInteractions to update the graph with potential drug interactions
        checkInteractions()
        
        // Call checkNewDrugInteraction for the new drug added
        checkNewDrugInteraction(userID: userID, drugName: newVertexName)
        
        // Clear the text field for new input
        newVertexName = ""
    }
    
    private func saveDrugCombination() {
        // Fetch all drug names from the graph
        let drugNames = graph.vertices().map { $0.data }
        
        // Call the NetworkManager to save the combination
        NetworkManager.saveCombination(userID: Int(userID) ?? 0, drugNames: drugNames) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to save combination: \(error.localizedDescription)"
                } else if success {
                    self.errorMessage = "Combination saved successfully!"
                } else {
                    self.errorMessage = "Failed to save combination."
                }
            }
        }
    }
    
    private func checkInteractions() {
        let drugs = graph.vertices().map { $0.data }
        
        NetworkManager.checkDrugInteractions(drugs: drugs) { results, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            } else if let results = results {
                DispatchQueue.main.async {
                    for interaction in results {
                        let sourceVertex = Vertex(data: interaction.drug1)
                        let destVertex = Vertex(data: interaction.drug2)
                        
                        // Add edge with weight based on severity
                        let weight = interaction.severity == "Major" ? 2.0 : 1.0
                        graph.add(.undirected, from: sourceVertex, to: destVertex, weight: weight)
                    }
                }
            }
        }
    }
    
    private func checkNewDrugInteraction(userID: String, drugName: String) {
        NetworkManager.fetchNewDrugInteractions(userID: userID, drugName: drugName) { hasModerateOrMajor, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Display an error message if the API call fails
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                if hasModerateOrMajor {
                    // Display the popup if the severity is "Moderate" or "Major"
                    self.severityMessage = "The drug \(drugName) has a moderate or major interaction with your current drug history"
                    self.showSeverityAlert = true
                }
            }
        }
    }

    private func midpoint(from: CGPoint, to: CGPoint) -> CGPoint {
        CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
    }
}
