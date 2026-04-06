//
//  PongGameBridge.swift
//  MyFirstGame
//

import Combine
import SpriteKit
import SwiftUI

/// Connects `PongScene` to SwiftUI: scores, flow state, and HUD actions (Phase 6).
@MainActor
final class PongGameBridge: ObservableObject {

    @Published var flowState: PongFlowState = .menu

    @Published var leftScore = 0
    @Published var rightScore = 0

    /// Set when a side reaches `PongRules.pointsToWin`; cleared on restart or new match.
    @Published var matchWinner: PongSide?

    weak var scene: PongScene?

    func updateScores(left: Int, right: Int) {
        leftScore = left
        rightScore = right
    }

    func notifyMatchEnded(winner: PongSide) {
        matchWinner = winner
        flowState = .gameOver
    }

    func pause() {
        guard flowState == .playing else { return }
        flowState = .paused
        scene?.isPaused = true
    }

    func resume() {
        guard flowState == .paused else { return }
        flowState = .playing
        scene?.isPaused = false
    }

    func goToMenu() {
        matchWinner = nil
        flowState = .menu
        scene?.isPaused = true
        scene?.resetMatchForMenu()
    }

    func playFromMenu() {
        flowState = .playing
        scene?.isPaused = false
        scene?.launchBallAfterMenu()
    }

    /// Full match reset from HUD; keeps current `PongScene` instance.
    func restartMatch() {
        scene?.restartMatchFromHUD()
        matchWinner = nil
        flowState = .playing
        scene?.isPaused = false
    }
}
