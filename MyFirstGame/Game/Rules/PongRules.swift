//
//  PongRules.swift
//  MyFirstGame
//

import Foundation

/// Tunable match rules (Phase 5 — scoring, win condition, serve behavior).
enum PongRules {

    /// First side to reach this many points wins the match.
    static let pointsToWin = 11

    /// After a point, wait this long before auto-serving (ignored if `requireTapToServeAfterPoint` is true).
    static let postPointResetDelay: TimeInterval = 0.55

    /// If `true`, the ball stays at center after each point until the player taps (still uses delay before game-over overlay only).
    static let requireTapToServeAfterPoint = false
}
