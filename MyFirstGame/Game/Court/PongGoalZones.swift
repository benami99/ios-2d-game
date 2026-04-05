//
//  PongGoalZones.swift
//  MyFirstGame
//

import SpriteKit

/// Invisible strips **behind** each paddle (between outer court edge and paddle face) — ball passes through; contact drives scoring.
enum PongGoalZones {

    /// Left strip from scene left edge up to the paddle’s outer face (uses same inset math as `PongScene.layoutPaddles`).
    static func makeLeftGoal() -> SKSpriteNode {
        let sceneLeft = -Playfield.halfWidth
        let paddleLeftEdge = -Playfield.halfWidth + PongPaddle.marginFromPlayfield
        let w = max(10, paddleLeftEdge - sceneLeft)
        let centerX = (sceneLeft + paddleLeftEdge) / 2
        return makeGoal(named: "goalLeft", centerX: centerX, width: w)
    }

    /// Right strip from paddle’s outer face to the scene right edge.
    static func makeRightGoal() -> SKSpriteNode {
        let sceneRight = Playfield.halfWidth
        let paddleRightEdge = Playfield.halfWidth - PongPaddle.marginFromPlayfield
        let w = max(10, sceneRight - paddleRightEdge)
        let centerX = (paddleRightEdge + sceneRight) / 2
        return makeGoal(named: "goalRight", centerX: centerX, width: w)
    }

    // MARK: - Private

    private static func makeGoal(named name: String, centerX: CGFloat, width: CGFloat) -> SKSpriteNode {
        let h = Playfield.innerTopY - Playfield.innerBottomY
        let node = SKSpriteNode(color: SKColor(white: 1, alpha: 0.001), size: CGSize(width: width, height: h))
        node.name = name
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.position = CGPoint(x: centerX, y: (Playfield.innerBottomY + Playfield.innerTopY) / 2)

        let body = SKPhysicsBody(rectangleOf: node.size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.goal
        body.collisionBitMask = 0
        body.contactTestBitMask = PhysicsCategory.ball

        node.physicsBody = body
        return node
    }
}
