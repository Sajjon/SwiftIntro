//
//  GameModelTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up the model (1–5 lines)
//  - Act:     read a property (1 line)
//  - Assert:  verify a single expected value (1 line)
//

@testable import SwiftIntro
import XCTest

final class GameModelTests: XCTestCase {
    private let url = URL(string: "https://example.com/img.jpg")!

    // MARK: - CardModel init

    func test_cardModel_init_isNotFlipped() {
        // Arrange + Act
        let card = CardModel(card: Card(imageUrl: url))

        // Assert
        XCTAssertFalse(card.isFlipped)
    }

    func test_cardModel_init_isNotMatched() {
        // Arrange + Act
        let card = CardModel(card: Card(imageUrl: url))

        // Assert
        XCTAssertFalse(card.isMatched)
    }

    func test_cardModel_init_preservesUrl() {
        // Arrange + Act
        let card = CardModel(card: Card(imageUrl: url))

        // Assert
        XCTAssertEqual(card.card.imageUrl, url)
    }

    // MARK: - GameModel init defaults

    func test_gameModel_init_clickCountIsZero() {
        // Arrange
        let model = makeEasyModel()

        // Act
        let clickCount = model.clickCount

        // Assert
        XCTAssertEqual(clickCount, 0)
    }

    func test_gameModel_init_matchesIsZero() {
        // Arrange
        let model = makeEasyModel()

        // Act
        let matches = model.matches

        // Assert
        XCTAssertEqual(matches, 0)
    }

    func test_gameModel_init_pendingCardIndexIsNil() {
        // Arrange
        let model = makeEasyModel()

        // Act
        let pending = model.pendingCardIndex

        // Assert
        XCTAssertNil(pending)
    }

    func test_gameModel_init_cardCountMatchesInput() {
        // Arrange
        let model = makeEasyModel()

        // Act
        let count = model.cards.count

        // Assert
        XCTAssertEqual(count, 6)
    }

    func test_gameModel_init_preservesLevel() {
        // Arrange
        let model: GameModel<6> = makeModel(level: .hard)

        // Act
        let level = model.level

        // Assert
        XCTAssertEqual(level, .hard)
    }

    // MARK: - totalPairs

    func test_totalPairs_forEasyLevelDeck() {
        // Arrange — easy = 6 cards = 3 pairs
        let cards = (0 ..< 6).map { _ in CardModel(card: Card(imageUrl: url)) }
        let model = GameModel<6>(cards: cards, level: .easy)

        // Act
        let pairs = model.totalPairs

        // Assert
        XCTAssertEqual(pairs, 3)
    }

    func test_totalPairs_forNormalLevelDeck() {
        // Arrange — normal = 12 cards = 6 pairs
        let cards = (0 ..< 12).map { _ in CardModel(card: Card(imageUrl: url)) }
        let model = GameModel<12>(cards: cards, level: .normal)

        // Act
        let pairs = model.totalPairs

        // Assert
        XCTAssertEqual(pairs, 6)
    }

    func test_totalPairs_forHardLevelDeck() {
        // Arrange — hard = 20 cards = 10 pairs
        let cards = (0 ..< 20).map { _ in CardModel(card: Card(imageUrl: url)) }
        let model = GameModel<20>(cards: cards, level: .hard)

        // Act
        let pairs = model.totalPairs

        // Assert
        XCTAssertEqual(pairs, 10)
    }

    func test_totalPairs_forFivePairDeck() {
        // Arrange — 10 cards = 5 pairs
        let model: GameModel<10> = makeModel(level: .easy)

        // Act
        let pairs = model.totalPairs

        // Assert
        XCTAssertEqual(pairs, 5)
    }

    // MARK: - Helpers

    /// Default easy-size helper — 6 cards, `.easy` level.
    private func makeEasyModel() -> GameModel<6> {
        let cards = (0 ..< 6).map { _ in CardModel(card: Card(imageUrl: url)) }
        return GameModel<6>(cards: cards, level: .easy)
    }

    /// Generic helper that defers the card count to the caller's explicit type annotation.
    /// The precondition in `GameModel.init` on pair-match is skipped at test time, so
    /// mismatched (level, N) pairs like `<6>` + `.hard` are allowed for assertions.
    private func makeModel<let N: Int>(level: Level) -> GameModel<N> {
        let cards = (0 ..< N).map { _ in CardModel(card: Card(imageUrl: url)) }
        return GameModel<N>(cards: cards, level: level)
    }
}
