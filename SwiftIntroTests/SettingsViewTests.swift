//
//  SettingsViewTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern.
//
//  Notes on approach:
//  - `SettingsView`'s controls are private, so they are located by type via
//    `findSubview(_:in:)` — a depth-first traversal of the view hierarchy.
//  - Actions are fired with `sendActions(for:)` rather than simulating taps,
//    so no window or layout pass is required.
//  - `onStartGame` is the only public output; all behaviour is verified
//    through the config it delivers.
//

@testable import SwiftIntro
import UIKit
import XCTest

@MainActor
final class SettingsViewTests: XCTestCase {
    // MARK: - Helpers

    /// Depth-first search for the first subview of the given type.
    private func findSubview<T: UIView>(
        _ type: T.Type,
        in view: UIView
    ) -> T? {
        if let found = view as? T { return found }
        return view.subviews.compactMap { findSubview(type, in: $0) }.first
    }

    private func startButton(in view: SettingsView) -> UIButton {
        findSubview(UIButton.self, in: view)!
    }

    private func textField(in view: SettingsView) -> UITextField {
        findSubview(UITextField.self, in: view)!
    }

    private func segmentedControl(in view: SettingsView) -> UISegmentedControl {
        findSubview(UISegmentedControl.self, in: view)!
    }

    // MARK: - init

    func test_init_doesNotCrash() {
        // Act + Assert
        XCTAssertNoThrow(SettingsView())
    }

    func test_init_onStartGameIsNil() {
        // Act + Assert
        XCTAssertNil(SettingsView().onStartGame)
    }

    // MARK: - populateViews (initial control state)

    func test_init_textFieldContainsDefaultSearchQuery() {
        // Act + Assert
        XCTAssertEqual(textField(in: SettingsView()).text, GameConfiguration().searchQuery)
    }

    func test_init_segmentSelectedIndexMatchesDefaultLevel() {
        // Act + Assert
        XCTAssertEqual(
            segmentedControl(in: SettingsView()).selectedSegmentIndex,
            GameConfiguration().level.segmentedControlIndex
        )
    }

    // MARK: - startGameTapped

    func test_startGameTapped_firesOnStartGame() {
        // Arrange
        let view = SettingsView()
        var fired = false
        view.onStartGame = { _ in fired = true }

        // Act
        startButton(in: view).sendActions(for: .touchUpInside)

        // Assert
        XCTAssertTrue(fired)
    }

    func test_startGameTapped_defaultConfig_passesDefaultSearchQuery() {
        // Arrange
        let view = SettingsView()
        var config: GameConfiguration?
        view.onStartGame = { config = $0 }

        // Act
        startButton(in: view).sendActions(for: .touchUpInside)

        // Assert
        XCTAssertEqual(config?.searchQuery, GameConfiguration().searchQuery)
    }

    func test_startGameTapped_defaultConfig_passesDefaultLevel() {
        // Arrange
        let view = SettingsView()
        var config: GameConfiguration?
        view.onStartGame = { config = $0 }

        // Act
        startButton(in: view).sendActions(for: .touchUpInside)

        // Assert
        XCTAssertEqual(config?.level, GameConfiguration().level)
    }

    func test_startGameTapped_withCustomText_passesQueryInConfig() {
        // Arrange
        let view = SettingsView()
        textField(in: view).text = "dogs"
        var config: GameConfiguration?
        view.onStartGame = { config = $0 }

        // Act
        startButton(in: view).sendActions(for: .touchUpInside)

        // Assert
        XCTAssertEqual(config?.searchQuery, "dogs")
    }

    func test_startGameTapped_withEmptyText_keepsDefaultQuery() {
        // Arrange — empty text does not override the default search query
        let view = SettingsView()
        textField(in: view).text = ""
        var config: GameConfiguration?
        view.onStartGame = { config = $0 }

        // Act
        startButton(in: view).sendActions(for: .touchUpInside)

        // Assert
        XCTAssertEqual(config?.searchQuery, GameConfiguration().searchQuery)
    }

    // MARK: - changedLevel

    func test_changedLevel_toEasy_passesEasyLevelInConfig() {
        // Arrange
        let view = SettingsView()
        let seg = segmentedControl(in: view)
        seg.selectedSegmentIndex = Level.easy.segmentedControlIndex
        seg.sendActions(for: .valueChanged)
        var config: GameConfiguration?
        view.onStartGame = { config = $0 }

        // Act
        startButton(in: view).sendActions(for: .touchUpInside)

        // Assert
        XCTAssertEqual(config?.level, .easy)
    }

    func test_changedLevel_toHard_passesHardLevelInConfig() {
        // Arrange
        let view = SettingsView()
        let seg = segmentedControl(in: view)
        seg.selectedSegmentIndex = Level.hard.segmentedControlIndex
        seg.sendActions(for: .valueChanged)
        var config: GameConfiguration?
        view.onStartGame = { config = $0 }

        // Act
        startButton(in: view).sendActions(for: .touchUpInside)

        // Assert
        XCTAssertEqual(config?.level, .hard)
    }
}
