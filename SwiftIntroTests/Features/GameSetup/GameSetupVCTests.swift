//
//  GameSetupVCTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern.
//

@testable import SwiftIntro
import UIKit
import XCTest

final class GameSetupVCTests: XCTestCase {
    // MARK: - Helpers

    private func gameSetupView(of vc: GameSetupVC) -> GameSetupView {
        // swiftlint:disable:next force_cast
        vc.view as! GameSetupView
    }

    // MARK: - init

    func test_init_doesNotCrash() {
        XCTAssertNoThrow(GameSetupVC())
    }

    // MARK: - loadView

    func test_view_isGameSetupView() {
        XCTAssertTrue(GameSetupVC().view is GameSetupView)
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_wiresOnStartGame() {
        // Arrange
        let vc = GameSetupVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertNotNil(gameSetupView(of: vc).onStartGame)
    }

    // MARK: - onStartGame

    func test_onStartGame_callsNavigatorNavigateToLoading() {
        // Arrange
        final class SpyNavigator: GameSetupNavigatorProtocol {
            var receivedConfig: GameConfiguration?
            func navigateToLoading(config: GameConfiguration) {
                receivedConfig = config
            }
        }
        let vc = GameSetupVC()
        let spy = SpyNavigator()
        vc.navigator = spy
        _ = vc.view
        let config = GameConfiguration(level: .hard, searchQuery: "dogs")

        // Act
        gameSetupView(of: vc).onStartGame?(config)

        // Assert
        XCTAssertEqual(spy.receivedConfig?.level, .hard)
        XCTAssertEqual(spy.receivedConfig?.searchQuery, "dogs")
    }

    func test_onStartGame_withNoNavigator_doesNotCrash() {
        // Arrange — navigator intentionally not set
        let vc = GameSetupVC()
        _ = vc.view

        // Act + Assert
        XCTAssertNoThrow(gameSetupView(of: vc).onStartGame?(GameConfiguration()))
    }
}
