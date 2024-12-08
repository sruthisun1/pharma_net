//
//  VisualView.swift
//  pharma_net
//
//  Created by Aryan Kunjir on 12/7/24.
//

import SwiftUI
struct VisualView: View {
    @ObservedObject var graph: AdjacencyList<String>
    @State private var newVertexName: String = ""
    var body: some View {
        NavigationView {
            
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
                                    .stroke(Color.blue, lineWidth: 2)
                                    
                                    // Display weight
                                    if let weight = edge.weight {
                                        Text("$\(Int(weight))")
                                            .font(.caption)
                                            .foregroundColor(.green)
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
                                    
                                    Text("\(vertex.data)")
                                        .foregroundColor(.black)
                                        .font(.caption)
                                        .position(position)
                                }
                            }
                        }.frame(height: 400)
                
                HStack {
                                TextField("Enter vertex name", text: $newVertexName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()

                                Button(action: addVertex) {
                                    Text("Add Vertex")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                
                    
                
                    }
        }
        .navigationBarHidden(true)
    }
    private func addVertex() {
            guard !newVertexName.isEmpty else { return }
            graph.createVertex(data: newVertexName) // Add the new vertex to the graph
            newVertexName = "" // Clear the text field
        }
}



private func midpoint(from: CGPoint, to: CGPoint) -> CGPoint {
        CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
    }
