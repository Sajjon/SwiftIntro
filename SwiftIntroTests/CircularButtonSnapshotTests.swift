//
//  CircularButtonSnapshotTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import SnapshotTesting
@testable import SwiftIntro
import XCTest

@MainActor
final class CircularButtonSnapshotTests: XCTestCase {
    func test_circularButton_defaultAppearance() {
        // Arrange
        let button = CircularButton(title: "OK")
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 80)

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: button, as: .image)
        }
    }

    func test_circularButton_longTitle() {
        // Arrange
        let button = CircularButton(title: "Restart")
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 80)

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: button, as: .image)
        }
    }
}
