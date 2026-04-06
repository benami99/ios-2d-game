//
//  PongGoalZones.swift
//  MyFirstGame
//

import SpriteKit

/// Invisible strips **behind** the top and bottom paddles — ball passes through; contact drives scoring.
enum PongGoalZones {

    /// Strip above the top paddle (toward +y).
    static func makeTopGoal() -> SKSpriteNode {
        let outerTop = Playfield.halfHeight
        let paddleOuterTop = PongPaddle.topPaddleCenterY + PongPaddle.size.height / 2
        let h = max(10, outerTop - paddleOuterTop)
        let centerY = (outerTop + paddleOuterTop) / 2
        let w = Playfield.innerRightX - Playfield.innerLeftX
        return makeGoal(named: "goalTop", center: CGPoint(x: 0, y: centerY), size: CGSize(width: w, height: h))
    }

    /// Strip below the bottom paddle (toward -y).
    static func makeBottomGoal() -> SKSpriteNode {
        let outerBottom = -Playfield.halfHeight
        let paddleOuterBottom = PongPaddle.bottomPaddleCenterY - PongPaddle.size.height / 2
        let h = max(10, paddleOuterBottom - outerBottom)
        let centerY = (outerBottom + paddleOuterBottom) / 2
        let w = Playfield.innerRightX - Playfield.innerLeftX
        return makeGoal(named: "goalBottom", center: CGPoint(x: 0, y: centerY), size: CGSize(width: w, height: h))
    }

    // MARK: - Private

    private static func makeGoal(named name: String, center: CGPoint, size: CGSize) -> SKSpriteNode {
        let node = SKSpriteNode(color: SKColor(white: 1, alpha: 0.001), size: size)
        node.name = name
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.position = center

        let body = SKPhysicsBody(rectangleOf: node.size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.goal
        body.collisionBitMask = 0
        body.contactTestBitMask = PhysicsCategory.ball

        node.physicsBody = body
        return node
    }
}
