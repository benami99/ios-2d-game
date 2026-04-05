//
//  ContentView.swift
//  MyFirstGame
//
//  Created by Noam on 21/03/2026.
//

import SpriteKit
import SwiftUI

struct ContentView: View {

    @State private var gameMode: PongGameMode = .twoPlayers
    @State private var scene: PongScene = PongScene(gameMode: .twoPlayers)

    var body: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $gameMode) {
                Text("1 vs AI").tag(PongGameMode.onePlayerVsAI)
                Text("2 players").tag(PongGameMode.twoPlayers)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .onChange(of: gameMode) { _, newMode in
                scene = PongScene(gameMode: newMode)
            }

            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
