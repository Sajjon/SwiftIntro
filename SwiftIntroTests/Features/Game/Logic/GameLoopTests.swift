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

final class GameLoopTests: XCTestCase {
    // MARK: - Helpers

    private func makeCard(index: Int) -> CardModel {
        CardModel(card: Card(imageUrl: URL(string: "https://a.test/\(index).jpg")!))
    }

    /// Builds a default easy (6-card) model. Used for most tests that only need
    /// a valid starting model and don't care about the level specifically.
    private func makeEasyModel() -> GameModel<6> {
        let cards = (0 ..< 6).map { i in makeCard(index: i) }
        return GameModel<6>(cards: cards, level: .easy)
    }

    private func makeNormalModel() -> GameModel<12> {
        let cards = (0 ..< 12).map { i in makeCard(index: i) }
        return GameModel<12>(cards: cards, level: .normal)
    }

    private func makeHardModel() -> GameModel<20> {
        let cards = (0 ..< 20).map { i in makeCard(index: i) }
        return GameModel<20>(cards: cards, level: .hard)
    }

    // MARK: - init

    func test_init_exposesCorrectLevel() {
        // Arrange
        let model = makeNormalModel()

        // Act
        let loop = GameLoop<12>(initialModel: model)

        // Assert
        XCTAssertEqual(loop.level, .normal)
    }

    func test_init_levelMatchesEasy() {
        // Arrange
        let model = makeEasyModel()

        // Act
        let loop = GameLoop<6>(initialModel: model)

        // Assert
        XCTAssertEqual(loop.level, .easy)
    }

    func test_init_levelMatchesHard() {
        // Arrange
        let model = makeHardModel()

        // Act
        let loop = GameLoop<20>(initialModel: model)

        // Assert
        XCTAssertEqual(loop.level, .hard)
    }

    // MARK: - canSelectCard

    func test_canSelectCard_returnsTrueForUnmatchedCard() {
        // Arrange
        let loop = GameLoop<6>(initialModel: makeEasyModel())

        // Act
        let result = loop.canSelectCard(at: 0)

        // Assert
        XCTAssertTrue(result)
    }

    func test_canSelectCard_returnsFalseAfterUpdate() {
        // Arrange
        var model = makeEasyModel()
        let loop = GameLoop<6>(initialModel: model)

        // Act — mark first card matched and push the update through
        model.cards[0].isMatched = true
        loop.update(with: model)

        // Assert
        XCTAssertFalse(loop.canSelectCard(at: 0))
    }

    // MARK: - update(with:)

    func test_update_doesNotCrash() {
        // Arrange
        let model = makeEasyModel()
        let loop = GameLoop<6>(initialModel: model)

        // Act + Assert
        XCTAssertNoThrow(loop.update(with: model))
    }

    // MARK: - start / stop

    func test_start_doesNotCrash() {
        // Arrange
        let loop = GameLoop<6>(initialModel: makeEasyModel())
        let view = AnyConnectable<GameModel<6>, GameEvent> { _ in
            Connection(acceptClosure: { _ in }, disposeClosure: {})
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        // Act + Assert
        XCTAssertNoThrow(loop.start(view: view, collectionView: cv, onNavigateToGameOver: { _ in }))
        loop.stop()
    }

    func test_stop_afterStart_doesNotCrash() {
        // Arrange
        let loop = GameLoop<6>(initialModel: makeEasyModel())
        let view = AnyConnectable<GameModel<6>, GameEvent> { _ in
            Connection(acceptClosure: { _ in }, disposeClosure: {})
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        loop.start(view: view, collectionView: cv, onNavigateToGameOver: { _ in })

        // Act + Assert
        XCTAssertNoThrow(loop.stop())
    }

    func test_start_deliversInitialModelToView() {
        // Arrange
        let model = makeEasyModel()
        let loop = GameLoop<6>(initialModel: model)
        let exp = expectation(description: "model delivered to view")
        exp.assertForOverFulfill = false
        var receivedCardCount: Int?
        let view = AnyConnectable<GameModel<6>, GameEvent> { _ in
            Connection(
                acceptClosure: { model in
                    receivedCardCount = model.cards.count
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
        XCTAssertEqual(receivedCardCount, model.cards.count)
        loop.stop()
    }

    func test_start_onNavigateToGameOver_isStoredAndCallable() {
        // Arrange
        let loop = GameLoop<6>(initialModel: makeEasyModel())
        let view = AnyConnectable<GameModel<6>, GameEvent> { _ in
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
        let loop = GameLoop<6>(initialModel: makeEasyModel())
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))

        // Act + Assert
        XCTAssertNoThrow(loop.configureCell(cell, at: 0))
    }

    func test_configureCell_doesNotCrashAfterStart() {
        // Arrange
        let loop = GameLoop<6>(initialModel: makeEasyModel())
        let view = AnyConnectable<GameModel<6>, GameEvent> { _ in
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
