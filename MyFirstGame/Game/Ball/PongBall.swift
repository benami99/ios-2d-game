//
//  PongBall.swift
//  MyFirstGame
//

import SpriteKit

/// Ball geometry, appearance, and dynamic physics in logical playfield space (`Playfield`).
enum PongBall {

    /// Diameter 16pt — small enough to stay clear of walls once velocity and physics are added.
    static let radius: CGFloat = 8

    /// Typical serve speed in points/second (scene units).
    static let launchSpeed: CGFloat = 420

    /// Mid-court with `SKScene.anchorPoint = (0.5, 0.5)`; same as scene center between inner walls.
    static let restPosition = CGPoint.zero

    /// Vector circle so the silhouette stays round at any scale (vs. a square sprite texture).
    static func makeNode() -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = SKColor(white: 1, alpha: 0.95)
        node.strokeColor = SKColor(white: 0, alpha: 0.2)
        node.lineWidth = 1
        return node
    }

    /// Dynamic circle: bounces off walls and paddles; goals use contact (not collision).
    static func attachPhysics(to node: SKShapeNode) {
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = true
        body.allowsRotation = false
        body.friction = 0.06
        body.restitution = 0.94
        body.linearDamping = 0
        body.angularDamping = 0
        body.categoryBitMask = PhysicsCategory.ball
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.paddle
        body.contactTestBitMask = PhysicsCategory.wall | PhysicsCategory.paddle | PhysicsCategory.goal
        body.usesPreciseCollisionDetection = true
        node.physicsBody = body
    }
}
