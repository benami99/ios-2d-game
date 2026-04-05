//
//  PongFlowState.swift
//  MyFirstGame
//

/// Phase 6 — top-level UI / simulation flow (distinct from `PongMatchPhase` rally logic inside a match).
enum PongFlowState: Equatable {
    /// Placeholder for future main menu; entry can still start in `.playing`.
    case menu
    case playing
    case paused
    case gameOver
}
