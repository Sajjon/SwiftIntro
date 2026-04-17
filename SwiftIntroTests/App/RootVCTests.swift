//
//  RootVCTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  Integration tests for `RootVC` — verifies every navigation transition
//  in the game flow produces the expected stack state.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern.
//

@testable import SwiftIntro
import UIKit
import XCTest

final class RootVCTests: XCTestCase {
    // MARK: - Helpers

    /// All RootVC navigation tests use the `.easy` path (6 cards) — the replacement
    /// logic is identical for each level; picking one keeps helpers concise.
    private func makeEasyCards() -> CardDuplicates<6> {
        let paired = (0 ..< 3).flatMap { i -> [Card] in
            let card = Card(imageUrl: URL(string: "https://a.test/\(i).jpg")!)
            return [card, card]
        }
        return CardDuplicates(reshuffling: paired)
    }

    private func makeEasyPreparedGame() -> AnyPreparedGame {
        .easy(PreparedGame<6>(config: GameConfiguration(), cards: makeEasyCards()))
    }

    private func makeEasyOutcome(clickCount: Int = 4) -> AnyGameOutcome {
        .easy(GameOutcome<6>(level: .easy, clickCount: clickCount, cards: makeEasyCards()))
    }

    // MARK: - init

    func test_init_doesNotCrash() {
        XCTAssertNoThrow(RootVC())
    }

    func test_init_rootVCIsGameSetupVC() {
        XCTAssertTrue(RootVC().viewControllers.first is GameSetupVC)
    }

    func test_init_hidesNavigationBar() {
        XCTAssertTrue(RootVC().isNavigationBarHidden)
    }

    func test_init_setsItselfAsGameSetupNavigator() {
        let root = RootVC()
        let gameSetupVC = root.viewControllers.first as? GameSetupVC
        XCTAssertTrue(gameSetupVC?.navigator === root)
    }

    // MARK: - navigateToLoading (GameSetupNavigatorProtocol)

    func test_navigateToLoading_pushesLoadingVC() {
        // Arrange
        let root = RootVC()

        // Act
        root.navigateToLoading(config: GameConfiguration())
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        // Assert
        XCTAssertTrue(root.topViewController is LoadingVC)
    }

    func test_navigateToLoading_setsNavigatorOnLoadingVC() {
        // Arrange
        let root = RootVC()

        // Act
        root.navigateToLoading(config: GameConfiguration())
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        // Assert
        let loadingVC = root.topViewController as? LoadingVC
        XCTAssertTrue(loadingVC?.navigator === root)
    }

    // MARK: - navigateToGame (LoadingNavigatorProtocol)

    func test_navigateToGame_withEmptyStack_doesNotCrash() {
        let root = RootVC()
        root.setViewControllers([], animated: false)
        XCTAssertNoThrow(root.navigateToGame(makeEasyPreparedGame()))
    }

    func test_navigateToGame_replacesTopVCWithGameVC() {
        // Arrange — [GameSetupVC, stand-in for LoadingVC]
        let root = RootVC()
        root.pushViewController(UIViewController(), animated: false)

        // Act
        root.navigateToGame(makeEasyPreparedGame())

        // Assert — LoadingVC stand-in replaced; player cannot back-swipe to loading
        XCTAssertTrue(root.topViewController is GameVC<6>)
    }

    func test_navigateToGame_stackCountIsUnchanged() {
        // Arrange
        let root = RootVC()
        root.pushViewController(UIViewController(), animated: false)
        let countBefore = root.viewControllers.count

        // Act
        root.navigateToGame(makeEasyPreparedGame())

        // Assert — replace (not push) keeps depth the same
        XCTAssertEqual(root.viewControllers.count, countBefore)
    }

    func test_navigateToGame_setsNavigatorOnGameVC() {
        // Arrange
        let root = RootVC()
        root.pushViewController(UIViewController(), animated: false)

        // Act
        root.navigateToGame(makeEasyPreparedGame())

        // Assert
        let gameVC = root.topViewController as? GameVC<6>
        XCTAssertTrue(gameVC?.navigator === root)
    }

    // MARK: - navigateToGameOver (GameNavigatorProtocol)

    func test_navigateToGameOver_pushesGameOverVC() {
        // Arrange
        let root = RootVC()
        let outcome = makeEasyOutcome()

        // Act
        root.navigateToGameOver(outcome: outcome)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        // Assert
        XCTAssertTrue(root.topViewController is GameOverVC)
    }

    func test_navigateToGameOver_setsNavigatorOnGameOverVC() {
        // Arrange
        let root = RootVC()
        let outcome = makeEasyOutcome()

        // Act
        root.navigateToGameOver(outcome: outcome)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        // Assert
        let gameOverVC = root.topViewController as? GameOverVC
        XCTAssertTrue(gameOverVC?.navigator === root)
    }

    // MARK: - restartGame (GameOverNavigatorProtocol)

    func test_restartGame_withShallowStack_doesNotCrash() {
        let root = RootVC()
        XCTAssertNoThrow(root.restartGame(makeEasyPreparedGame()))
    }

    func test_restartGame_topVCIsGameVC() {
        // Arrange — [GameSetupVC, stand-in GameVC, stand-in GameOverVC]
        let root = RootVC()
        root.setViewControllers([GameSetupVC(), UIViewController(), UIViewController()], animated: false)

        // Act
        root.restartGame(makeEasyPreparedGame())

        // Assert
        XCTAssertTrue(root.topViewController is GameVC<6>)
    }

    func test_restartGame_stackCountDecreasesByOne() {
        // Arrange
        let root = RootVC()
        let initial: [UIViewController] = [GameSetupVC(), UIViewController(), UIViewController()]
        root.setViewControllers(initial, animated: false)

        // Act
        root.restartGame(makeEasyPreparedGame())

        // Assert — removeLast(2) + append(1) = net −1
        XCTAssertEqual(root.viewControllers.count, initial.count - 1)
    }

    // MARK: - quitGame (GameOverNavigatorProtocol)

    func test_quitGame_withoutExtraVCs_doesNotCrash() {
        XCTAssertNoThrow(RootVC().quitGame())
    }

    func test_quitGame_leavesOnlyRootOnStack() {
        // Arrange
        let root = RootVC()
        root.pushViewController(UIViewController(), animated: false)
        root.pushViewController(UIViewController(), animated: false)

        // Act
        root.quitGame()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        // Assert — only GameSetupVC remains
        XCTAssertEqual(root.viewControllers.count, 1)
        XCTAssertTrue(root.viewControllers.first is GameSetupVC)
    }
}
