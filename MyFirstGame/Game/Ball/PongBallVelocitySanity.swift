//
//  PongBallVelocitySanity.swift
//  MyFirstGame
//

import CoreGraphics

/// Pure helpers to avoid the ball bouncing forever along one axis with almost no motion on the other.
enum PongBallVelocitySanity {

    /// Left/right walls: when vertical speed dominates and horizontal is tiny, add minimum horizontal speed.
    static func correctedVelocityIfVerticalLoop(
        velocity: CGVector,
        minHorizontalSpeed: CGFloat = 140,
        verticalDominanceRatio: CGFloat = 3.5,
        minSpeedToConsider: CGFloat = 45
    ) -> CGVector? {
        let vx = velocity.dx
        let vy = velocity.dy
        let speed = hypot(vx, vy)
        guard speed >= minSpeedToConsider else { return nil }
        guard abs(vy) >= abs(vx) * verticalDominanceRatio else { return nil }
        guard abs(vx) < minHorizontalSpeed else { return nil }

        let newVx = vx >= 0 ? minHorizontalSpeed : -minHorizontalSpeed
        return CGVector(dx: newVx, dy: vy)
    }

    /// Top/bottom walls: when horizontal speed dominates and vertical is tiny, add minimum vertical speed.
    static func correctedVelocityIfHorizontalLoop(
        velocity: CGVector,
        minVerticalSpeed: CGFloat = 140,
        horizontalDominanceRatio: CGFloat = 3.5,
        minSpeedToConsider: CGFloat = 45
    ) -> CGVector? {
        let vx = velocity.dx
        let vy = velocity.dy
        let speed = hypot(vx, vy)
        guard speed >= minSpeedToConsider else { return nil }
        guard abs(vx) >= abs(vy) * horizontalDominanceRatio else { return nil }
        guard abs(vy) < minVerticalSpeed else { return nil }

        let newVy = vy >= 0 ? minVerticalSpeed : -minVerticalSpeed
        return CGVector(dx: vx, dy: newVy)
    }
}
