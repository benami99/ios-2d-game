//
//  GameHUDView.swift
//  MyFirstGame
//

import SwiftUI

/// Score + pause / menu / game-over controls (Phase 6).
struct GameHUDView: View {

    @ObservedObject var bridge: PongGameBridge
    let gameMode: PongGameMode

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                scoreBar
                controlBar
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            fullScreenOverlays
        }
    }

    @ViewBuilder
    private var fullScreenOverlays: some View {
        if bridge.flowState == .paused {
            pausedOverlay
        } else if bridge.flowState == .menu {
            menuOverlay
        } else if bridge.flowState == .gameOver, let winner = bridge.matchWinner {
            gameOverOverlay(winner: winner)
        }
    }

    private var scoreBar: some View {
        HStack {
            Text("\(bridge.leftScore)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
            Spacer()
            Text("\(bridge.rightScore)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
        }
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            if bridge.flowState == .playing {
                Button("Pause") { bridge.pause() }
                    .buttonStyle(.borderedProminent)
                Button("Menu") { bridge.goToMenu() }
                    .buttonStyle(.bordered)
            } else if bridge.flowState == .paused {
                Button("Resume") { bridge.resume() }
                    .buttonStyle(.borderedProminent)
                Button("Menu") { bridge.goToMenu() }
                    .buttonStyle(.bordered)
            } else if bridge.flowState == .menu {
                Button("Play") { bridge.playFromMenu() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.top, 4)
    }

    private var pausedOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            Text("Paused")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(.white)
        }
        .allowsHitTesting(false)
    }

    private var menuOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Pong")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Tap Play to resume")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                Button("Play") { bridge.playFromMenu() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func gameOverOverlay(winner: PongSide) -> some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Game Over")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text(winnerTitle(for: winner))
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                HStack(spacing: 16) {
                    Button("Restart") { bridge.restartMatch() }
                        .buttonStyle(.borderedProminent)
                    Button("Menu") {
                        bridge.matchWinner = nil
                        bridge.goToMenu()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
        }
    }

    private func winnerTitle(for winner: PongSide) -> String {
        switch (gameMode, winner) {
        case (.onePlayerVsAI, .left): return "AI wins"
        case (.onePlayerVsAI, .right): return "You win"
        case (.twoPlayers, .left): return "Left player wins"
        case (.twoPlayers, .right): return "Right player wins"
        }
    }
}
