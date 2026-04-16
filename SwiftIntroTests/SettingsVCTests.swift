//
//  SettingsVCTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern.
//
//  Notes on approach:
//  - `_ = vc.view` triggers loadView + viewDidLoad (wires onStartGame).
//  - `settingsView(of:)` casts `vc.view` to `SettingsView`; only valid after loadView.
//  - `onStartGame?()` fires the closure wired in viewDidLoad — exercising the push
//    path without simulating a real UIKit tap event.
//  - `navigateToGame` is called directly; a plain `UIViewController` acts as
//    a stand-in for `LoadingVC` in the preceding stack position.
//

@testable import SwiftIntro
import UIKit
import XCTest

final class SettingsVCTests: XCTestCase {
    // MARK: - Helpers

    private func makeCard(index: Int) -> Card {
        Card(imageUrl: URL(string: "https://a.test/\(index).jpg")!)
    }

    private func makeCards(count: Int) -> CardDuplicates {
        CardDuplicates(memoryCards: (0 ..< count).map { makeCard(index: $0) })
    }

    /// Casts `vc.view` to `SettingsView`. Only valid after `loadView` has run.
    private func settingsView(of vc: SettingsVC) -> SettingsView {
        // swiftlint:disable:next force_cast
        vc.view as! SettingsView
    }

    // MARK: - init

    func test_init_doesNotCrash() {
        // Act + Assert
        XCTAssertNoThrow(SettingsVC())
    }

    // MARK: - loadView

    func test_view_isSettingsView() {
        // Act + Assert
        XCTAssertTrue(SettingsVC().view is SettingsView)
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_wiresOnStartGame() {
        // Arrange
        let vc = SettingsVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertNotNil(settingsView(of: vc).onStartGame)
    }

    // MARK: - viewWillAppear

    func test_viewWillAppear_hidesNavigationBar() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        _ = vc.view

        // Act
        vc.viewWillAppear(false)

        // Assert
        XCTAssertTrue(nav.isNavigationBarHidden)
    }

    // MARK: - onStartGame

    func test_onStartGame_pushesLoadingVC() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        _ = vc.view

        // Act — fire the closure wired in viewDidLoad
        settingsView(of: vc).onStartGame?(GameConfiguration())

        // Assert
        XCTAssertTrue(nav.topViewController is LoadingVC)
    }

    func test_onStartGame_setsNavigatorOnLoadingVC() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        _ = vc.view

        // Act
        settingsView(of: vc).onStartGame?(GameConfiguration())

        // Assert — SettingsVC wires itself as the navigator so it can receive the callback
        let loadingVC = nav.topViewController as? LoadingVC
        XCTAssertTrue(loadingVC?.navigator === vc)
    }

    // MARK: - navigateToGame (LoadingDataNavigatorProtocol)

    func test_navigateToGame_withoutNavController_doesNotCrash() {
        // Arrange — no nav controller; the guard exits early
        let vc = SettingsVC()

        // Act + Assert
        XCTAssertNoThrow(vc.navigateToGame(config: GameConfiguration(), cards: makeCards(count: 6)))
    }

    func test_navigateToGame_replacesTopVCWithGameVC() {
        // Arrange — [settingsVC, stand-in for LoadingVC]
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.pushViewController(UIViewController(), animated: false)

        // Act
        vc.navigateToGame(config: GameConfiguration(), cards: makeCards(count: 6))

        // Assert — LoadingVC stand-in is replaced; no way to go back to loading
        XCTAssertTrue(nav.topViewController is GameVC)
    }

    func test_navigateToGame_stackCountIsUnchanged() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.pushViewController(UIViewController(), animated: false)
        let countBefore = nav.viewControllers.count

        // Act
        vc.navigateToGame(config: GameConfiguration(), cards: makeCards(count: 6))

        // Assert — replace (not push) keeps the stack depth the same
        XCTAssertEqual(nav.viewControllers.count, countBefore)
    }

    func test_navigateToGame_setsNavigatorOnGameVC() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.pushViewController(UIViewController(), animated: false)

        // Act
        vc.navigateToGame(config: GameConfiguration(), cards: makeCards(count: 6))

        // Assert — SettingsVC wires itself as GameVC's navigator
        let gameVC = nav.topViewController as? GameVC
        XCTAssertTrue(gameVC?.navigator === vc)
    }

    // MARK: - navigateToGameOver (GameNavigatorProtocol)

    func test_navigateToGameOver_withoutNavController_doesNotCrash() {
        // Arrange
        let vc = SettingsVC()
        let outcome = GameOutcome(level: .easy, clickCount: 4, cards: makeCards(count: 6))

        // Act + Assert
        XCTAssertNoThrow(vc.navigateToGameOver(outcome: outcome))
    }

    func test_navigateToGameOver_pushesGameOverVC() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        let outcome = GameOutcome(level: .easy, clickCount: 4, cards: makeCards(count: 6))

        // Act
        vc.navigateToGameOver(outcome: outcome)

        // Assert
        XCTAssertTrue(nav.topViewController is GameOverVC)
    }

    func test_navigateToGameOver_setsNavigatorOnGameOverVC() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        let outcome = GameOutcome(level: .easy, clickCount: 4, cards: makeCards(count: 6))

        // Act
        vc.navigateToGameOver(outcome: outcome)

        // Assert — SettingsVC wires itself as GameOverVC's navigator
        let gameOverVC = nav.topViewController as? GameOverVC
        XCTAssertTrue(gameOverVC?.navigator === vc)
    }

    // MARK: - restartGame (GameOverNavigatorProtocol)

    func test_restartGame_withoutNavController_doesNotCrash() {
        // Arrange
        let vc = SettingsVC()

        // Act + Assert
        XCTAssertNoThrow(vc.restartGame(config: GameConfiguration(), cards: makeCards(count: 6)))
    }

    func test_restartGame_topVCIsGameVC() {
        // Arrange — [settingsVC, stand-in for GameVC, stand-in for GameOverVC]
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.setViewControllers([vc, UIViewController(), UIViewController()], animated: false)

        // Act
        vc.restartGame(config: GameConfiguration(), cards: makeCards(count: 6))

        // Assert — removeLast(2) + append(new GameVC) keeps depth the same
        XCTAssertTrue(nav.topViewController is GameVC)
    }

    func test_restartGame_stackCountDecreasesByOne() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        let initial: [UIViewController] = [vc, UIViewController(), UIViewController()]
        nav.setViewControllers(initial, animated: false)

        // Act
        vc.restartGame(config: GameConfiguration(), cards: makeCards(count: 6))

        // Assert — removeLast(2) + append(1) = net −1
        XCTAssertEqual(nav.viewControllers.count, initial.count - 1)
    }

    // MARK: - quitGame (GameOverNavigatorProtocol)

    func test_quitGame_withoutNavController_doesNotCrash() {
        // Arrange
        let vc = SettingsVC()

        // Act + Assert
        XCTAssertNoThrow(vc.quitGame())
    }

    func test_quitGame_popsToRootViewController() {
        // Arrange — spy records the pop call without depending on UIKit animation timing
        final class SpyNav: UINavigationController {
            private(set) var didPopToRoot = false
            override func popToRootViewController(animated: Bool) -> [UIViewController]? {
                didPopToRoot = true
                return super.popToRootViewController(animated: animated)
            }
        }
        let vc = SettingsVC()
        let nav = SpyNav(rootViewController: vc)
        nav.pushViewController(UIViewController(), animated: false)
        nav.pushViewController(UIViewController(), animated: false)

        // Act
        vc.quitGame()

        // Assert
        XCTAssertTrue(nav.didPopToRoot)
    }
}
