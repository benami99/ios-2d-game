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
            VStack(spacing: 0) {
                Picker("Mode", selection: $gameMode) {
                    Text("1 vs AI").tag(PongGameMode.onePlayerVsAI)
                    Text("2 players").tag(PongGameMode.twoPlayers)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onChange(of: gameMode) { _, newMode in
                    scene = PongScene(gameMode: newMode, bridge: bridge)
                }

                SpriteView(scene: scene)
                    .ignoresSafeArea()
            }

            GameHUDView(bridge: bridge, gameMode: gameMode)
        }
    }
}

#Preview {
    ContentView()
}
