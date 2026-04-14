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

import XCTest
@testable import SwiftIntro

final class GameModelTests: XCTestCase {

    private let url = URL(string: "https://example.com/img.jpg")!

    // MARK: - CardModel init

    func test_cardModel_init_isNotFlipped() {
        // Arrange + Act
        let card = CardModel(imageUrl: url)

        // Assert
        XCTAssertFalse(card.isFlipped)
    }

    func test_cardModel_init_isNotMatched() {
        // Arrange + Act
        let card = CardModel(imageUrl: url)

        // Assert
        XCTAssertFalse(card.isMatched)
    }

    func test_cardModel_init_preservesUrl() {
        // Arrange + Act
        let card = CardModel(imageUrl: url)

        // Assert
        XCTAssertEqual(card.imageUrl, url)
    }

    // MARK: - GameModel init defaults

    func test_gameModel_init_clickCountIsZero() {
        // Arrange
        let model = makeModel(pairs: 3)

        // Act
        let clickCount = model.clickCount

        // Assert
        XCTAssertEqual(clickCount, 0)
    }

    func test_gameModel_init_matchesIsZero() {
        // Arrange
        let model = makeModel(pairs: 3)

        // Act
        let matches = model.matches

        // Assert
        XCTAssertEqual(matches, 0)
    }

    func test_gameModel_init_pendingCardIndexIsNil() {
        // Arrange
        let model = makeModel(pairs: 3)

        // Act
        let pending = model.pendingCardIndex

        // Assert
        XCTAssertNil(pending)
    }

    func test_gameModel_init_cardCountMatchesInput() {
        // Arrange
        let model = makeModel(pairs: 3)

        // Act
        let count = model.cards.count

        // Assert
        XCTAssertEqual(count, 6)
    }

    func test_gameModel_init_preservesLevel() {
        // Arrange
        let model = makeModel(pairs: 3, level: .hard)

        // Act
        let level = model.level

        // Assert
        XCTAssertEqual(level, .hard)
    }

    // MARK: - totalPairs

    func test_totalPairs_isHalfOfCardCount() {
        // Arrange
        let model = makeModel(pairs: 5)

        // Act
        let pairs = model.totalPairs

        // Assert
        XCTAssertEqual(pairs, 5)
    }

    func test_totalPairs_forEasyLevelDeck() {
        // Arrange — easy = 6 cards = 3 pairs
        let cards = (0..<6).map { _ in CardModel(imageUrl: url) }
        let model = GameModel(cards: cards, level: .easy)

        // Act
        let pairs = model.totalPairs

        // Assert
        XCTAssertEqual(pairs, 3)
    }

    func test_totalPairs_forNormalLevelDeck() {
        // Arrange — normal = 12 cards = 6 pairs
        let cards = (0..<12).map { _ in CardModel(imageUrl: url) }
        let model = GameModel(cards: cards, level: .normal)

        // Act
        let pairs = model.totalPairs

        // Assert
        XCTAssertEqual(pairs, 6)
    }

    func test_totalPairs_forHardLevelDeck() {
        // Arrange — hard = 20 cards = 10 pairs
        let cards = (0..<20).map { _ in CardModel(imageUrl: url) }
        let model = GameModel(cards: cards, level: .hard)

        // Act
        let pairs = model.totalPairs

        // Assert
        XCTAssertEqual(pairs, 10)
    }

    // MARK: - Helpers

    private func makeModel(pairs: Int, level: Level = .easy) -> GameModel {
        let cards = (0..<pairs * 2).map { _ in CardModel(imageUrl: url) }
        return GameModel(cards: cards, level: level)
    }
}
