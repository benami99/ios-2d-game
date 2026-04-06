//
//  Playfield.swift
//  MyFirstGame
//

import CoreGraphics

/// Logical court dimensions and derived bounds. No SpriteKit — pure geometry for layout and future ball logic.
enum Playfield {

    /// Fixed scene size in points; `SKView` scales with `aspectFit` so coordinates stay stable across devices.
    static let logicalSize = CGSize(width: 800, height: 1200)

    static var halfWidth: CGFloat { logicalSize.width / 2 }
    static var halfHeight: CGFloat { logicalSize.height / 2 }

    /// Vertical bands at left/right for wall bodies (ball bounces off these).
    static let wallThickness: CGFloat = 28

    /// Inner vertical segment between wall inner faces (paddle horizontal range / ball x-range).
    static var innerLeftX: CGFloat { -halfWidth + wallThickness }
    static var innerRightX: CGFloat { halfWidth - wallThickness }

    /// Full inner height between top and bottom outer edges (goals sit in the bands beyond paddles).
    static var innerBottomY: CGFloat { -halfHeight }
    static var innerTopY: CGFloat { halfHeight }
}
