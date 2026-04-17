//
//  GameSetupViewSnapshotTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import SnapshotTesting
@testable import SwiftIntro
import XCTest

final class SettingsViewSnapshotTests: XCTestCase {
    private let size = CGSize(width: 393, height: 852)

    func test_settingsView_defaultAppearance() {
        // Arrange
        let view = GameSetupView()

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }

    func test_settingsView_onStartGameClosureAssignable() {
        // Arrange
        let view = GameSetupView()
        var capturedConfig: GameConfiguration?

        // Act
        view.onStartGame = { config in capturedConfig = config }

        // Assert — closure is assignable, view still renders correctly
        XCTAssertNil(capturedConfig)
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }
}
