//
//  AdjacencyList.swift
//  pharma_net
//
//  Created by Aryan Kunjir on 12/7/24.
//

import Foundation
open class AdjacencyList<T: Hashable>: ObservableObject {
    @Published public var adjacencyDict: [Vertex<T>: [Edge<T>]] = [:]
    public init () {}
    fileprivate func addDirectedEdge(from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?) {
        let edge = Edge(source: source, destination: destination, weight: weight)
        adjacencyDict[source]?.append(edge)
    }
    fileprivate func addUndirectedEdge(verticies: (Vertex<Element>, Vertex<Element>), weight: Double?) {
        let (source, destination) = verticies
        addDirectedEdge(from: source, to: destination, weight: weight)
        addDirectedEdge(from: destination, to: source, weight: weight)
    }
    
    public func vertices() -> [Vertex<T>] {
           return Array(adjacencyDict.keys)
       }
       
       public func edges() -> [Edge<T>] {
           return adjacencyDict.values.flatMap { $0 }
       }
    func clear() {
            adjacencyDict.removeAll() // Remove all vertices and edges
        }
    
}

extension AdjacencyList: CustomStringConvertible {
    public var description: String {
        var result = ""
        for (vertex, edges) in adjacencyDict {
            var edgeString = ""
            for (index, edge) in edges.enumerated() {
                if index != edges.count - 1 {
                    edgeString.append("\(edge.destination), ")
                } else {
                    edgeString.append("\(edge.destination)")
                }
            }
            result.append("\(vertex) ---> [ \(edgeString) ] \n")
        }
        return result
    }
}



extension AdjacencyList: Graphable {
    public typealias Element = T
    
    public func createVertex(data: Element) -> Vertex<Element> {
        let vertex = Vertex(data: data)
        
        if adjacencyDict[vertex] == nil {
            adjacencyDict[vertex] = []
        }
        
        return vertex
    }
    
    public func add(_ type: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?) {
        switch type {
        case .directed:
            addDirectedEdge(from: source, to:destination, weight: weight)
        case .undirected:
            addUndirectedEdge(verticies: (source, destination), weight: weight)
            
        }
    }
    
    public func weight(from source: Vertex<T>, to destination: Vertex<T>) -> Double? {
        guard let edges = adjacencyDict[source] else {
            return nil
        }
        for edge in edges {
            if edge.destination == destination{
                return edge.weight
            }
        }
        return nil
    }
    
    public func edges(from source: Vertex<T>) -> [Edge<T>]? {
        return adjacencyDict[source]
    }

    
}










