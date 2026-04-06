//
//  GameHUDView.swift
//  MyFirstGame
//

import SwiftUI

/// Score + pause / menu / game-over controls (Phase 6).
struct GameHUDView: View {

    @ObservedObject var bridge: PongGameBridge
    @Binding var gameMode: PongGameMode

    var body: some View {
        ZStack {
            // Scores on the trailing edge: top score in upper half, bottom score in lower half, symmetric around vertical midline (matches court center).
            scoreBar
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                controlBar
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            fullScreenOverlays
        }
        // Cover the full window so touches don’t fall through to SpriteView (which was eating Resume taps).
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    /// `leftScore` = top player, `rightScore` = bottom player (`PongScene`). Fixed gap between scores so the court midline bisects that gap (equal offset from center to each score).
    private var scoreBar: some View {
        GeometryReader { _ in
            let padFromCenter: CGFloat = 6
            let scoreFont = Font.system(size: 36, weight: .bold, design: .rounded)

            VStack(spacing: 2 * padFromCenter) {
                Text("\(bridge.leftScore)")
                    .font(scoreFont)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text("\(bridge.rightScore)")
                    .font(scoreFont)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            if bridge.flowState == .playing {
                Button("Pause") { bridge.pause() }
                    .buttonStyle(.borderedProminent)
                Button("Exit") { bridge.goToMenu() }
                    .buttonStyle(.bordered)
            } else if bridge.flowState == .paused {
                // Resume / Menu live in `pausedOverlay` so taps aren’t delivered to SpriteView underneath.
                EmptyView()
            } else if bridge.flowState == .menu {
                // Play only in `menuOverlay` (avoids duplicate “double” Play buttons).
                EmptyView()
            }
        }
        .padding(.top, 4)
    }

    private var pausedOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { bridge.resume() }

            VStack(spacing: 20) {
                Text("Paused")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white)
                Button("Resume") { bridge.resume() }
                    .buttonStyle(.borderedProminent)
                Button("Exit") { bridge.goToMenu() }
                    .buttonStyle(.bordered)
            }
            .padding(24)
        }
    }

    private var menuOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Pong")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Choose a mode, then tap Play")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                menuModePickerRow
                Button("Play") { bridge.playFromMenu() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 24)
        }
    }

    /// Light material so both mode labels stay readable (segmented-style on dark overlay).
    private var menuModePickerRow: some View {
        HStack(spacing: 10) {
            menuModeButton(title: "1 vs AI", mode: .onePlayerVsAI)
            menuModeButton(title: "2 players", mode: .twoPlayers)
        }
        .padding(10)
        .frame(maxWidth: 400)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .colorScheme(.light)
    }

    @ViewBuilder
    private func menuModeButton(title: String, mode: PongGameMode) -> some View {
        let selected = gameMode == mode
        Button {
            gameMode = mode
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selected ? Color.primary : Color.primary.opacity(0.55))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selected ? Color.accentColor.opacity(0.28) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.black.opacity(selected ? 0.22 : 0.12), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
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
                    Button("Exit") {
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
        case (.twoPlayers, .left): return "Top player wins"
        case (.twoPlayers, .right): return "Bottom player wins"
        }
    }
}
