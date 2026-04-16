//
//  GameHeaderViewSnapshotTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import SnapshotTesting
@testable import SwiftIntro
import XCTest

final class GameHeaderViewSnapshotTests: XCTestCase {
    private let size = CGSize(width: 393, height: 44)

    func test_gameHeaderView_emptyScore() {
        // Arrange
        let header = GameHeaderView()
        header.scoreLabel.text = ""

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: header, as: .image(size: size))
        }
    }

    func test_gameHeaderView_withScore() {
        // Arrange
        let header = GameHeaderView()
        header.scoreLabel.text = String(localized: .Game.pairsFoundUnformatted(pairsFound: 3, totalPairs: 6))

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: header, as: .image(size: size))
        }
    }

    func test_gameHeaderView_fullScore() {
        // Arrange
        let header = GameHeaderView()
        header.scoreLabel.text = String(localized: .Game.pairsFoundUnformatted(pairsFound: 10, totalPairs: 10))

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: header, as: .image(size: size))
        }
    }
}
