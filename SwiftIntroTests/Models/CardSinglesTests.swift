//
//  CardSinglesTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

@testable import SwiftIntro
import XCTest

final class CardSinglesTests: XCTestCase {
    private func makeCard(_ index: Int) -> Card {
        Card(imageUrl: URL(string: "https://example.com/\(index).jpg")!)
    }

    // MARK: - ==

    func test_equal_sameCardsSameOrder_areEqual() {
        // Arrange
        let a = CardSingles(cards: [makeCard(1), makeCard(2)])
        let b = CardSingles(cards: [makeCard(1), makeCard(2)])

        // Act + Assert
        XCTAssertEqual(a, b)
    }

    func test_equal_sameCardsDifferentOrder_areEqual() {
        // Arrange — equality is set-based, order-insensitive
        let a = CardSingles(cards: [makeCard(1), makeCard(2)])
        let b = CardSingles(cards: [makeCard(2), makeCard(1)])

        // Act + Assert
        XCTAssertEqual(a, b)
    }

    func test_equal_differentCards_areNotEqual() {
        // Arrange
        let a = CardSingles(cards: [makeCard(1), makeCard(2)])
        let b = CardSingles(cards: [makeCard(1), makeCard(3)])

        // Act + Assert
        XCTAssertNotEqual(a, b)
    }

    // MARK: - hash(into:)

    func test_hash_equalValues_produceEqualHashes() {
        // Arrange
        let a = CardSingles(cards: [makeCard(1), makeCard(2)])
        let b = CardSingles(cards: [makeCard(2), makeCard(1)])

        // Act + Assert — order-insensitive hashing matches equality
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func test_hash_usedInSet_dedupesEqualValues() {
        // Arrange
        let a = CardSingles(cards: [makeCard(1), makeCard(2)])
        let b = CardSingles(cards: [makeCard(2), makeCard(1)])

        // Act
        let set: Set<CardSingles> = [a, b]

        // Assert
        XCTAssertEqual(set.count, 1)
    }
}
