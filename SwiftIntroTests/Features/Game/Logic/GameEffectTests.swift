//
//  GameEffectTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: build a `GameEffect` value (1–3 lines)
//  - Act:     read `description` (1 line)
//  - Assert:  compare against the expected string (1 line)
//

import Foundation
@testable import SwiftIntro
import XCTest

final class GameEffectTests: XCTestCase {
    private let url = URL(string: "https://example.com/img.jpg")!

    // MARK: - flipCard

    func test_description_flipCard_faceUpTrue() {
        // Arrange
        let effect = GameEffect.flipCard(index: 3, faceUp: true)

        // Act
        let description = effect.description

        // Assert
        XCTAssertEqual(description, "flipCard(index: 3, faceUp: true)")
    }

    func test_description_flipCard_faceUpFalse() {
        // Arrange
        let effect = GameEffect.flipCard(index: 7, faceUp: false)

        // Act
        let description = effect.description

        // Assert
        XCTAssertEqual(description, "flipCard(index: 7, faceUp: false)")
    }

    func test_description_flipCard_zeroIndex() {
        // Arrange
        let effect = GameEffect.flipCard(index: 0, faceUp: true)

        // Act
        let description = effect.description

        // Assert
        XCTAssertEqual(description, "flipCard(index: 0, faceUp: true)")
    }

    // MARK: - scheduleFlipBack

    func test_description_scheduleFlipBack_preservesIndices() {
        // Arrange
        let effect = GameEffect.scheduleFlipBack(index1: 2, index2: 5)

        // Act
        let description = effect.description

        // Assert
        XCTAssertEqual(description, "scheduleFlipBack(index1: 2, index2: 5)")
    }

    func test_description_scheduleFlipBack_preservesOrder() {
        // Arrange — swap the indices to verify order is not normalised
        let effect = GameEffect.scheduleFlipBack(index1: 5, index2: 2)

        // Act
        let description = effect.description

        // Assert
        XCTAssertEqual(description, "scheduleFlipBack(index1: 5, index2: 2)")
    }

    // MARK: - navigateToGameOver

    func test_description_navigateToGameOver_includesOutcome() {
        // Arrange
        let outcome = GameOutcome(
            level: .easy,
            clickCount: 8,
            cards: CardDuplicates(reshuffling: makePairedCards(pairs: 3))
        )
        let effect = GameEffect.navigateToGameOver(outcome: outcome)

        // Act
        let description = effect.description

        // Assert
        let expected = "navigateToGameOver(outcome: \(String(describing: outcome)))"
        XCTAssertEqual(description, expected)
    }

    func test_description_navigateToGameOver_reflectsOutcomeFields() {
        // Arrange
        let outcome = GameOutcome(
            level: .hard,
            clickCount: 42,
            cards: CardDuplicates(reshuffling: makePairedCards(pairs: 10))
        )
        let effect = GameEffect.navigateToGameOver(outcome: outcome)

        // Act
        let description = effect.description

        // Assert — outcome's own description is "{level} - {clickCount} taps"
        XCTAssertTrue(
            description.contains("42 taps"),
            "Expected description to include the outcome's tap count, got: \(description)"
        )
    }

    // MARK: - Helpers

    private func makePairedCards(pairs: Int) -> [Card] {
        (0 ..< pairs).flatMap { index -> [Card] in
            let card = Card(imageUrl: URL(string: "https://example.com/\(index).jpg")!)
            return [card, card]
        }
    }
}
