//
//  GameOverViewSnapshotTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import SnapshotTesting
@testable import SwiftIntro
import XCTest

final class GameOverViewSnapshotTests: XCTestCase {
    private let size = CGSize(width: 393, height: 852)

    private func makeOutcome(
        level: Level = .easy,
        clickCount: Int = 10
    ) -> GameOutcome {
        let paired = (0 ..< level.cardCount / 2).flatMap { i -> [Card] in
            let card = Card(imageUrl: URL(string: "https://a.test/\(i).jpg")!)
            return [card, card]
        }
        let deck = CardDuplicates(reshuffling: paired)
        return GameOutcome(level: level, clickCount: clickCount, cards: deck)
    }

    func test_gameOverView_defaultAppearance() {
        // Arrange
        let view = GameOverView()

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }

    func test_gameOverView_withRenderedOutcome() {
        // Arrange
        let view = GameOverView()
        view.render(makeOutcome(clickCount: 12))

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }

    func test_gameOverView_highClickCount() {
        // Arrange
        let view = GameOverView()
        view.render(makeOutcome(level: .hard, clickCount: 99))

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }
}
