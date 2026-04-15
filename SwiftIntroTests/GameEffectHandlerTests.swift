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

@testable import SwiftIntro
import UIKit
import XCTest

final class GameEffectHandlerTests: XCTestCase {
    // MARK: - Helpers

    private func makeCard(
        url: URL = URL(string: "https://a.test/img.jpg")!,
        isFlipped: Bool = false,
        isMatched: Bool = false
    ) -> CardModel {
        var card = CardModel(imageUrl: url)
        card.isFlipped = isFlipped
        card.isMatched = isMatched
        return card
    }

    private func makeModel(
        cards: [CardModel] = [],
        level: Level = .easy
    ) -> GameModel {
        GameModel(cards: cards, level: level)
    }

    private func makeHandler(
        model: GameModel? = nil,
        level: Level = .easy
    ) -> GameEffectHandler {
        let initialModel = model ?? makeModel(level: level)
        return GameEffectHandler(level: level, initialModel: initialModel)
    }

    // MARK: - canSelectCard

    func test_canSelectCard_returnsTrueForUnmatchedCard() {
        // Arrange
        let cards = [makeCard(isMatched: false)]
        let handler = makeHandler(model: makeModel(cards: cards))

        // Act
        let result = handler.canSelectCard(at: 0)

        // Assert
        XCTAssertTrue(result)
    }

    func test_canSelectCard_returnsFalseForMatchedCard() {
        // Arrange
        let cards = [makeCard(isMatched: true)]
        let handler = makeHandler(model: makeModel(cards: cards))

        // Act
        let result = handler.canSelectCard(at: 0)

        // Assert
        XCTAssertFalse(result)
    }

    // MARK: - update(with:)

    func test_update_canSelectCard_reflectsUpdatedModel() {
        // Arrange — initially unmatched
        let cards = [makeCard(isMatched: false)]
        let handler = makeHandler(model: makeModel(cards: cards))

        // Act — update with a model where the card is now matched
        var matched = makeModel(cards: cards)
        matched.cards[0].isMatched = true
        handler.update(with: matched)

        // Assert
        XCTAssertFalse(handler.canSelectCard(at: 0))
    }

    // MARK: - connect(_:)

    func test_connect_returnsNonNilConnection() {
        // Arrange
        let handler = makeHandler()

        // Act
        let connection = handler.connect { _ in }

        // Assert
        XCTAssertNotNil(connection)
    }

    func test_connect_disposeDoesNotCrashWithNoPendingWorkItem() {
        // Arrange
        let handler = makeHandler()
        let connection = handler.connect { _ in }

        // Act + Assert — dispose must not crash when no flip-back timer is pending
        XCTAssertNoThrow(connection.dispose())
    }

    // MARK: - flipCard effect (via connect)

    func test_connect_flipCardEffect_doesNotCrashWithNoCollectionView() {
        // Arrange — no collectionView assigned
        let handler = makeHandler()
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
        let handler = makeHandler()
        handler.collectionView = cv
        let connection = handler.connect { _ in }
        let exp = expectation(description: "main queue drain")

        // Act
        connection.accept(.flipCard(index: 0, faceUp: true))
        DispatchQueue.main.async { exp.fulfill() }

        // Assert — must not crash; collectionView reference is still set
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(handler.collectionView)
        connection.dispose()
    }

    // MARK: - scheduleFlipBack effect (via connect)

    func test_connect_scheduleFlipBackEffect_dispatchesFlipBackEvent() {
        // Arrange
        let handler = makeHandler()
        let exp = expectation(description: "flipBackCards event dispatched")
        var receivedEvent: GameEvent?
        let connection = handler.connect { event in
            receivedEvent = event
            exp.fulfill()
        }

        // Act
        connection.accept(.scheduleFlipBack(index1: 0, index2: 1))

        // Assert
        waitForExpectations(timeout: 2)
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
        let handler = makeHandler()
        var didDispatch = false
        let connection = handler.connect { _ in didDispatch = true }

        // Act — schedule, then immediately dispose to cancel
        connection.accept(.scheduleFlipBack(index1: 0, index2: 1))
        connection.dispose()

        // Assert — after the 1-second delay, no event should have fired
        let waiter = expectation(description: "wait past delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { waiter.fulfill() }
        waitForExpectations(timeout: 2)
        XCTAssertFalse(didDispatch)
    }

    // MARK: - navigateToGameOver effect (via connect)

    func test_connect_navigateToGameOverEffect_callsOnNavigateToGameOver() {
        // Arrange
        let handler = makeHandler()
        let exp = expectation(description: "navigate called")
        var receivedOutcome: GameOutcome?
        handler.onNavigateToGameOver = { outcome in
            receivedOutcome = outcome
            exp.fulfill()
        }
        let connection = handler.connect { _ in }
        let deck = CardDuplicates(memoryCards: [])
        let outcome = GameOutcome(level: .easy, clickCount: 7, cards: deck)

        // Act
        connection.accept(.navigateToGameOver(outcome: outcome))

        // Assert
        waitForExpectations(timeout: 2)
        XCTAssertEqual(receivedOutcome?.clickCount, 7)
        connection.dispose()
    }
}
