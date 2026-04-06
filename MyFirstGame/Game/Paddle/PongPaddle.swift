//
//  PongPaddle.swift
//  MyFirstGame
//

import SpriteKit

/// Paddle geometry and appearance in logical playfield space (`Playfield`).
enum PongPaddle {

    /// Horizontal paddle: long along x, thin along y (top/bottom of court).
    static let size = CGSize(width: 158, height: 40)

    /// Inset from the top/bottom outer edges so paddles sit inside the scene.
    static let marginFromPlayfield: CGFloat = 12

    /// Fixed center Y for top paddle (matches goal geometry).
    static var topPaddleCenterY: CGFloat {
        Playfield.halfHeight - marginFromPlayfield - size.height / 2
    }

    /// Fixed center Y for bottom paddle (matches goal geometry).
    static var bottomPaddleCenterY: CGFloat {
        -Playfield.halfHeight + marginFromPlayfield + size.height / 2
    }

    static func makeSprite() -> SKSpriteNode {
        let node = SKSpriteNode(color: SKColor(red: 0.95, green: 0.45, blue: 0.65, alpha: 1), size: size)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }

    /// Static body moved by setting `node.position` each frame — still collides with the dynamic ball.
    static func attachPhysics(to node: SKSpriteNode) {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.friction = 0
        body.restitution = 1
        body.categoryBitMask = PhysicsCategory.paddle
        body.collisionBitMask = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball
        node.physicsBody = body
    }
}
