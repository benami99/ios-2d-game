//
//  PongCourtElements.swift
//  MyFirstGame
//

import SpriteKit

/// Builds static court visuals: top/bottom walls (with physics) and the mid-court line (no physics).
enum PongCourtElements {

    /// Horizontal strip along the top edge; nearly invisible sprite with a static physics body.
    static func makeTopWall() -> SKSpriteNode {
        let node = makeWallSprite()
        let h = Playfield.wallThickness
        let w = Playfield.logicalSize.width
        node.size = CGSize(width: w, height: h)
        node.position = CGPoint(x: 0, y: Playfield.halfHeight - h / 2)
        attachStaticWallPhysics(to: node)
        return node
    }

    /// Horizontal strip along the bottom edge.
    static func makeBottomWall() -> SKSpriteNode {
        let node = makeWallSprite()
        let h = Playfield.wallThickness
        let w = Playfield.logicalSize.width
        node.size = CGSize(width: w, height: h)
        node.position = CGPoint(x: 0, y: -Playfield.halfHeight + h / 2)
        attachStaticWallPhysics(to: node)
        return node
    }

    /// Vertical line at x = 0 between inner wall faces (cosmetic only).
    static func makeCenterLine() -> SKShapeNode {
        let bottom = Playfield.innerBottomY
        let top = Playfield.innerTopY
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: bottom))
        path.addLine(to: CGPoint(x: 0, y: top))

        let line = SKShapeNode(path: path)
        line.strokeColor = SKColor(white: 1, alpha: 0.22)
        line.lineWidth = 3
        line.lineCap = .round
        return line
    }

    // MARK: - Private

    /// Minimal visible sprite so hit testing / rendering behave consistently across OS versions.
    private static func makeWallSprite() -> SKSpriteNode {
        let node = SKSpriteNode(color: SKColor(white: 1, alpha: 0.02), size: CGSize(width: 1, height: 1))
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return node
    }

    private static func attachStaticWallPhysics(to node: SKSpriteNode) {
        let body = SKPhysicsBody(rectangleOf: node.size)
        body.isDynamic = false
        body.friction = 0.04
        body.restitution = 0.96
        body.categoryBitMask = PhysicsCategory.wall
        body.collisionBitMask = PhysicsCategory.ball
        node.physicsBody = body
    }
}
