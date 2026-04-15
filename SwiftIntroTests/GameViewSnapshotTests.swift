//
//  GameViewSnapshotTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import SnapshotTesting
@testable import SwiftIntro
import XCTest

@MainActor
final class GameViewSnapshotTests: XCTestCase {
    private let size = CGSize(width: 393, height: 852)

    private func makeCards(count: Int) -> [CardModel] {
        (0 ..< count).map { i in CardModel(imageUrl: URL(string: "https://a.test/\(i).jpg")!) }
    }

    func test_gameView_defaultAppearance() {
        // Arrange
        let view = GameView()

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }

    func test_gameView_renderedWithEasyModel() {
        // Arrange
        let cards = makeCards(count: 6)
        let model = GameModel(cards: cards, level: .easy)
        let view = GameView()
        view.render(model)

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }

    func test_gameView_renderedWithOneMatch() {
        // Arrange
        var cards = makeCards(count: 6)
        cards[0].isMatched = true
        cards[1].isMatched = true
        var model = GameModel(cards: cards, level: .easy)
        model.matches = 1
        _ = model // suppress unused warning
        let view = GameView()
        view.render(model)

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }
}
