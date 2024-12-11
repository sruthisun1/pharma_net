//
//  DrugHistoryItem.swift
//  pharma_net
//
//  Created by Aryan Kunjir on 12/11/24.
//

import Foundation

struct DrugHistoryItem: Identifiable, Codable {
    let id =  UUID()
    let historyID: Int
    let drugName: String
    let start: String
    let end: String?
}
