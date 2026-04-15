//
//  GameVCTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: build a GameVC with a known config and card deck (1–5 lines)
//  - Act:     trigger the lifecycle event or method under test (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//
//  Notes on approach:
//  - `_ = vc.view` triggers loadView + viewDidLoad (starts the Mobius loop).
//  - `vc.viewDidDisappear(false)` stops the loop after each such test.
//  - `dataSourceAndDelegate` is retrieved via the collectionView's dataSource
//    property, which is set to it during `setupCollectionView`.
//  - `connect` is called a second time in some tests to capture events with a
//    test-controlled consumer; this overwrites the loop's internal wiring of
//    `onCardTapped`, which is safe in a test context.
//

import Factory
import MobiusCore
@testable import SwiftIntro
import UIKit
import XCTest

@MainActor
final class GameVCTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Container.shared.clock.register { ImmediateClock() }
    }

    override func tearDown() {
        Container.shared.clock.reset()
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeCard(index: Int) -> Card {
        Card(imageUrl: URL(string: "https://a.test/\(index).jpg")!)
    }

    /// Returns a `CardDuplicates` deck with `count` distinct cards (not paired — suitable for
    /// direct `GameVC` construction without requiring a real shuffle).
    private func makeCards(count: Int) -> CardDuplicates {
        CardDuplicates(memoryCards: (0 ..< count).map { makeCard(index: $0) })
    }

    private func makeVC(level: Level = .easy) -> GameVC {
        GameVC(
            config: GameConfiguration(level: level),
            cards: makeCards(count: level.cardCount)
        )
    }

    private func makeModel(
        level: Level = .easy,
        matches: Int = 0
    ) -> GameModel {
        let cards = (0 ..< level.cardCount).map {
            CardModel(imageUrl: URL(string: "https://a.test/\($0).jpg")!)
        }
        var model = GameModel(cards: cards, level: level)
        model.matches = matches
        return model
    }

    /// Casts `vc.view` to `GameView`. Crashes the test if the type is wrong.
    private func gameView(of vc: GameVC) -> GameView {
        // swiftlint:disable:next force_cast
        vc.view as! GameView
    }

    /// Retrieves the `MemoryDataSourceAndDelegate` from the collection view's `dataSource`
    /// property. Only valid after `viewDidLoad` has run.
    private func dataSourceAndDelegate(of vc: GameVC) -> MemoryDataSourceAndDelegate {
        // swiftlint:disable:next force_cast
        gameView(of: vc).collectionView.dataSource as! MemoryDataSourceAndDelegate
    }

    // MARK: - init

    func test_init_doesNotCrash() {
        // Act + Assert
        XCTAssertNoThrow(makeVC())
    }

    func test_init_easy_doesNotCrash() {
        XCTAssertNoThrow(makeVC(level: .easy))
    }

    func test_init_normal_doesNotCrash() {
        XCTAssertNoThrow(makeVC(level: .normal))
    }

    func test_init_hard_doesNotCrash() {
        XCTAssertNoThrow(makeVC(level: .hard))
    }

    // MARK: - loadView

    func test_view_isGameView() {
        // Act + Assert
        XCTAssertTrue(makeVC().view is GameView)
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_setsCollectionViewDataSource() {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertNotNil(gameView(of: vc).collectionView.dataSource)
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_setsCollectionViewDelegate() {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertNotNil(gameView(of: vc).collectionView.delegate)
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_dataSourceIsMemoryDataSourceAndDelegate() {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertTrue(gameView(of: vc).collectionView.dataSource is MemoryDataSourceAndDelegate)
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_canSelectCardClosureIsWired() {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert — the closure is set so the data source can gate taps
        XCTAssertNotNil(dataSourceAndDelegate(of: vc).canSelectCard)
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_configureCellClosureIsWired() {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert — the closure is set so cells are configured on willDisplay
        XCTAssertNotNil(dataSourceAndDelegate(of: vc).configureCell)
        vc.viewDidDisappear(false)
    }

    // MARK: - viewWillAppear

    func test_viewWillAppear_hidesNavigationBar() {
        // Arrange — embed in a nav controller so the property is observable
        let vc = makeVC()
        let nav = UINavigationController(rootViewController: vc)
        _ = vc.view

        // Act
        vc.viewWillAppear(false)

        // Assert
        XCTAssertTrue(nav.isNavigationBarHidden)
        vc.viewDidDisappear(false)
    }

    // MARK: - viewDidDisappear

    func test_viewDidDisappear_doesNotCrash() {
        // Arrange
        let vc = makeVC()
        _ = vc.view

        // Act + Assert
        XCTAssertNoThrow(vc.viewDidDisappear(false))
    }

    func test_viewDidDisappear_calledTwice_doesNotCrash() {
        // Arrange — guard against double-stop if a VC disappears more than once
        let vc = makeVC()
        _ = vc.view

        // Act + Assert
        vc.viewDidDisappear(false)
        XCTAssertNoThrow(vc.viewDidDisappear(false))
    }

    // MARK: - connect

    func test_connect_onCardTapped_dispatchesCardTappedIndex() {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        var receivedIndex: Int?
        let conn = vc.connect { event in
            if case let .cardTapped(index) = event { receivedIndex = index }
        }

        // Act — fire the wired closure directly, bypassing UICollectionView
        dataSourceAndDelegate(of: vc).onCardTapped?(7)

        // Assert
        XCTAssertEqual(receivedIndex, 7)
        conn.dispose()
        vc.viewDidDisappear(false)
    }

    func test_connect_onCardTapped_dispatchesCorrectIndexForEachCall() {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        var indices: [Int] = []
        let conn = vc.connect { event in
            if case let .cardTapped(index) = event { indices.append(index) }
        }

        // Act
        dataSourceAndDelegate(of: vc).onCardTapped?(0)
        dataSourceAndDelegate(of: vc).onCardTapped?(3)

        // Assert
        XCTAssertEqual(indices, [0, 3])
        conn.dispose()
        vc.viewDidDisappear(false)
    }

    func test_connect_acceptClosure_setsScoreLabelText() {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        let conn = vc.connect { _ in }

        // Act
        conn.accept(makeModel())

        // Assert — render() always sets the score label to a non-nil string
        XCTAssertNotNil(gameView(of: vc).headerView.scoreLabel.text)
        conn.dispose()
        vc.viewDidDisappear(false)
    }

    func test_connect_acceptClosure_reflectsMatchCountInScoreLabel() {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        let conn = vc.connect { _ in }

        // Act
        conn.accept(makeModel(matches: 2))

        // Assert — the score label text contains the current match count
        XCTAssertTrue(gameView(of: vc).headerView.scoreLabel.text?.contains("2") ?? false)
        conn.dispose()
        vc.viewDidDisappear(false)
    }

    func test_connect_disposeClosure_nilsOnCardTapped() {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        let conn = vc.connect { _ in }
        XCTAssertNotNil(dataSourceAndDelegate(of: vc).onCardTapped)

        // Act
        conn.dispose()

        // Assert — disposeClosure clears the closure so taps are silenced after disconnect
        XCTAssertNil(dataSourceAndDelegate(of: vc).onCardTapped)
        vc.viewDidDisappear(false)
    }

    // MARK: - wireDataSourceClosures

    func test_canSelectCard_closure_returnsTrueForUnmatchedCard() {
        // Arrange
        let vc = makeVC()
        _ = vc.view

        // Act — invoke the canSelectCard closure body wired in wireDataSourceClosures
        let result = dataSourceAndDelegate(of: vc).canSelectCard?(0)

        // Assert — fresh model has no matched cards
        XCTAssertEqual(result, true)
        vc.viewDidDisappear(false)
    }

    func test_configureCell_closure_doesNotCrash() {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))

        // Act + Assert — invoke the configureCell closure body wired in wireDataSourceClosures
        XCTAssertNoThrow(dataSourceAndDelegate(of: vc).configureCell?(cell, 0))
        vc.viewDidDisappear(false)
    }

    // MARK: - navigateToGameOver

    func test_navigateToGameOver_pushesGameOverVC() {
        // Arrange — build properly paired cards so all 3 easy pairs can be matched.
        // Adjacent indices share a URL: (0,1), (2,3), (4,5).
        let pairURL: (Int) -> URL = { URL(string: "https://a.test/pair\($0).jpg")! }
        let pairedCards = CardDuplicates(memoryCards: (0 ..< 3).flatMap { i -> [Card] in
            let url = pairURL(i)
            return [Card(imageUrl: url), Card(imageUrl: url)]
        })
        let vc = GameVC(config: GameConfiguration(level: .easy), cards: pairedCards)
        // SpyNav fulfils the expectation the moment pushViewController is called —
        // no fixed time delay needed because ImmediateClock fires on the next queue cycle.
        final class SpyNav: UINavigationController {
            var onPush: (() -> Void)?
            override func pushViewController(
                _ viewController: UIViewController,
                animated: Bool
            ) {
                super.pushViewController(viewController, animated: animated)
                onPush?()
            }
        }
        let nav = SpyNav(rootViewController: UIViewController())
        nav.pushViewController(vc, animated: false)
        _ = vc.view
        // Arm the spy AFTER vc is already on the stack so its own push doesn't fire it.
        let exp = expectation(description: "game over navigation")
        nav.onPush = { exp.fulfill() }

        // Act — tap each pair; the last match triggers navigateToGameOver via ImmediateClock
        let ds = dataSourceAndDelegate(of: vc)
        for i in stride(from: 0, to: Level.easy.cardCount, by: 2) {
            ds.onCardTapped?(i)
            ds.onCardTapped?(i + 1)
        }

        // Assert — ImmediateClock fires on the next main-queue cycle, well within 1 s
        waitForExpectations(timeout: 1)
        XCTAssertTrue(nav.topViewController is GameOverVC)
        vc.viewDidDisappear(false)
    }
}
