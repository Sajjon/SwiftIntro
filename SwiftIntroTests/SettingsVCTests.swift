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
//    a stand-in for `LoadingDataVC` in the preceding stack position.
//

@testable import SwiftIntro
import UIKit
import XCTest

@MainActor
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

    func test_onStartGame_pushesLoadingDataVC() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        _ = vc.view

        // Act — fire the closure wired in viewDidLoad
        settingsView(of: vc).onStartGame?(GameConfiguration())

        // Assert
        XCTAssertTrue(nav.topViewController is LoadingDataVC)
    }

    func test_onStartGame_setsNavigatorOnLoadingDataVC() {
        // Arrange
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        _ = vc.view

        // Act
        settingsView(of: vc).onStartGame?(GameConfiguration())

        // Assert — SettingsVC wires itself as the navigator so it can receive the callback
        let loadingVC = nav.topViewController as? LoadingDataVC
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
        // Arrange — [settingsVC, stand-in for LoadingDataVC]
        let vc = SettingsVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.pushViewController(UIViewController(), animated: false)

        // Act
        vc.navigateToGame(config: GameConfiguration(), cards: makeCards(count: 6))

        // Assert — LoadingDataVC stand-in is replaced; no way to go back to loading
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
}
