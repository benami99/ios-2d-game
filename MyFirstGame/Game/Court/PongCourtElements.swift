//
//  PongCourtElements.swift
//  MyFirstGame
//

import SpriteKit

/// Static court visuals: **left/right walls** (physics) and mid-court **horizontal** line (cosmetic).
enum PongCourtElements {

    /// Vertical strip along the left edge.
    static func makeLeftWall() -> SKSpriteNode {
        let node = makeWallSprite()
        let w = Playfield.wallThickness
        let h = Playfield.logicalSize.height
        node.size = CGSize(width: w, height: h)
        node.position = CGPoint(x: -Playfield.halfWidth + w / 2, y: 0)
        attachStaticWallPhysics(to: node)
        return node
    }

    /// Vertical strip along the right edge.
    static func makeRightWall() -> SKSpriteNode {
        let node = makeWallSprite()
        let w = Playfield.wallThickness
        let h = Playfield.logicalSize.height
        node.size = CGSize(width: w, height: h)
        node.position = CGPoint(x: Playfield.halfWidth - w / 2, y: 0)
        attachStaticWallPhysics(to: node)
        return node
    }

    /// Horizontal line at y = 0 between inner wall faces (cosmetic only).
    static func makeCenterLine() -> SKShapeNode {
        let left = Playfield.innerLeftX
        let right = Playfield.innerRightX
        let path = CGMutablePath()
        path.move(to: CGPoint(x: left, y: 0))
        path.addLine(to: CGPoint(x: right, y: 0))

        let line = SKShapeNode(path: path)
        line.strokeColor = SKColor(white: 1, alpha: 0.22)
        line.lineWidth = 3
        line.lineCap = .round
        return line
    }

    // MARK: - Private

    private static func makeWallSprite() -> SKSpriteNode {
        let node = SKSpriteNode(color: SKColor(white: 1, alpha: 0.02), size: CGSize(width: 1, height: 1))
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }

    private static func attachStaticWallPhysics(to node: SKSpriteNode) {
        let body = SKPhysicsBody(rectangleOf: node.size)
        body.isDynamic = false
        body.friction = 0
        body.restitution = 1
        body.categoryBitMask = PhysicsCategory.wall
        body.collisionBitMask = PhysicsCategory.ball
        node.physicsBody = body
    }
}
