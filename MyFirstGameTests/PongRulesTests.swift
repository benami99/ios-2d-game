//
//  PongRulesTests.swift
//  MyFirstGameTests
//

import XCTest
@testable import MyFirstGame

final class PongRulesTests: XCTestCase {

    func testLaunchSpeedAtZeroPoints() {
        XCTAssertEqual(
            Double(PongRules.launchSpeed(totalPointsScored: 0)),
            Double(PongRules.baseLaunchSpeed),
            accuracy: 0.001
        )
    }

    func testLaunchSpeedIncreasesWithPoints() {
        let s0 = PongRules.launchSpeed(totalPointsScored: 0)
        let s5 = PongRules.launchSpeed(totalPointsScored: 5)
        XCTAssertGreaterThan(s5, s0)
    }

    func testLaunchSpeedCapsAtMaxMultiplier() {
        let capped = PongRules.launchSpeed(totalPointsScored: 999)
        let expected = PongRules.baseLaunchSpeed * PongRules.maxLaunchSpeedMultiplier
        XCTAssertEqual(Double(capped), Double(expected), accuracy: 0.5)
    }
}
