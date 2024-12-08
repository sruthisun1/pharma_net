//
//  GraphLayout.swift
//  pharma_net
//
//  Created by Aryan Kunjir on 12/7/24.
//

import Foundation

func generateLayout<T: Hashable>(for vertices: [Vertex<T>], in size: CGSize) -> [Vertex<T>: CGPoint] {
    let centerX = size.width / 2
    let centerY = size.height / 2
    let radius = min(size.width, size.height) / 3
    let angleStep = 2 * .pi / CGFloat(vertices.count)
    
    var layout: [Vertex<T>: CGPoint] = [:]
    for (index, vertex) in vertices.enumerated() {
        let angle = angleStep * CGFloat(index)
        let x = centerX + radius * cos(angle)
        let y = centerY + radius * sin(angle)
        layout[vertex] = CGPoint(x: x, y: y)
    }
    return layout
}
