//
//  DrugSeverityCount.swift
//  pharma_net
//
//  Created by Sruthi Sundar on 12/8/24.
//

import Foundation

struct DrugSeverityCount: Identifiable, Codable {
    let id = UUID()
    let drug: String
    let interactionCount: Int

    enum CodingKeys: String, CodingKey {
        case drug = "Drug"
        case interactionCount = "InteractionCount"
    }
}

