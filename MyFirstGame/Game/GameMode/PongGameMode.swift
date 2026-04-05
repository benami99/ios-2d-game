//
//  PongGameMode.swift
//  MyFirstGame
//

/// How human input maps to paddles (`PongScene` uses this for touch routing and AI).
enum PongGameMode: String, CaseIterable, Hashable {
    /// Human controls the **right** paddle; **left** paddle follows the ball (smoothed).
    case onePlayerVsAI
    /// Left screen half → left paddle, right half → right paddle (same as Phase 1).
    case twoPlayers
}
