//
//  GameOverVCTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern.
//
//  Notes on approach:
//  - `_ = vc.view` triggers loadView + viewDidLoad.
//  - Navigation-stack tests use plain `UIViewController` stand-ins for
//    the VCs that precede `GameOverVC` in the stack.
//  - `onRestart?()` / `onQuit?()` invoke the closures wired in `viewDidLoad`,
//    exercising `restartGame()` and `popToRootViewController` without UIKit events.
//

@testable import SwiftIntro
import UIKit
import XCTest

// MARK: - SpyNavigator

private final class SpyNavigator: GameOverNavigatorProtocol {
    private(set) var restartGameCalled = false
    private(set) var quitGameCalled = false
    private(set) var lastGame: PreparedGame?

    func restartGame(_ game: PreparedGame) {
        restartGameCalled = true
        lastGame = game
    }

    func quitGame() {
        quitGameCalled = true
    }
}

// MARK: - Tests

final class GameOverVCTests: XCTestCase {
    // MARK: - Helpers

    private func makeCard(index: Int) -> Card {
        Card(imageUrl: URL(string: "https://a.test/\(index).jpg")!)
    }

    private func makeCards(count: Int) -> CardDuplicates {
        CardDuplicates(memoryCards: (0 ..< count).map { makeCard(index: $0) })
    }

    private func makeOutcome(
        level: Level = .easy,
        clickCount: Int = 5
    ) -> GameOutcome {
        GameOutcome(
            level: level,
            clickCount: clickCount,
            cards: makeCards(count: level.cardCount)
        )
    }

    private func makeVC(
        config: GameConfiguration = GameConfiguration(level: .easy),
        outcome: GameOutcome? = nil
    ) -> GameOverVC {
        GameOverVC(config: config, outcome: outcome ?? makeOutcome())
    }

    /// Casts `vc.view` to `GameOverView`. Crashes the test if the type is wrong.
    private func gameOverView(of vc: GameOverVC) -> GameOverView {
        // swiftlint:disable:next force_cast
        vc.view as! GameOverView
    }

    /// Recursively collects every `CircularButton` in the view hierarchy, depth-first.
    private func findCircularButtons(in view: UIView) -> [CircularButton] {
        var result: [CircularButton] = []
        if let btn = view as? CircularButton { result.append(btn) }
        for sub in view.subviews {
            result.append(contentsOf: findCircularButtons(in: sub))
        }
        return result
    }

    // MARK: - init

    func test_init_doesNotCrash() {
        // Act + Assert
        XCTAssertNoThrow(makeVC())
    }

    // MARK: - loadView

    func test_view_isGameOverView() {
        // Act + Assert
        XCTAssertTrue(makeVC().view is GameOverView)
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_wiresOnRestart() {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertNotNil(gameOverView(of: vc).onRestart)
    }

    func test_viewDidLoad_wiresOnQuit() {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertNotNil(gameOverView(of: vc).onQuit)
    }

    // MARK: - onQuit

    func test_onQuit_callsNavigatorQuitGame() {
        // Arrange
        let vc = makeVC()
        let spy = SpyNavigator()
        vc.navigator = spy
        _ = vc.view

        // Act
        gameOverView(of: vc).onQuit?()

        // Assert
        XCTAssertTrue(spy.quitGameCalled)
    }

    func test_onQuit_withoutNavigator_doesNotCrash() {
        // Arrange — navigator intentionally not set
        let vc = makeVC()
        _ = vc.view

        // Act + Assert
        XCTAssertNoThrow(gameOverView(of: vc).onQuit?())
    }

    // MARK: - onRestart

    func test_onRestart_callsNavigatorRestartGame() {
        // Arrange
        let vc = makeVC()
        let spy = SpyNavigator()
        vc.navigator = spy
        _ = vc.view

        // Act
        gameOverView(of: vc).onRestart?()

        // Assert
        XCTAssertTrue(spy.restartGameCalled)
    }

    func test_onRestart_passesOutcomeCardsToNavigator() {
        // Arrange
        let outcome = makeOutcome(level: .easy)
        let vc = makeVC(outcome: outcome)
        let spy = SpyNavigator()
        vc.navigator = spy
        _ = vc.view

        // Act
        gameOverView(of: vc).onRestart?()

        // Assert
        XCTAssertEqual(spy.lastGame?.cards.memoryCards.count, outcome.cards.memoryCards.count)
    }

    func test_onRestart_withoutNavigator_doesNotCrash() {
        // Arrange — navigator intentionally not set
        let vc = makeVC()
        _ = vc.view

        // Act + Assert
        XCTAssertNoThrow(gameOverView(of: vc).onRestart?())
    }

    // MARK: - @objc button targets

    func test_restartButton_invokesOnRestartClosure() {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        var restartCalled = false
        gameOverView(of: vc).onRestart = { restartCalled = true }

        // Act — trigger the @objc target-action registered on the restart button
        findCircularButtons(in: gameOverView(of: vc)).first?.sendActions(for: .touchUpInside)

        // Assert
        XCTAssertTrue(restartCalled)
    }

    func test_quitButton_invokesOnQuitClosure() {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        var quitCalled = false
        gameOverView(of: vc).onQuit = { quitCalled = true }

        // Act — trigger the @objc target-action registered on the quit button
        findCircularButtons(in: gameOverView(of: vc)).last?.sendActions(for: .touchUpInside)

        // Assert
        XCTAssertTrue(quitCalled)
    }

    // MARK: - GameOverView.render

    func test_render_doesNotCrash() {
        // Act + Assert — render is also called implicitly by viewDidLoad
        XCTAssertNoThrow(GameOverView().render(makeOutcome()))
    }
}
