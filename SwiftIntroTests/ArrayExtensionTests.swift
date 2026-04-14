//
//  ArrayExtensionTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up the array under test (1–5 lines)
//  - Act:     call the property or method (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import XCTest
@testable import SwiftIntro

final class ArrayExtensionTests: XCTestCase {

    // MARK: - shuffled (computed property)

    func test_shuffled_preservesElementCount() {
        // Arrange
        let array = [1, 2, 3, 4, 5]

        // Act
        let result = array.shuffled

        // Assert
        XCTAssertEqual(result.count, array.count)
    }

    func test_shuffled_containsAllOriginalElements() {
        // Arrange
        let array = [10, 20, 30, 40, 50]

        // Act
        let result = array.shuffled

        // Assert
        XCTAssertEqual(Set(result), Set(array))
    }

    func test_shuffled_doesNotMutateReceiver() {
        // Arrange
        let array = [1, 2, 3, 4, 5]

        // Act
        _ = array.shuffled

        // Assert — array itself must be unchanged
        XCTAssertEqual(array, [1, 2, 3, 4, 5])
    }

    func test_shuffled_emptyArray_returnsEmpty() {
        // Arrange
        let array: [Int] = []

        // Act
        let result = array.shuffled

        // Assert
        XCTAssertEqual(result, [])
    }

    func test_shuffled_singleElement_returnsSameElement() {
        // Arrange
        let array = [42]

        // Act
        let result = array.shuffled

        // Assert
        XCTAssertEqual(result, [42])
    }

    // MARK: - shuffle() (mutating)

    func test_shuffle_preservesElementCount() {
        // Arrange
        var array = [1, 2, 3, 4, 5, 6]

        // Act
        array.shuffle()

        // Assert
        XCTAssertEqual(array.count, 6)
    }

    func test_shuffle_preservesAllElements() {
        // Arrange
        let original = [1, 2, 3, 4, 5]
        var array = original

        // Act
        array.shuffle()

        // Assert
        XCTAssertEqual(Set(array), Set(original))
    }

    // MARK: - chooseOne

    func test_chooseOne_returnsMemberOfArray() {
        // Arrange
        let array = [10, 20, 30, 40, 50]

        // Act
        let chosen = array.chooseOne

        // Assert
        XCTAssertTrue(array.contains(chosen))
    }

    func test_chooseOne_singleElement_returnsThatElement() {
        // Arrange
        let array = [99]

        // Act
        let chosen = array.chooseOne

        // Assert
        XCTAssertEqual(chosen, 99)
    }

    // MARK: - choose(_:)

    func test_choose_returnsExactlyRequestedCount() {
        // Arrange
        let array = [1, 2, 3, 4, 5, 6, 7, 8]

        // Act
        let result = array.choose(3)

        // Assert
        XCTAssertEqual(result.count, 3)
    }

    func test_choose_returnsOnlyMembersOfOriginalArray() {
        // Arrange
        let array = [10, 20, 30, 40, 50]

        // Act
        let result = array.choose(3)

        // Assert
        XCTAssertTrue(result.allSatisfy { array.contains($0) })
    }

    func test_choose_withCountExceedingLength_returnsWholeArray() {
        // Arrange
        let array = [1, 2, 3]

        // Act
        let result = array.choose(100)

        // Assert
        XCTAssertEqual(result.count, array.count)
    }

    func test_choose_withZeroCount_returnsEmpty() {
        // Arrange
        let array = [1, 2, 3, 4, 5]

        // Act
        let result = array.choose(0)

        // Assert
        XCTAssertEqual(result.count, 0)
    }

    func test_choose_fromEmptyArray_returnsEmpty() {
        // Arrange
        let array: [Int] = []

        // Act
        let result = array.choose(3)

        // Assert
        XCTAssertEqual(result.count, 0)
    }

    func test_choose_fromDistinctArray_containsNoDuplicates() {
        // Arrange — 8 distinct values, choose 5 without replacement
        let array = [1, 2, 3, 4, 5, 6, 7, 8]

        // Act
        let result = array.choose(5)

        // Assert
        XCTAssertEqual(Set(result).count, result.count, "choose must not duplicate elements from a distinct source")
    }
}
