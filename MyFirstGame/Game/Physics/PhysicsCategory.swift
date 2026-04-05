//
//  PhysicsCategory.swift
//  MyFirstGame
//

import Foundation

/// Bit masks for `SKPhysicsBody` categories, collisions, and contact callbacks (scoring via goal sensors).
enum PhysicsCategory {
    static let wall: UInt32 = 0b1
    static let paddle: UInt32 = 0b10
    static let ball: UInt32 = 0b100
    /// Invisible edge sensors — contact only (no collision with ball).
    static let goal: UInt32 = 0b1000
}
