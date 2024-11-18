//
//  pharma_netApp.swift
//  pharma_net
//
//  Created by Sruthi Sundar on 11/14/24.
//

import SwiftUI

@main
struct pharma_netApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
}

