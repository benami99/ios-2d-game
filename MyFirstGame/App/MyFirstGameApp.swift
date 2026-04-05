//
//  MyFirstGameApp.swift
//  MyFirstGame
//
//  Created by Noam on 21/03/2026.
//

import SwiftUI

// App entry point: iOS starts here and asks for the app’s scenes.
@main
struct MyFirstGameApp: App {
    // One main window; its SwiftUI content is ContentView (which hosts SpriteKit).
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
