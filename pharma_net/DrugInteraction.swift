//
//  DrugInteraction.swift
//  pharma_net
//
//  Created by Aryan Kunjir on 12/8/24.
//

import Foundation

struct DrugInteraction: Decodable {
    let drug1: String
    let drug2: String
    let severity: String
}
