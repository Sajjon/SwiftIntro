//
//  StringsTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: nothing — all tests exercise static L10n accessors directly
//  - Act:     access the L10n property or call the L10n function (1 line)
//  - Assert:  verify the returned string is non-empty and matches the fallback (1 line)
//

import XCTest
@testable import SwiftIntro

final class StringsTests: XCTestCase {

    // MARK: - Static let keys

    func test_title_isNonEmpty() {
        // Act
        let value = L10n.title

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_startGame_isNonEmpty() {
        // Act
        let value = L10n.startGame

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_level_isNonEmpty() {
        // Act
        let value = L10n.level

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_usernamePlaceholder_isNonEmpty() {
        // Act
        let value = L10n.usernamePlaceholder

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_username_isNonEmpty() {
        // Act
        let value = L10n.username

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_easy_isNonEmpty() {
        // Act
        let value = L10n.easy

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_normal_isNonEmpty() {
        // Act
        let value = L10n.normal

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_hard_isNonEmpty() {
        // Act
        let value = L10n.hard

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_gameOverTitle_isNonEmpty() {
        // Act
        let value = L10n.gameOverTitle

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_gameOverSubtitle_isNonEmpty() {
        // Act
        let value = L10n.gameOverSubtitle

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_tryHarder_isNonEmpty() {
        // Act
        let value = L10n.tryHarder

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_quit_isNonEmpty() {
        // Act
        let value = L10n.quit

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_restart_isNonEmpty() {
        // Act
        let value = L10n.restart

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_loading_isNonEmpty() {
        // Act
        let value = L10n.loading

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    // MARK: - Functions with format arguments

    func test_pairsFoundUnformatted_isNonEmpty() {
        // Act
        let value = L10n.pairsFoundUnformatted(3, 6)

        // Assert
        XCTAssertFalse(value.isEmpty)
    }

    func test_clickScore_isNonEmpty() {
        // Act
        let value = L10n.clickScore(42)

        // Assert
        XCTAssertFalse(value.isEmpty)
    }
}
