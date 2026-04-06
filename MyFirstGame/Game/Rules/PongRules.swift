//
//  PongRules.swift
//  MyFirstGame
//

import CoreGraphics
import Foundation

/// Tunable match rules (Phase 5 — scoring, win condition, serve behavior).
enum PongRules {

    /// First side to reach this many points wins the match.
    static let pointsToWin = 11

    /// After a point, wait this long before auto-serving (ignored if `requireTapToServeAfterPoint` is true).
    static let postPointResetDelay: TimeInterval = 0.55

    /// If `true`, the ball stays at center after each point until the player taps (still uses delay before game-over overlay only).
    static let requireTapToServeAfterPoint = false

    /// Target ball speed (points/sec) at 0–0; used for serves and to keep rally speed steady (no slowdown from friction).
    static let baseLaunchSpeed: CGFloat = 620

    /// Caps the speed multiplier (late match); allows big late-game jumps.
    static let maxLaunchSpeedMultiplier: CGFloat = 2.2

    /// Extra speed per combined point scored (both sides). Each point adds ~12% so the jump is clearly felt.
    static let launchSpeedRampPerPoint: CGFloat = 0.12

    /// Extra speed (pts/sec) added for each paddle hit during a rally. Resets on every serve.
    static let rallySpeedBoostPerHit: CGFloat = 22

    /// Max angle (radians) added from hitting away from paddle center (classic Pong "English").
    static let paddleMaxBounceAngle: CGFloat = .pi / 2.75

    /// Serve speed based on score alone (no rally hits yet).
    static func launchSpeed(totalPointsScored: Int) -> CGFloat {
        let ramp = min(maxLaunchSpeedMultiplier, 1.0 + launchSpeedRampPerPoint * CGFloat(totalPointsScored))
        return baseLaunchSpeed * ramp
    }

    /// In-rally target speed: score ramp + cumulative per-hit acceleration, still capped at max multiplier.
    static func rallySpeed(totalPointsScored: Int, rallyHits: Int) -> CGFloat {
        let base = launchSpeed(totalPointsScored: totalPointsScored)
        let hitBoost = rallySpeedBoostPerHit * CGFloat(rallyHits)
        return min(base + hitBoost, baseLaunchSpeed * maxLaunchSpeedMultiplier)
    }
}
