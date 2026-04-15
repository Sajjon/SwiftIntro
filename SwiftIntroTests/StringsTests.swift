//
//  StringsTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  Verifies that every key in every .xcstrings catalog resolves to a non-empty
//  string at runtime using Xcode's generated LocalizedStringResource symbols.
//  A missing key is a compile error, not a test failure.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: nothing — all tests exercise generated symbols directly
//  - Act:     resolve the symbol to a String (1 line)
//  - Assert:  verify the returned string is non-empty (1 line)
//

@testable import SwiftIntro
import XCTest

final class StringsTests: XCTestCase {
    // MARK: - Settings.xcstrings

    func test_title_isNonEmpty() {
        XCTAssertFalse(String(localized: .Settings.title).isEmpty)
    }

    func test_startGame_isNonEmpty() {
        XCTAssertFalse(String(localized: .Settings.startGame).isEmpty)
    }

    func test_level_isNonEmpty() {
        XCTAssertFalse(String(localized: .Settings.level).isEmpty)
    }

    func test_usernamePlaceholder_isNonEmpty() {
        XCTAssertFalse(String(localized: .Settings.usernamePlaceholder).isEmpty)
    }

    func test_username_isNonEmpty() {
        XCTAssertFalse(String(localized: .Settings.username).isEmpty)
    }

    func test_easy_isNonEmpty() {
        XCTAssertFalse(String(localized: .Settings.easy).isEmpty)
    }

    func test_normal_isNonEmpty() {
        XCTAssertFalse(String(localized: .Settings.normal).isEmpty)
    }

    func test_hard_isNonEmpty() {
        XCTAssertFalse(String(localized: .Settings.hard).isEmpty)
    }

    // MARK: - Loading.xcstrings

    func test_loading_isNonEmpty() {
        XCTAssertFalse(String(localized: .Loading.loading).isEmpty)
    }

    // MARK: - GameOver.xcstrings

    func test_gameOverTitle_isNonEmpty() {
        XCTAssertFalse(String(localized: .GameOver.gameOverTitle).isEmpty)
    }

    func test_gameOverSubtitle_isNonEmpty() {
        XCTAssertFalse(String(localized: .GameOver.gameOverSubtitle).isEmpty)
    }

    func test_tryHarder_isNonEmpty() {
        XCTAssertFalse(String(localized: .GameOver.tryHarder).isEmpty)
    }

    func test_quit_isNonEmpty() {
        XCTAssertFalse(String(localized: .GameOver.quit).isEmpty)
    }

    func test_restart_isNonEmpty() {
        XCTAssertFalse(String(localized: .GameOver.restart).isEmpty)
    }

    func test_clickScore_isNonEmpty() {
        XCTAssertFalse(String(localized: .GameOver.clickScore(score: 42)).isEmpty)
    }

    // MARK: - Game.xcstrings

    func test_pairsFoundUnformatted_isNonEmpty() {
        XCTAssertFalse(String(localized: .Game.pairsFoundUnformatted(pairsFound: 3, totalPairs: 6)).isEmpty)
    }
}
