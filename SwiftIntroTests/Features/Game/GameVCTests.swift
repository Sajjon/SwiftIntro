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
//  - All tests use the `.easy` (6-card) variant. The generic VC plumbing is
//    identical across levels; one concrete size keeps the helpers readable.
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

    /// Returns a 6-card `CardDuplicates<6>` where each image appears twice,
    /// satisfying the deck's pair invariant.
    private func makeEasyCards() -> CardDuplicates<6> {
        let paired = (0 ..< 3).flatMap { i -> [Card] in
            let card = makeCard(index: i)
            return [card, card]
        }
        return CardDuplicates<6>(reshuffling: paired)
    }

    private func makeVC() -> GameVC<6> {
        GameVC<6>(
            PreparedGame<6>(config: GameConfiguration(level: .easy), cards: makeEasyCards()),
            wrapOutcome: AnyGameOutcome.easy
        )
    }

    private func makeEasyModel(matches: Int = 0) -> GameModel<6> {
        let cards = (0 ..< 6).map {
            CardModel(card: Card(imageUrl: URL(string: "https://a.test/\($0).jpg")!))
        }
        var model = GameModel<6>(cards: cards, level: .easy)
        model.matches = matches
        return model
    }

    /// Casts `vc.view` to `GameView`. Crashes the test if the type is wrong.
    private func gameView(of vc: GameVC<6>) -> GameView {
        // swiftlint:disable:next force_cast
        vc.view as! GameView
    }

    /// Retrieves the `MemoryDataSourceAndDelegate` from the collection view's `dataSource`
    /// property. Only valid after `viewDidLoad` has run.
    private func dataSourceAndDelegate(of vc: GameVC<6>) -> MemoryDataSourceAndDelegate {
        // swiftlint:disable:next force_cast
        gameView(of: vc).collectionView.dataSource as! MemoryDataSourceAndDelegate
    }

    // MARK: - init

    func test_init_doesNotCrash() {
        // Act + Assert
        XCTAssertNoThrow(makeVC())
    }

    func test_init_easy_doesNotCrash() {
        XCTAssertNoThrow(makeVC())
    }

    func test_init_normal_doesNotCrash() {
        // 12-card normal deck
        let paired = (0 ..< 6).flatMap { i -> [Card] in
            let card = makeCard(index: i)
            return [card, card]
        }
        let deck = CardDuplicates<12>(reshuffling: paired)
        XCTAssertNoThrow(GameVC<12>(
            PreparedGame<12>(config: GameConfiguration(level: .normal), cards: deck),
            wrapOutcome: AnyGameOutcome.normal
        ))
    }

    func test_init_hard_doesNotCrash() {
        // 20-card hard deck
        let paired = (0 ..< 10).flatMap { i -> [Card] in
            let card = makeCard(index: i)
            return [card, card]
        }
        let deck = CardDuplicates<20>(reshuffling: paired)
        XCTAssertNoThrow(GameVC<20>(
            PreparedGame<20>(config: GameConfiguration(level: .hard), cards: deck),
            wrapOutcome: AnyGameOutcome.hard
        ))
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
        dataSourceAndDelegate(of: vc).onCardTapped?(2)

        // Assert
        XCTAssertEqual(receivedIndex, 2)
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
        conn.accept(makeEasyModel())

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
        conn.accept(makeEasyModel(matches: 2))

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

    func test_navigateToGameOver_callsNavigatorWithOutcome() {
        // Arrange — 3 paired cards (easy = 3 pairs). Deck is shuffled, so locate
        // matching index pairs by URL after construction.
        let pairedCards = makePairedEasyCards()
        let pairs = pairIndices(in: pairedCards)
        let vc = GameVC<6>(
            PreparedGame<6>(config: GameConfiguration(level: .easy), cards: pairedCards),
            wrapOutcome: AnyGameOutcome.easy
        )
        let spy = SpyGameNavigator()
        vc.navigator = spy
        _ = vc.view
        let exp = expectation(description: "navigateToGameOver called")
        spy.onNavigateToGameOver = { exp.fulfill() }

        // Act — tap each pair; the last match triggers the navigator via ImmediateClock
        let ds = dataSourceAndDelegate(of: vc)
        for (first, second) in pairs {
            ds.onCardTapped?(first)
            ds.onCardTapped?(second)
        }

        // Assert — ImmediateClock fires on the next main-queue cycle, well within 1 s
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(spy.lastOutcome)
        vc.viewDidDisappear(false)
    }

    // MARK: - Pairing helpers

    private func makePairedEasyCards() -> CardDuplicates<6> {
        let cards = (0 ..< 3).flatMap { i -> [Card] in
            let card = Card(imageUrl: URL(string: "https://a.test/pair\(i).jpg")!)
            return [card, card]
        }
        return CardDuplicates<6>(reshuffling: cards)
    }

    private func pairIndices(in deck: CardDuplicates<6>) -> [(Int, Int)] {
        var seen: [URL: Int] = [:]
        var pairs: [(Int, Int)] = []
        for idx in deck.memoryCards.indices {
            let card = deck.memoryCards[idx]
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
    private(set) var lastOutcome: AnyGameOutcome?
    func navigateToGameOver(outcome: AnyGameOutcome) {
        lastOutcome = outcome
        onNavigateToGameOver?()
    }
}
