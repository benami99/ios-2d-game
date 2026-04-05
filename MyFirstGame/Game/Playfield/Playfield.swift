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

    /// Horizontal band at top/bottom for wall bodies (and future ball bounces).
    static let wallThickness: CGFloat = 28

    /// Inner horizontal segment between wall inner faces (paddle / ball vertical range uses this).
    static var innerBottomY: CGFloat { -halfHeight + wallThickness }
    static var innerTopY: CGFloat { halfHeight - wallThickness }
}
