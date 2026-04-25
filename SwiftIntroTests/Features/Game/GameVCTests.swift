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
//  - `_ = vc.view` triggers `loadView()` and installs `GameView`, wiring the data
//    source/delegate closures through to the view model.
//  - The initial `onModelChanged` callback (which renders the score label) fires
//    later from `viewWillAppear` via `viewModel.start(...)`, so tests that assert
//    on the rendered score must invoke `viewWillAppear(_:)` explicitly.
//  - `vc.viewDidDisappear(false)` calls `viewModel.stop()`, cancelling any pending
//    flip-back timers.
//  - `dataSourceAndDelegate` is retrieved via the collection view's dataSource
//    property, which is set when `GameView` is initialised.
//

import Factory
@testable import SwiftIntro
import UIKit
import XCTest

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

    /// Returns a `CardDuplicates` deck of `count` cards (must be even) where each
    /// image appears exactly twice, satisfying the deck's pair invariant.
    private func makeCards(count: Int) -> CardDuplicates {
        let paired = (0 ..< count / 2).flatMap { i -> [Card] in
            let card = makeCard(index: i)
            return [card, card]
        }
        return CardDuplicates(reshuffling: paired)
    }

    private func makeVC(level: Level = .easy) -> GameVC {
        GameVC(PreparedGame(
            config: GameConfiguration(level: level),
            cards: makeCards(count: level.cardCount)
        ))
    }

    /// Casts `vc.view` to `GameView`. Throws if the type is wrong so the test
    /// terminates immediately rather than continuing with a stand-in instance.
    private func gameView(
        of vc: GameVC,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> GameView {
        try XCTUnwrap(
            vc.view as? GameView,
            "Expected vc.view to be GameView, got \(type(of: vc.view))",
            file: file,
            line: line
        )
    }

    /// Locates the card grid's `UICollectionView` by traversing `GameView`'s
    /// subviews. `GameView.collectionView` is private by design, so tests reach
    /// it through the view hierarchy rather than adding a test-only accessor.
    private func collectionView(
        of vc: GameVC,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> UICollectionView {
        try XCTUnwrap(
            gameView(of: vc, file: file, line: line)
                .subviews.compactMap { $0 as? UICollectionView }.first,
            "No UICollectionView found in GameView subviews",
            file: file,
            line: line
        )
    }

    /// Retrieves the `MemoryDataSourceAndDelegate` from the collection view's `dataSource`
    /// property. Only valid after `viewDidLoad` has run.
    private func dataSourceAndDelegate(
        of vc: GameVC,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> MemoryDataSourceAndDelegate {
        try XCTUnwrap(
            try collectionView(of: vc, file: file, line: line).dataSource as? MemoryDataSourceAndDelegate,
            "Expected dataSource to be MemoryDataSourceAndDelegate",
            file: file,
            line: line
        )
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

    func test_viewDidLoad_setsCollectionViewDataSource() throws {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertNotNil(try collectionView(of: vc).dataSource)
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_setsCollectionViewDelegate() throws {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertNotNil(try collectionView(of: vc).delegate)
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_dataSourceIsMemoryDataSourceAndDelegate() throws {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert
        XCTAssertTrue(try collectionView(of: vc).dataSource is MemoryDataSourceAndDelegate)
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_canSelectCardClosure_returnsTrueForUnmatchedCard() throws {
        // Arrange
        let vc = makeVC()

        // Act
        _ = vc.view

        // Assert — the closure is wired to the view model; a fresh deck has no matched cards
        XCTAssertTrue(try dataSourceAndDelegate(of: vc).canSelectCard(0))
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_configureCellClosure_doesNotCrash() throws {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))
        let ds = try dataSourceAndDelegate(of: vc)

        // Act + Assert — the closure is wired to the view model
        XCTAssertNoThrow(ds.configureCell(cell, 0))
        vc.viewDidDisappear(false)
    }

    func test_viewDidLoad_onCardTappedClosure_doesNotCrash() throws {
        // Arrange
        let vc = makeVC()

        // Act + Assert — the closure is wired to the view model
        _ = vc.view
        let ds = try dataSourceAndDelegate(of: vc)
        XCTAssertNoThrow(ds.onCardTapped(0))
        vc.viewDidDisappear(false)
    }

    func test_viewWillAppear_setsScoreLabelText() throws {
        // Arrange — start() (invoked from viewWillAppear) fires the initial
        // onModelChanged so the score renders.
        let vc = makeVC()
        _ = vc.view

        // Act
        vc.viewWillAppear(false)

        // Assert
        XCTAssertNotNil(try gameView(of: vc).headerView.scoreLabel.text)
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

    // MARK: - data source closures

    func test_canSelectCard_closure_returnsTrueForUnmatchedCard() throws {
        // Arrange
        let vc = makeVC()
        _ = vc.view

        // Act
        let result = try dataSourceAndDelegate(of: vc).canSelectCard(0)

        // Assert — fresh deck has no matched cards
        XCTAssertTrue(result)
        vc.viewDidDisappear(false)
    }

    func test_configureCell_closure_doesNotCrash() throws {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))
        let ds = try dataSourceAndDelegate(of: vc)

        // Act + Assert
        XCTAssertNoThrow(ds.configureCell(cell, 0))
        vc.viewDidDisappear(false)
    }

    func test_onCardTapped_closure_doesNotCrash() throws {
        // Arrange
        let vc = makeVC()
        _ = vc.view
        let ds = try dataSourceAndDelegate(of: vc)

        // Act + Assert — invoking the tap should drive the view model without crashing
        XCTAssertNoThrow(ds.onCardTapped(0))
        vc.viewDidDisappear(false)
    }

    // MARK: - navigateToGameOver

    func test_navigateToGameOver_callsNavigatorWithOutcome() throws {
        // Arrange — easy = 3 pairs. Build a deck and locate matching index pairs by URL.
        let pairedCards = makePairedCards(pairCount: 3)
        let pairs = pairIndices(in: pairedCards)
        let vc = GameVC(PreparedGame(config: GameConfiguration(level: .easy), cards: pairedCards))
        let spy = SpyGameNavigator()
        vc.navigator = spy
        _ = vc.view
        // viewWillAppear wires the navigator callback via viewModel.start(...)
        vc.viewWillAppear(false)
        let exp = expectation(description: "navigateToGameOver called")
        spy.onNavigateToGameOver = { exp.fulfill() }

        // Act — tap each pair; the last match triggers the navigator via ImmediateClock
        let ds = try dataSourceAndDelegate(of: vc)
        for (first, second) in pairs {
            ds.onCardTapped(first)
            ds.onCardTapped(second)
        }

        // Assert — ImmediateClock fires on the next main-queue cycle, well within 1 s
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(spy.lastOutcome)
        vc.viewDidDisappear(false)
    }

    // MARK: - Pairing helpers

    private func makePairedCards(pairCount: Int) -> CardDuplicates {
        let cards = (0 ..< pairCount).flatMap { i -> [Card] in
            let card = Card(imageUrl: URL(string: "https://a.test/pair\(i).jpg")!)
            return [card, card]
        }
        return CardDuplicates(reshuffling: cards)
    }

    private func pairIndices(in deck: CardDuplicates) -> [(Int, Int)] {
        var seen: [URL: Int] = [:]
        var pairs: [(Int, Int)] = []
        for (idx, card) in deck.memoryCards.enumerated() {
            if let first = seen[card.imageUrl] {
                pairs.append((first, idx))
            } else {
                seen[card.imageUrl] = idx
            }
        }
        return pairs
    }
}

private final class SpyGameNavigator: GameNavigatorProtocol {
    var onNavigateToGameOver: (() -> Void)?
    private(set) var lastOutcome: GameOutcome?
    func navigateToGameOver(outcome: GameOutcome) {
        lastOutcome = outcome
        onNavigateToGameOver?()
    }
}
