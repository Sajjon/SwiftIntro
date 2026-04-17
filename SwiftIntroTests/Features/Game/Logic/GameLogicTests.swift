//
//  GameLogicTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up the model and any preconditions (1–5 lines)
//  - Act:     call the pure function under test (1 line)
//  - Assert:  verify a single observable outcome (1 line where possible)
//

import MobiusCore
@testable import SwiftIntro
import XCTest

final class GameLogicTests: XCTestCase {
    // MARK: - Fixtures

    private let urlA = URL(string: "https://example.com/a.jpg")!
    private let urlB = URL(string: "https://example.com/b.jpg")!
    private let urlC = URL(string: "https://example.com/c.jpg")!

    /// Returns a `GameModel<6>` with three pairs: urlA×2, urlB×2, urlC×2.
    private func threePairModel() -> GameModel<6> {
        let cards = [urlA, urlA, urlB, urlB, urlC, urlC].map { CardModel(card: Card(imageUrl: $0)) }
        return GameModel<6>(cards: cards, level: .easy)
    }

    /// Returns a `GameModel<2>` with exactly one pair: two cards sharing `urlA`.
    /// The level tag is intentionally loose here — these fixtures exercise `update`
    /// in isolation without needing a valid full-size board.
    private func onePairModel() -> GameModel<2> {
        let cards = [urlA, urlA].map { CardModel(card: Card(imageUrl: $0)) }
        return GameModel<2>(cards: cards, level: .easy)
    }

    // MARK: - Out-of-bounds tap

    func test_cardTapped_outOfBounds_producesNoModelChange() {
        // Arrange
        let model = threePairModel()

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 99))

        // Assert
        XCTAssertNil(result.model, "Out-of-bounds tap must not change the model")
    }

    func test_cardTapped_outOfBounds_producesNoEffects() {
        // Arrange
        let model = threePairModel()

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 99))

        // Assert
        XCTAssertTrue(result.effects.isEmpty)
    }

    // MARK: - Already face-up tap

    func test_cardTapped_alreadyFlipped_producesNoModelChange() {
        // Arrange
        var model = threePairModel()
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 0))

        // Assert
        XCTAssertNil(result.model, "Tap on a face-up card must not change the model")
    }

    func test_cardTapped_alreadyFlipped_producesNoEffects() {
        // Arrange
        var model = threePairModel()
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 0))

        // Assert
        XCTAssertTrue(result.effects.isEmpty)
    }

    // MARK: - Already matched tap

    func test_cardTapped_alreadyMatched_producesNoModelChange() {
        // Arrange
        var model = threePairModel()
        model.cards[0].isMatched = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 0))

        // Assert
        XCTAssertNil(result.model, "Tap on a matched card must not change the model")
    }

    func test_cardTapped_alreadyMatched_producesNoEffects() {
        // Arrange
        var model = threePairModel()
        model.cards[0].isMatched = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 0))

        // Assert
        XCTAssertTrue(result.effects.isEmpty)
    }

    // MARK: - First card of a turn

    func test_cardTapped_firstCard_incrementsClickCount() {
        // Arrange
        let model = threePairModel()

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 0))

        // Assert
        XCTAssertEqual(result.model?.clickCount, 1)
    }

    func test_cardTapped_firstCard_marksCardFlipped() {
        // Arrange
        let model = threePairModel()

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 0))

        // Assert
        XCTAssertEqual(result.model?.cards[0].isFlipped, true)
    }

    func test_cardTapped_firstCard_storesPendingIndex() {
        // Arrange
        let model = threePairModel()

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 2))

        // Assert
        XCTAssertEqual(result.model?.pendingCardIndex, 2)
    }

    func test_cardTapped_firstCard_emitsSingleFlipCardEffect() {
        // Arrange
        let model = threePairModel()

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 0))

        // Assert
        XCTAssertEqual(result.effects.count, 1)
    }

    func test_cardTapped_firstCard_flipEffectIsFaceUp() {
        // Arrange
        let model = threePairModel()

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 0))

        // Assert
        guard case let .flipCard(index, faceUp) = result.effects.first else {
            return XCTFail("Expected .flipCard effect")
        }
        XCTAssertEqual(index, 0)
        XCTAssertTrue(faceUp)
    }

    // MARK: - Second card, no match

    func test_cardTapped_secondCard_noMatch_clearsPendingIndex() {
        // Arrange — urlA (index 0) vs urlB (index 2): no match
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 2))

        // Assert
        XCTAssertNil(result.model?.pendingCardIndex)
    }

    func test_cardTapped_secondCard_noMatch_emitsTwoEffects() {
        // Arrange
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 2))

        // Assert
        XCTAssertEqual(result.effects.count, 2)
    }

    func test_cardTapped_secondCard_noMatch_includesFlipEffect() {
        // Arrange
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 2))

        // Assert
        let hasFlip = result.effects.contains {
            if case let .flipCard(i, faceUp) = $0 { return i == 2 && faceUp }
            return false
        }
        XCTAssertTrue(hasFlip, "Expected .flipCard(index: 2, faceUp: true)")
    }

    func test_cardTapped_secondCard_noMatch_includesScheduleFlipBackEffect() {
        // Arrange
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 2))

        // Assert
        let hasSchedule = result.effects.contains {
            if case let .scheduleFlipBack(i1, i2) = $0 { return i1 == 0 && i2 == 2 }
            return false
        }
        XCTAssertTrue(hasSchedule, "Expected .scheduleFlipBack(index1: 0, index2: 2)")
    }

    func test_cardTapped_secondCard_noMatch_doesNotIncrementMatches() {
        // Arrange
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 2))

        // Assert
        XCTAssertEqual(result.model?.matches, 0)
    }

    // MARK: - Second card, match (not last pair)

    func test_cardTapped_secondCard_match_incrementsMatchCount() {
        // Arrange — urlA at index 0 and urlA at index 1: matching pair
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert
        XCTAssertEqual(result.model?.matches, 1)
    }

    func test_cardTapped_secondCard_match_marksFirstCardAsMatched() {
        // Arrange
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert
        XCTAssertEqual(result.model?.cards[0].isMatched, true)
    }

    func test_cardTapped_secondCard_match_marksSecondCardAsMatched() {
        // Arrange
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert
        XCTAssertEqual(result.model?.cards[1].isMatched, true)
    }

    func test_cardTapped_secondCard_match_clearsPendingIndex() {
        // Arrange
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert
        XCTAssertNil(result.model?.pendingCardIndex)
    }

    func test_cardTapped_secondCard_match_emitsOnlyFlipEffect() {
        // Arrange — intermediate match (not the last pair)
        var model = threePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert — only a flip effect; no navigation since pairs remain
        XCTAssertEqual(result.effects.count, 1)
    }

    // MARK: - Last match → game over

    func test_cardTapped_lastMatch_emitsTwoEffects() {
        // Arrange — one pair: urlA at index 0 and 1
        var model = onePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert — flipCard + navigateToGameOver
        XCTAssertEqual(result.effects.count, 2)
    }

    func test_cardTapped_lastMatch_includesNavigateToGameOverEffect() {
        // Arrange
        var model = onePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert
        let hasNavigation = result.effects.contains {
            if case .navigateToGameOver = $0 { return true }
            return false
        }
        XCTAssertTrue(hasNavigation, "Expected .navigateToGameOver effect on last match")
    }

    func test_cardTapped_lastMatch_navigateOutcomeCarriesLevel() {
        // Arrange
        let cards = [urlA, urlA].map { CardModel(card: Card(imageUrl: $0)) }
        var model = GameModel<2>(cards: cards, level: .hard)
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert
        guard case let .navigateToGameOver(outcome) = result.effects.first(where: {
            if case .navigateToGameOver = $0 { return true }; return false
        }) else { return XCTFail("Expected .navigateToGameOver") }
        XCTAssertEqual(outcome.level, .hard)
    }

    func test_cardTapped_lastMatch_navigateOutcomeCarriesIncrementedClickCount() {
        // Arrange
        var model = onePairModel()
        model.pendingCardIndex = 0
        model.cards[0].isFlipped = true
        model.clickCount = 5

        // Act
        let result = GameLogic.update(model: model, event: .cardTapped(index: 1))

        // Assert — tap itself increments clickCount before the outcome is built
        guard case let .navigateToGameOver(outcome) = result.effects.first(where: {
            if case .navigateToGameOver = $0 { return true }; return false
        }) else { return XCTFail("Expected .navigateToGameOver") }
        XCTAssertEqual(outcome.clickCount, 6)
    }

    // MARK: - flipBackCards event

    func test_flipBackCards_marksFirstCardFaceDown() {
        // Arrange
        var model = threePairModel()
        model.cards[0].isFlipped = true
        model.cards[2].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .flipBackCards(index1: 0, index2: 2))

        // Assert
        XCTAssertEqual(result.model?.cards[0].isFlipped, false)
    }

    func test_flipBackCards_marksSecondCardFaceDown() {
        // Arrange
        var model = threePairModel()
        model.cards[0].isFlipped = true
        model.cards[2].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .flipBackCards(index1: 0, index2: 2))

        // Assert
        XCTAssertEqual(result.model?.cards[2].isFlipped, false)
    }

    func test_flipBackCards_emitsTwoFlipDownEffects() {
        // Arrange
        var model = threePairModel()
        model.cards[0].isFlipped = true
        model.cards[2].isFlipped = true

        // Act
        let result = GameLogic.update(model: model, event: .flipBackCards(index1: 0, index2: 2))

        // Assert
        let flipDownCount = result.effects.count(where: {
            if case let .flipCard(_, faceUp) = $0 { return !faceUp }
            return false
        })
        XCTAssertEqual(flipDownCount, 2)
    }

    func test_flipBackCards_doesNotChangeMatchCount() {
        // Arrange
        var model = threePairModel()
        model.matches = 1

        // Act
        let result = GameLogic.update(model: model, event: .flipBackCards(index1: 0, index2: 2))

        // Assert
        XCTAssertEqual(result.model?.matches, 1)
    }
}
