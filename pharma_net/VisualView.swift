
import SwiftUI

struct VisualView: View {
    @ObservedObject var graph: AdjacencyList<String>
    @State private var newVertexName: String = ""
    @State private var errorMessage: String? = nil
    
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
                                Path { path in
                                    path.move(to: sourcePosition)
                                    path.addLine(to: destinationPosition)
                                }
                                .stroke(Color.red, lineWidth: 2)
                                
                                if let weight = edge.weight {
                                    Text(weight > 1.5 ? "Major" : "Moderate")
                                        .font(.caption)
                                        .foregroundColor(.red)
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
        print("Checking interactions for drugs: \(drugs)")  // Debug print
        
        NetworkManager.checkDrugInteractions(drugs: drugs) { results, error in
            if let error = error {
                print("Error checking interactions: \(error)")  // Debug print
                self.errorMessage = error.localizedDescription
            } else if let results = results {
                print("Received interactions: \(results)")  // Debug print
                // Update graph edges based on interactions
                for interaction in results {
                    let sourceVertex = Vertex(data: interaction.drug1)
                    let destVertex = Vertex(data: interaction.drug2)
                    
                    // Add edge with weight based on severity
                    let weight = interaction.severity == "Major" ? 2.0 : 1.0
                    graph.add(.undirected, from: sourceVertex, to: destVertex, weight: weight)
                    print("Added edge between \(interaction.drug1) and \(interaction.drug2)")  // Debug print
                }
            }
        }
    }
    
    private func midpoint(from: CGPoint, to: CGPoint) -> CGPoint {
        CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
    }
}

