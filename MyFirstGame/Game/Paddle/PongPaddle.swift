//
//  PongPaddle.swift
//  MyFirstGame
//

import SpriteKit

/// Paddle geometry and appearance in logical playfield space (`Playfield`).
enum PongPaddle {

    static let size = CGSize(width: 18, height: 110)

    /// Inset from the inner court (between walls) so paddles do not hug the wall line.
    static let marginFromPlayfield: CGFloat = 12

    static func makeSprite() -> SKSpriteNode {
        let node = SKSpriteNode(color: SKColor(red: 0.95, green: 0.45, blue: 0.65, alpha: 1), size: size)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }

    /// Static body moved by setting `node.position` each frame — still collides with the dynamic ball.
    static func attachPhysics(to node: SKSpriteNode) {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.friction = 0.12
        body.restitution = 0.88
        body.categoryBitMask = PhysicsCategory.paddle
        body.collisionBitMask = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball
        node.physicsBody = body
    }
}
