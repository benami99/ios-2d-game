//
//  PongMatchPhase.swift
//  MyFirstGame
//

/// High-level match flow: active rally, waiting for serve, or match finished.
enum PongMatchPhase: Equatable {
    /// Ball may be in motion; goals can score.
    case rally
    /// Point scored; ball is centered — next serve is tap-driven when rules say so.
    case awaitingServe
    /// A side reached `PongRules.pointsToWin`; no scoring until restart.
    case gameOver(winner: PongSide)
}
