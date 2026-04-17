//
//  GameEffectHandlerTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: build a handler with a known initial model (1–5 lines)
//  - Act:     call the method under test (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import Factory
@testable import SwiftIntro
import UIKit
import XCTest

// MARK: - ImmediateClock

/// Test clock: ignores the requested delay and fires on the next main-queue cycle.
///
/// Defined as `internal` so every test file in this module can share it.
/// Register it in `setUp` via `Container.shared.clock.register { ImmediateClock() }`.
final class ImmediateClock: Clock {
    @discardableResult
    func schedule(
        after _: TimeInterval,
        execute block: @escaping () -> Void
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        DispatchQueue.main.async(execute: item)
        return item
    }
}

// MARK: - Tests

final class GameEffectHandlerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Container.shared.clock.register { ImmediateClock() }
    }

    override func tearDown() {
        Container.shared.clock.reset()
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeCard(
        url: URL = URL(string: "https://a.test/img.jpg")!,
        isFlipped: Bool = false,
        isMatched: Bool = false
    ) -> CardModel {
        var card = CardModel(card: Card(imageUrl: url))
        card.isFlipped = isFlipped
        card.isMatched = isMatched
        return card
    }

    /// Builds a one-card "model" tagged `.easy`. The `.easy` level nominally requires 6
    /// cards, but `GameModel.init` does not enforce that invariant, so a 1-card fixture
    /// is sufficient for the handler tests (which only read `cards[0]`).
    private func makeOneCardModel(_ card: CardModel) -> GameModel<1> {
        GameModel<1>(cards: [card], level: .easy)
    }

    /// Builds a minimal single-card model for tests that don't read any card state.
    /// Using N=1 (rather than N=0) sidesteps any zero-sized `InlineArray` edge cases.
    private func makeMinimalModel() -> GameModel<1> {
        GameModel<1>(cards: [makeCard()], level: .easy)
    }

    private func makeHandler<let N: Int>(model: GameModel<N>) -> GameEffectHandler<N> {
        GameEffectHandler<N>(initialModel: model)
    }

    // MARK: - canSelectCard

    func test_canSelectCard_returnsTrueForUnmatchedCard() {
        // Arrange
        let handler = makeHandler(model: makeOneCardModel(makeCard(isMatched: false)))

        // Act
        let result = handler.canSelectCard(at: 0)

        // Assert
        XCTAssertTrue(result)
    }

    func test_canSelectCard_returnsFalseForMatchedCard() {
        // Arrange
        let handler = makeHandler(model: makeOneCardModel(makeCard(isMatched: true)))

        // Act
        let result = handler.canSelectCard(at: 0)

        // Assert
        XCTAssertFalse(result)
    }

    // MARK: - update(with:)

    func test_update_canSelectCard_reflectsUpdatedModel() {
        // Arrange — initially unmatched
        let handler = makeHandler(model: makeOneCardModel(makeCard(isMatched: false)))

        // Act — update with a model where the card is now matched
        var matched = makeOneCardModel(makeCard(isMatched: false))
        matched.cards[0].isMatched = true
        handler.update(with: matched)

        // Assert
        XCTAssertFalse(handler.canSelectCard(at: 0))
    }

    // MARK: - connect(_:)

    func test_connect_returnsNonNilConnection() {
        // Arrange
        let handler = makeHandler(model: makeMinimalModel())

        // Act
        let connection = handler.connect { _ in }

        // Assert
        XCTAssertNotNil(connection)
    }

    func test_connect_disposeDoesNotCrashWithNoPendingWorkItem() {
        // Arrange
        let handler = makeHandler(model: makeMinimalModel())
        let connection = handler.connect { _ in }

        // Act + Assert — dispose must not crash when no flip-back timer is pending
        XCTAssertNoThrow(connection.dispose())
    }

    // MARK: - flipCard effect (via connect)

    func test_connect_flipCardEffect_doesNotCrashWithNoCollectionView() {
        // Arrange — no collectionView assigned
        let handler = makeHandler(model: makeMinimalModel())
        let connection = handler.connect { _ in }
        let exp = expectation(description: "main queue drain")

        // Act
        connection.accept(.flipCard(index: 0, faceUp: true))
        DispatchQueue.main.async { exp.fulfill() }

        // Assert — must not crash
        waitForExpectations(timeout: 1)
        XCTAssertNil(handler.collectionView)
    }

    func test_connect_flipCardEffect_withCollectionView_doesNotCrash() {
        // Arrange — non-nil collectionView exercises indexPath(for:) even though
        // cellForItem(at:) returns nil (no window) and animateFlip is skipped.
        let cv = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 300, height: 400),
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let handler = makeHandler(model: makeMinimalModel())
        handler.collectionView = cv
        let connection = handler.connect { _ in }
        let exp = expectation(description: "main queue drain")

        // Act
        connection.accept(.flipCard(index: 0, faceUp: true))
        DispatchQueue.main.async { exp.fulfill() }

        // Assert — must not crash; collectionView reference is still set
        waitForExpectations(timeout: 5)
        XCTAssertNotNil(handler.collectionView)
        connection.dispose()
    }

    // MARK: - scheduleFlipBack effect (via connect)

    func test_connect_scheduleFlipBackEffect_dispatchesFlipBackEvent() {
        // Arrange
        let handler = makeHandler(model: makeMinimalModel())
        let exp = expectation(description: "flipBackCards event dispatched")
        var receivedEvent: GameEvent?
        let connection = handler.connect { event in
            receivedEvent = event
            exp.fulfill()
        }

        // Act
        connection.accept(.scheduleFlipBack(index1: 0, index2: 1))

        // Assert — ImmediateClock fires on the next main-queue cycle
        waitForExpectations(timeout: 1)
        if case let .flipBackCards(i1, i2) = receivedEvent {
            XCTAssertEqual(i1, 0)
            XCTAssertEqual(i2, 1)
        } else {
            XCTFail("Expected flipBackCards event")
        }
        connection.dispose()
    }

    func test_connect_scheduleFlipBackEffect_canBeCancelledByDispose() {
        // Arrange
        let handler = makeHandler(model: makeMinimalModel())
        var didDispatch = false
        let connection = handler.connect { _ in didDispatch = true }

        // Act — schedule, then immediately dispose to cancel before the async block fires
        connection.accept(.scheduleFlipBack(index1: 0, index2: 1))
        connection.dispose()

        // Assert — drain one main-queue cycle; the cancelled item must not have fired
        let waiter = expectation(description: "main queue drain")
        DispatchQueue.main.async { waiter.fulfill() }
        waitForExpectations(timeout: 1)
        XCTAssertFalse(didDispatch)
    }

    // MARK: - navigateToGameOver effect (via connect)

    func test_connect_navigateToGameOverEffect_callsOnNavigateToGameOver() throws {
        // Arrange — 2-card deck (1 pair) keeps the `CardDuplicates<2>` invariant happy.
        let card = try Card(imageUrl: XCTUnwrap(URL(string: "https://a.test/0.jpg")))
        let deck = CardDuplicates<2>(reshuffling: [card, card])
        let model = GameModel<2>(
            cards: [CardModel(card: card), CardModel(card: card)],
            level: .easy
        )
        let handler = makeHandler(model: model)
        let exp = expectation(description: "navigate called")
        var receivedOutcome: GameOutcome<2>?
        handler.onNavigateToGameOver = { outcome in
            receivedOutcome = outcome
            exp.fulfill()
        }
        let connection = handler.connect { _ in }
        let outcome = GameOutcome<2>(level: .easy, clickCount: 7, cards: deck)

        // Act
        connection.accept(.navigateToGameOver(outcome: outcome))

        // Assert — ImmediateClock fires on the next main-queue cycle
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedOutcome?.clickCount, 7)
        connection.dispose()
    }
}
