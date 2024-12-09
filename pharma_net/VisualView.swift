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
        graph.createVertex(data: newVertexName)
        checkInteractions()
        newVertexName = ""
    }
    
    private func checkInteractions() {
        let drugs = graph.vertices().map { $0.data }
//        print("Checking interactions for drugs: \(drugs)")  // Debug print
        
        NetworkManager.checkDrugInteractions(drugs: drugs) { results, error in
            if let error = error {
//                print("Error checking interactions: \(error)")  // Debug print
                self.errorMessage = error.localizedDescription
            } else if let results = results {
//                print("Received interactions: \(results)")  // Debug print
                // Update graph edges based on interactions
                for interaction in results {
                    let sourceVertex = Vertex(data: interaction.drug1)
                    let destVertex = Vertex(data: interaction.drug2)
                    
                    // Add edge with weight based on severity
                    let weight = interaction.severity == "Major" ? 2.0 : 1.0
                    graph.add(.undirected, from: sourceVertex, to: destVertex, weight: weight)
//                    print("Added edge between \(interaction.drug1) and \(interaction.drug2)")  // Debug print
                }
            }
        }
    }
    
    private func checkNewDrugInteraction(userID: String, drugName: String) {
        NetworkManager.fetchNewDrugInteractions(userID: userID, drugName: drugName) { results, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching drug interactions: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            if let results = results, !results.isEmpty {
                print("Received results: \(results)") // Debug print
                if results.contains(where: { $0.severity.trimmingCharacters(in: .whitespacesAndNewlines) == "Moderate" || $0.severity.trimmingCharacters(in: .whitespacesAndNewlines) == "Severe" }) {
                    DispatchQueue.main.async {
                        print("Setting alert for severity: \(results)") // Debug print
                        self.severityMessage = "The drug \(drugName) has interactions with severity: Moderate or Severe."
                        self.showSeverityAlert = true
                    }
                } else {
                    print("No Moderate or Severe interactions found.") // Debug print
                }
            } else {
                DispatchQueue.main.async {
                    print("Results are empty or nil.") // Debug print
                }
            }
        }
    }

    
    
    private func midpoint(from: CGPoint, to: CGPoint) -> CGPoint {
        CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
    }
}
