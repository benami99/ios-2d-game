//
//  ContentView.swift
//  MyFirstGame
//
//  Created by Noam on 21/03/2026.
//

import SpriteKit
import SwiftUI

struct ContentView: View {

    @StateObject private var bridge = PongGameBridge()
    @State private var gameMode: PongGameMode = .twoPlayers
    @State private var scene: PongScene

    init() {
        let b = PongGameBridge()
        _bridge = StateObject(wrappedValue: b)
        _scene = State(initialValue: PongScene(gameMode: .twoPlayers, bridge: b))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // `id` forces a new `SpriteView` host when mode changes; otherwise the view can keep a stale scene (e.g. still in 2-player touch routing).
            SpriteView(scene: scene)
                .id(gameMode)
                .ignoresSafeArea()

            GameHUDView(bridge: bridge, gameMode: $gameMode)
        }
        .onChange(of: gameMode) { _, newMode in
            scene = PongScene(gameMode: newMode, bridge: bridge)
        }
    }
}

#Preview {
    ContentView()
}
