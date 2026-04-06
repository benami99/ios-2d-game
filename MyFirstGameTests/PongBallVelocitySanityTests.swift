//
//  PongBallVelocitySanityTests.swift
//  MyFirstGameTests
//

import CoreGraphics
import XCTest
@testable import MyFirstGame

final class PongBallVelocitySanityTests: XCTestCase {

    func testLeavesDiagonalVelocityUnchanged() {
        let v = CGVector(dx: 300, dy: 200)
        XCTAssertNil(PongBallVelocitySanity.correctedVelocityIfVerticalLoop(velocity: v))
    }

    func testNudgesNearlyVerticalUpward() {
        let v = CGVector(dx: 3, dy: 500)
        let fixed = PongBallVelocitySanity.correctedVelocityIfVerticalLoop(velocity: v)
        XCTAssertNotNil(fixed)
        XCTAssertEqual(Double(fixed!.dx), 140, accuracy: 0.01)
        XCTAssertEqual(Double(fixed!.dy), 500, accuracy: 0.01)
    }

    func testNudgesNearlyVerticalWithNegativeHorizontal() {
        let v = CGVector(dx: -2, dy: -400)
        let fixed = PongBallVelocitySanity.correctedVelocityIfVerticalLoop(velocity: v)
        XCTAssertNotNil(fixed)
        XCTAssertEqual(Double(fixed!.dx), -140, accuracy: 0.01)
        XCTAssertEqual(Double(fixed!.dy), -400, accuracy: 0.01)
    }

    func testIgnoresVerySlowVelocity() {
        let v = CGVector(dx: 1, dy: 2)
        XCTAssertNil(PongBallVelocitySanity.correctedVelocityIfVerticalLoop(velocity: v))
    }

    func testNudgesNearlyHorizontalRightward() {
        let v = CGVector(dx: 500, dy: 3)
        let fixed = PongBallVelocitySanity.correctedVelocityIfHorizontalLoop(velocity: v)
        XCTAssertNotNil(fixed)
        XCTAssertEqual(Double(fixed!.dx), 500, accuracy: 0.01)
        XCTAssertEqual(Double(fixed!.dy), 140, accuracy: 0.01)
    }
}
