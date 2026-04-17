//
//  CardDuplicatesTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up cards/singles/config (1–5 lines)
//  - Act:     call the initialiser or method under test (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import XCTest
@testable import SwiftIntro

final class CardDuplicatesTests: XCTestCase {

    private let url1 = URL(string: "https://example.com/1.jpg")!
    private let url2 = URL(string: "https://example.com/2.jpg")!
    private let url3 = URL(string: "https://example.com/3.jpg")!

    // MARK: - init(reshuffling:)

    func test_initReshuffling_preservesCardCount() {
        // Arrange
        let cards = [url1, url1, url2, url2].map { Card(imageUrl: $0) }

        // Act
        let deck = CardDuplicates(reshuffling: cards)

        // Assert
        XCTAssertEqual(deck.count, 4)
    }

    func test_initReshuffling_preservesUrl1Frequency() {
        // Arrange
        let cards = [url1, url1, url2, url2, url3, url3].map { Card(imageUrl: $0) }

        // Act
        let deck = CardDuplicates(reshuffling: cards)

        // Assert
        XCTAssertEqual(deck.memoryCards.filter { $0.imageUrl == url1 }.count, 2)
    }

    func test_initReshuffling_preservesUrl2Frequency() {
        // Arrange
        let cards = [url1, url1, url2, url2, url3, url3].map { Card(imageUrl: $0) }

        // Act
        let deck = CardDuplicates(reshuffling: cards)

        // Assert
        XCTAssertEqual(deck.memoryCards.filter { $0.imageUrl == url2 }.count, 2)
    }

    func test_initReshuffling_preservesUrl3Frequency() {
        // Arrange
        let cards = [url1, url1, url2, url2, url3, url3].map { Card(imageUrl: $0) }

        // Act
        let deck = CardDuplicates(reshuffling: cards)

        // Assert
        XCTAssertEqual(deck.memoryCards.filter { $0.imageUrl == url3 }.count, 2)
    }

    // MARK: - init(singles:config:)

    func test_initWithSinglesConfig_easy_produces6Cards() {
        // Arrange
        let singles = makeSingles(count: 6)
        let config = GameConfiguration(level: .easy, searchQuery: "test")

        // Act
        let deck = CardDuplicates(singles: singles, config: config)

        // Assert — easy = 2×3 = 6 cards (3 pairs)
        XCTAssertEqual(deck.count, 6)
    }

    func test_initWithSinglesConfig_normal_produces12Cards() {
        // Arrange
        let singles = makeSingles(count: 10)
        let config = GameConfiguration(level: .normal, searchQuery: "test")

        // Act
        let deck = CardDuplicates(singles: singles, config: config)

        // Assert — normal = 3×4 = 12 cards (6 pairs)
        XCTAssertEqual(deck.count, 12)
    }

    func test_initWithSinglesConfig_hard_produces20Cards() {
        // Arrange
        let singles = makeSingles(count: 15)
        let config = GameConfiguration(level: .hard, searchQuery: "test")

        // Act
        let deck = CardDuplicates(singles: singles, config: config)

        // Assert — hard = 4×5 = 20 cards (10 pairs)
        XCTAssertEqual(deck.count, 20)
    }

    func test_initWithSinglesConfig_eachImageAppearsExactlyTwice() {
        // Arrange
        let singles = makeSingles(count: 6)
        let config = GameConfiguration(level: .easy, searchQuery: "test")

        // Act
        let deck = CardDuplicates(singles: singles, config: config)

        // Assert — build a frequency map and verify every URL appears exactly twice
        var frequency: [URL: Int] = [:]
        for card in deck.memoryCards { frequency[card.imageUrl, default: 0] += 1 }
        XCTAssertTrue(frequency.values.allSatisfy { $0 == 2 }, "Every image must appear exactly twice")
    }

    // MARK: - count

    func test_count_equalsMemoryCardsCount() {
        // Arrange
        let cards = [url1, url2, url1, url2].map { Card(imageUrl: $0) }
        let deck = CardDuplicates(reshuffling: cards)

        // Act + Assert
        XCTAssertEqual(deck.count, deck.memoryCards.count)
    }

    // MARK: - Helpers

    /// Creates a `CardSingles` pool with `count` unique image URLs.
    private func makeSingles(count: Int) -> CardSingles {
        let cards = (0..<count).map { i in Card(imageUrl: URL(string: "https://example.com/\(i).jpg")!) }
        return CardSingles(cards: cards)
    }
}
