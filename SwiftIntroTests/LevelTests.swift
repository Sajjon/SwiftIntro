//
//  LevelTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up the value under test (1–5 lines)
//  - Act:     call the property or initialiser (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import XCTest
@testable import SwiftIntro

final class LevelTests: XCTestCase {

    // MARK: - rowCount

    func test_easy_rowCount_isThree() {
        // Arrange
        let level = Level.easy

        // Act
        let rows = level.rowCount

        // Assert
        XCTAssertEqual(rows, 3)
    }

    func test_normal_rowCount_isFour() {
        // Arrange
        let level = Level.normal

        // Act
        let rows = level.rowCount

        // Assert
        XCTAssertEqual(rows, 4)
    }

    func test_hard_rowCount_isFive() {
        // Arrange
        let level = Level.hard

        // Act
        let rows = level.rowCount

        // Assert
        XCTAssertEqual(rows, 5)
    }

    // MARK: - columnCount

    func test_easy_columnCount_isTwo() {
        // Arrange
        let level = Level.easy

        // Act
        let columns = level.columnCount

        // Assert
        XCTAssertEqual(columns, 2)
    }

    func test_normal_columnCount_isThree() {
        // Arrange
        let level = Level.normal

        // Act
        let columns = level.columnCount

        // Assert
        XCTAssertEqual(columns, 3)
    }

    func test_hard_columnCount_isFour() {
        // Arrange
        let level = Level.hard

        // Act
        let columns = level.columnCount

        // Assert
        XCTAssertEqual(columns, 4)
    }

    // MARK: - cardCount

    func test_easy_cardCount_isSix() {
        // Arrange
        let level = Level.easy

        // Act
        let count = level.cardCount

        // Assert
        XCTAssertEqual(count, 6)   // 2 columns × 3 rows
    }

    func test_normal_cardCount_isTwelve() {
        // Arrange
        let level = Level.normal

        // Act
        let count = level.cardCount

        // Assert
        XCTAssertEqual(count, 12)  // 3 columns × 4 rows
    }

    func test_hard_cardCount_isTwenty() {
        // Arrange
        let level = Level.hard

        // Act
        let count = level.cardCount

        // Assert
        XCTAssertEqual(count, 20)  // 4 columns × 5 rows
    }

    func test_cardCount_equalsRowsTimesColumns_forEasy() {
        // Arrange
        let level = Level.easy

        // Act
        let count = level.cardCount

        // Assert
        XCTAssertEqual(count, level.rowCount * level.columnCount)
    }

    func test_cardCount_equalsRowsTimesColumns_forNormal() {
        // Arrange
        let level = Level.normal

        // Act
        let count = level.cardCount

        // Assert
        XCTAssertEqual(count, level.rowCount * level.columnCount)
    }

    func test_cardCount_equalsRowsTimesColumns_forHard() {
        // Arrange
        let level = Level.hard

        // Act
        let count = level.cardCount

        // Assert
        XCTAssertEqual(count, level.rowCount * level.columnCount)
    }

    // MARK: - segmentedControlIndex

    func test_easy_segmentedControlIndex_isZero() {
        // Arrange
        let level = Level.easy

        // Act
        let index = level.segmentedControlIndex

        // Assert
        XCTAssertEqual(index, 0)
    }

    func test_normal_segmentedControlIndex_isOne() {
        // Arrange
        let level = Level.normal

        // Act
        let index = level.segmentedControlIndex

        // Assert
        XCTAssertEqual(index, 1)
    }

    func test_hard_segmentedControlIndex_isTwo() {
        // Arrange
        let level = Level.hard

        // Act
        let index = level.segmentedControlIndex

        // Assert
        XCTAssertEqual(index, 2)
    }

    // MARK: - init(segmentedControlIndex:)

    func test_initFromSegmentedControlIndex_zero_givesEasy() {
        // Arrange
        let segmentIndex = 0

        // Act
        let level = Level(segmentedControlIndex: segmentIndex)

        // Assert
        XCTAssertEqual(level, .easy)
    }

    func test_initFromSegmentedControlIndex_one_givesNormal() {
        // Arrange
        let segmentIndex = 1

        // Act
        let level = Level(segmentedControlIndex: segmentIndex)

        // Assert
        XCTAssertEqual(level, .normal)
    }

    func test_initFromSegmentedControlIndex_two_givesHard() {
        // Arrange
        let segmentIndex = 2

        // Act
        let level = Level(segmentedControlIndex: segmentIndex)

        // Assert
        XCTAssertEqual(level, .hard)
    }

    // MARK: - Round-trip

    func test_segmentedControlIndex_roundTrips_forEasy() {
        // Arrange
        let level = Level.easy

        // Act
        let roundTripped = Level(segmentedControlIndex: level.segmentedControlIndex)

        // Assert
        XCTAssertEqual(roundTripped, level)
    }

    func test_segmentedControlIndex_roundTrips_forNormal() {
        // Arrange
        let level = Level.normal

        // Act
        let roundTripped = Level(segmentedControlIndex: level.segmentedControlIndex)

        // Assert
        XCTAssertEqual(roundTripped, level)
    }

    func test_segmentedControlIndex_roundTrips_forHard() {
        // Arrange
        let level = Level.hard

        // Act
        let roundTripped = Level(segmentedControlIndex: level.segmentedControlIndex)

        // Assert
        XCTAssertEqual(roundTripped, level)
    }
}
