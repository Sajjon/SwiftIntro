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

@testable import SwiftIntro
import XCTest

final class ArrayExtensionTests: XCTestCase {
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
