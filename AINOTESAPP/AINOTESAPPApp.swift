//
//  AINOTESAPPApp.swift
//  AINOTESAPP
//
//  Created by Riya Shukla on 02/10/25.
//

import SwiftUI

@main
struct AINOTESAPPApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
