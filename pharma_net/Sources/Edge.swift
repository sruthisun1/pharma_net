//
//  Edge.swift
//  pharma_net
//
//  Created by Aryan Kunjir on 12/7/24.
//

import Foundation
public enum EdgeType {
    case directed, undirected
}

public struct Edge<T: Hashable> {
    public var source: Vertex<T>
    public var destination: Vertex<T>
    public var weight: Double?
}

extension Edge: Hashable {
    public var hashValue: Int {
        return "\(source)\(destination)\(String(describing: weight))".hashValue
    }
    static public func ==(e1: Edge<T>, e2: Edge<T>) -> Bool {
        return e1.source == e2.source && e1.destination == e2.destination && e1.weight == e2.weight
    }
    
}
