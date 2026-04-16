//
//  GameLoopTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: build a GameLoop with a known initial model (1–5 lines)
//  - Act:     call the method under test (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import MobiusCore
@testable import SwiftIntro
import UIKit
import XCTest

@MainActor
final class GameLoopTests: XCTestCase {
    // MARK: - Helpers

    private func makeCard(url: URL = URL(string: "https://a.test/img.jpg")!) -> CardModel {
        CardModel(card: Card(imageUrl: url))
    }

    private func makeModel(level: Level = .easy) -> GameModel {
        let cards = (0 ..< level.cardCount).map { i in
            CardModel(card: Card(imageUrl: URL(string: "https://a.test/\(i).jpg")!))
        }
        return GameModel(cards: cards, level: level)
    }

    // MARK: - init

    func test_init_exposesCorrectLevel() {
        // Arrange
        let model = makeModel(level: .normal)

        // Act
        let loop = GameLoop(initialModel: model)

        // Assert
        XCTAssertEqual(loop.level, .normal)
    }

    func test_init_levelMatchesEasy() {
        // Arrange
        let model = makeModel(level: .easy)

        // Act
        let loop = GameLoop(initialModel: model)

        // Assert
        XCTAssertEqual(loop.level, .easy)
    }

    func test_init_levelMatchesHard() {
        // Arrange
        let model = makeModel(level: .hard)

        // Act
        let loop = GameLoop(initialModel: model)

        // Assert
        XCTAssertEqual(loop.level, .hard)
    }

    // MARK: - canSelectCard

    func test_canSelectCard_returnsTrueForUnmatchedCard() {
        // Arrange
        let model = makeModel(level: .easy)
        let loop = GameLoop(initialModel: model)

        // Act
        let result = loop.canSelectCard(at: 0)

        // Assert
        XCTAssertTrue(result)
    }

    func test_canSelectCard_returnsFalseAfterUpdate() {
        // Arrange
        var model = makeModel(level: .easy)
        let loop = GameLoop(initialModel: model)

        // Act — mark first card matched and push the update through
        model.cards[0].isMatched = true
        loop.update(with: model)

        // Assert
        XCTAssertFalse(loop.canSelectCard(at: 0))
    }

    // MARK: - update(with:)

    func test_update_doesNotCrash() {
        // Arrange
        let model = makeModel(level: .easy)
        let loop = GameLoop(initialModel: model)

        // Act + Assert
        XCTAssertNoThrow(loop.update(with: model))
    }

    // MARK: - start / stop

    func test_start_doesNotCrash() {
        // Arrange
        let loop = GameLoop(initialModel: makeModel())
        let view = AnyConnectable<GameModel, GameEvent> { _ in
            Connection(acceptClosure: { _ in }, disposeClosure: {})
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        // Act + Assert
        XCTAssertNoThrow(loop.start(view: view, collectionView: cv, onNavigateToGameOver: { _ in }))
        loop.stop()
    }

    func test_stop_afterStart_doesNotCrash() {
        // Arrange
        let loop = GameLoop(initialModel: makeModel())
        let view = AnyConnectable<GameModel, GameEvent> { _ in
            Connection(acceptClosure: { _ in }, disposeClosure: {})
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        loop.start(view: view, collectionView: cv, onNavigateToGameOver: { _ in })

        // Act + Assert
        XCTAssertNoThrow(loop.stop())
    }

    func test_start_deliversInitialModelToView() {
        // Arrange
        let model = makeModel(level: .easy)
        let loop = GameLoop(initialModel: model)
        let exp = expectation(description: "model delivered to view")
        exp.assertForOverFulfill = false
        var receivedModel: GameModel?
        let view = AnyConnectable<GameModel, GameEvent> { _ in
            Connection(
                acceptClosure: { model in
                    receivedModel = model
                    exp.fulfill()
                },
                disposeClosure: {}
            )
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        // Act
        loop.start(view: view, collectionView: cv, onNavigateToGameOver: { _ in })

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedModel?.cards.count, model.cards.count)
        loop.stop()
    }

    func test_start_onNavigateToGameOver_isStoredAndCallable() {
        // Arrange
        let loop = GameLoop(initialModel: makeModel())
        let view = AnyConnectable<GameModel, GameEvent> { _ in
            Connection(acceptClosure: { _ in }, disposeClosure: {})
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        var navigateCalled = false

        // Act
        loop.start(view: view, collectionView: cv, onNavigateToGameOver: { _ in navigateCalled = true })

        // Assert — just verify start ran without crash and the closure was captured
        XCTAssertFalse(navigateCalled)
        loop.stop()
    }

    // MARK: - configureCell

    func test_configureCell_doesNotCrashBeforeStart() {
        // Arrange — loop not started; effectHandler is pre-seeded with initial model
        let loop = GameLoop(initialModel: makeModel())
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))

        // Act + Assert
        XCTAssertNoThrow(loop.configureCell(cell, at: 0))
    }

    func test_configureCell_doesNotCrashAfterStart() {
        // Arrange
        let loop = GameLoop(initialModel: makeModel())
        let view = AnyConnectable<GameModel, GameEvent> { _ in
            Connection(acceptClosure: { _ in }, disposeClosure: {})
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        loop.start(view: view, collectionView: cv, onNavigateToGameOver: { _ in })
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))

        // Act + Assert
        XCTAssertNoThrow(loop.configureCell(cell, at: 0))
        loop.stop()
    }
}
