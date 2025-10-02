//
//  AINotesAppApp.swift
//  AINotesApp
//

import SwiftUI
import FirebaseCore

@main
struct AINotesAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
