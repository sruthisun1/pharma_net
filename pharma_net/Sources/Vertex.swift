//
//  Vertex.swift
//  pharma_net
//
//  Created by Aryan Kunjir on 12/7/24.
//

import Foundation
public struct Vertex<T: Hashable> {
    var data: T
}

extension Vertex: Hashable {
    public var hashValue: Int {
        return "\(data)".hashValue
    }
    
    static public func ==(v1: Vertex, v2: Vertex) -> Bool {
        return v1.data == v2.data
    }
}

extension Vertex: CustomStringConvertible {
    public var description: String {
        return "\(data)"
    }
}
