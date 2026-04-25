//
//  GameViewModelTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: build a view model with a known prepared game (1–5 lines)
//  - Act:     call the method under test (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import Factory
@testable import SwiftIntro
import UIKit
import XCTest

final class GameViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Container.shared.clock.register { ImmediateClock() }
    }

    override func tearDown() {
        Container.shared.clock.reset()
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeCard(index: Int) -> Card {
        Card(imageUrl: URL(string: "https://a.test/\(index).jpg")!)
    }

    /// Returns a `CardDuplicates` deck of `count` cards (must be even) where each
    /// image appears exactly twice. Order is shuffled inside `CardDuplicates.init`.
    private func makeShuffledDeck(count: Int) -> CardDuplicates {
        let paired = (0 ..< count / 2).flatMap { i -> [Card] in
            let card = makeCard(index: i)
            return [card, card]
        }
        return CardDuplicates(reshuffling: paired)
    }

    /// Returns a deck whose `memoryCards` are deterministically ordered as
    /// `[A, A, B, B, C, C, ...]` so the tests can rely on specific indices being
    /// matching pairs (0/1, 2/3, ...).
    private func makeOrderedDeck(pairCount: Int) -> CardDuplicates {
        let canonical = (0 ..< pairCount).flatMap { i -> [Card] in
            let card = makeCard(index: i)
            return [card, card]
        }
        return CardDuplicates(ordered: canonical)
    }

    private func makeViewModel(
        level: Level = .easy,
        deck: CardDuplicates? = nil
    ) -> GameViewModel {
        let cards = deck ?? makeShuffledDeck(count: level.cardCount)
        return GameViewModel(PreparedGame(config: GameConfiguration(level: level), cards: cards))
    }

    // MARK: - init

    func test_init_easy_levelMatches() {
        // Act
        let vm = makeViewModel(level: .easy)

        // Assert
        XCTAssertEqual(vm.level, .easy)
    }

    func test_init_normal_levelMatches() {
        // Act
        let vm = makeViewModel(level: .normal)

        // Assert
        XCTAssertEqual(vm.level, .normal)
    }

    func test_init_hard_levelMatches() {
        // Act
        let vm = makeViewModel(level: .hard)

        // Assert
        XCTAssertEqual(vm.level, .hard)
    }

    // MARK: - start

    func test_start_firesOnModelChangedWithInitialModel() {
        // Arrange
        let vm = makeViewModel()
        var receivedModel: GameModel?

        // Act
        vm.start(
            onModelChanged: { receivedModel = $0 },
            onFlipCard: { _, _ in },
            onNavigateToGameOver: { _ in }
        )

        // Assert
        XCTAssertEqual(receivedModel?.matches, 0)
    }

    func test_start_initialModelHasZeroClickCount() {
        // Arrange
        let vm = makeViewModel()
        var receivedModel: GameModel?

        // Act
        vm.start(
            onModelChanged: { receivedModel = $0 },
            onFlipCard: { _, _ in },
            onNavigateToGameOver: { _ in }
        )

        // Assert
        XCTAssertEqual(receivedModel?.clickCount, 0)
    }

    // MARK: - stop

    func test_stop_calledTwice_doesNotCrash() {
        // Arrange
        let vm = makeViewModel()

        // Act
        vm.stop()

        // Assert
        XCTAssertNoThrow(vm.stop())
    }

    func test_stop_cancelsPendingFlipBackTimer() {
        // Arrange — non-matching pair schedules a flip-back. Then stop before it fires.
        let deck = makeOrderedDeck(pairCount: 3)
        let vm = makeViewModel(level: .easy, deck: deck)
        var flipDownsAfterStop = 0
        vm.onFlipCard = { _, _ in } // absorb initial flip-up callbacks
        vm.cardTapped(at: 0)
        vm.cardTapped(at: 2)
        vm.onFlipCard = { _, faceUp in if !faceUp { flipDownsAfterStop += 1 } }

        // Act
        vm.stop()
        let waiter = expectation(description: "main queue drain")
        DispatchQueue.main.async { waiter.fulfill() }
        waitForExpectations(timeout: 1)

        // Assert — without cancellation, two face-down callbacks would have fired
        XCTAssertEqual(flipDownsAfterStop, 0)
    }

    // MARK: - canSelectCard

    func test_canSelectCard_returnsTrueForFreshCard() {
        // Arrange
        let vm = makeViewModel()

        // Act
        let canSelect = vm.canSelectCard(at: 0)

        // Assert
        XCTAssertTrue(canSelect)
    }

    func test_canSelectCard_returnsFalseAfterCardIsMatched() {
        // Arrange — match indices 0 and 1 of an ordered (AABBCC) deck
        let deck = makeOrderedDeck(pairCount: 3)
        let vm = makeViewModel(level: .easy, deck: deck)
        vm.cardTapped(at: 0)
        vm.cardTapped(at: 1)

        // Act
        let canSelect = vm.canSelectCard(at: 0)

        // Assert
        XCTAssertFalse(canSelect)
    }

    // MARK: - configureCell

    func test_configureCell_doesNotCrash() {
        // Arrange
        let vm = makeViewModel()
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))

        // Act + Assert
        XCTAssertNoThrow(vm.configureCell(cell, at: 0))
    }

    // MARK: - cardTapped — invalid input

    func test_cardTapped_outOfBounds_doesNotFireOnFlipCard() {
        // Arrange
        let vm = makeViewModel()
        var fired = false
        vm.onFlipCard = { _, _ in fired = true }

        // Act
        vm.cardTapped(at: 999)

        // Assert
        XCTAssertFalse(fired)
    }

    func test_cardTapped_outOfBounds_doesNotFireOnModelChanged() {
        // Arrange
        let vm = makeViewModel()
        var fired = false
        vm.onModelChanged = { _ in fired = true }

        // Act
        vm.cardTapped(at: 999)

        // Assert
        XCTAssertFalse(fired)
    }

    func test_cardTapped_alreadyFlipped_doesNotFlipAgain() {
        // Arrange — tap once to flip, then again on the same index
        let vm = makeViewModel()
        vm.cardTapped(at: 0)
        var flipCalls = 0
        vm.onFlipCard = { _, _ in flipCalls += 1 }

        // Act
        vm.cardTapped(at: 0)

        // Assert
        XCTAssertEqual(flipCalls, 0)
    }

    // MARK: - cardTapped — first card of a turn

    func test_cardTapped_firstCard_firesOnFlipCardFaceUp() {
        // Arrange
        let vm = makeViewModel()
        var receivedFaceUp: Bool?
        vm.onFlipCard = { _, faceUp in receivedFaceUp = faceUp }

        // Act
        vm.cardTapped(at: 0)

        // Assert
        XCTAssertEqual(receivedFaceUp, true)
    }

    func test_cardTapped_firstCard_emitsModelWithIncrementedClickCount() {
        // Arrange
        let vm = makeViewModel()
        var receivedModel: GameModel?
        vm.onModelChanged = { receivedModel = $0 }

        // Act
        vm.cardTapped(at: 0)

        // Assert
        XCTAssertEqual(receivedModel?.clickCount, 1)
    }

    // MARK: - cardTapped — intermediate match

    func test_cardTapped_intermediateMatch_emitsIncrementedMatchCount() {
        // Arrange — pair 0 sits at deck indices (0, 1) in an AABBCC deck
        let deck = makeOrderedDeck(pairCount: 3)
        let vm = makeViewModel(level: .easy, deck: deck)
        var lastModel: GameModel?
        vm.onModelChanged = { lastModel = $0 }
        vm.cardTapped(at: 0)

        // Act
        vm.cardTapped(at: 1)

        // Assert
        XCTAssertEqual(lastModel?.matches, 1)
    }

    func test_cardTapped_intermediateMatch_doesNotTriggerNavigation() {
        // Arrange
        let deck = makeOrderedDeck(pairCount: 3)
        let vm = makeViewModel(level: .easy, deck: deck)
        var navigated = false
        vm.onNavigateToGameOver = { _ in navigated = true }
        vm.cardTapped(at: 0)

        // Act
        vm.cardTapped(at: 1)
        let waiter = expectation(description: "main queue drain")
        DispatchQueue.main.async { waiter.fulfill() }
        waitForExpectations(timeout: 1)

        // Assert — pairs remain after a single match in a 3-pair deck
        XCTAssertFalse(navigated)
    }

    // MARK: - cardTapped — non-matching pair triggers flip-back

    func test_cardTapped_nonMatch_schedulesTwoFlipDownsAfterDelay() {
        // Arrange — index 0 (pair 0) and index 2 (pair 1) do not match
        let deck = makeOrderedDeck(pairCount: 3)
        let vm = makeViewModel(level: .easy, deck: deck)
        var flipDownCalls = 0
        vm.onFlipCard = { _, faceUp in if !faceUp { flipDownCalls += 1 } }
        vm.cardTapped(at: 0)

        // Act
        vm.cardTapped(at: 2)
        let waiter = expectation(description: "flip-back delay drained")
        DispatchQueue.main.async { waiter.fulfill() }
        waitForExpectations(timeout: 1)

        // Assert — both cards flip back face-down
        XCTAssertEqual(flipDownCalls, 2)
    }

    // MARK: - cardTapped — final match → game over

    func test_cardTapped_lastMatch_firesOnNavigateToGameOver() {
        // Arrange — match all three pairs in an AABBCC easy deck
        let vm = makeViewModel(level: .easy, deck: makeOrderedDeck(pairCount: 3))
        let exp = expectation(description: "navigateToGameOver fired")
        vm.onNavigateToGameOver = { _ in exp.fulfill() }

        // Act
        playMatchingPairs(in: vm, pairCount: 3)

        // Assert — ImmediateClock fires on the next main-queue cycle
        waitForExpectations(timeout: 1)
    }

    func test_cardTapped_lastMatch_navigateOutcomeCarriesCorrectClickCount() {
        // Arrange
        let vm = makeViewModel(level: .easy, deck: makeOrderedDeck(pairCount: 3))
        let exp = expectation(description: "navigateToGameOver fired")
        var receivedOutcome: GameOutcome?
        vm.onNavigateToGameOver = {
            receivedOutcome = $0
            exp.fulfill()
        }

        // Act
        playMatchingPairs(in: vm, pairCount: 3)

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedOutcome?.clickCount, 6)
    }

    func test_cardTapped_lastMatch_navigateOutcomeCarriesLevel() {
        // Arrange
        let vm = makeViewModel(level: .easy, deck: makeOrderedDeck(pairCount: 3))
        let exp = expectation(description: "navigateToGameOver fired")
        var receivedOutcome: GameOutcome?
        vm.onNavigateToGameOver = {
            receivedOutcome = $0
            exp.fulfill()
        }

        // Act
        playMatchingPairs(in: vm, pairCount: 3)

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedOutcome?.level, .easy)
    }

    // MARK: - Pairing helper

    /// Taps each `(2i, 2i+1)` pair in turn — assumes the deck is in canonical AABBCC order.
    private func playMatchingPairs(
        in viewModel: GameViewModel,
        pairCount: Int
    ) {
        for pairIndex in 0 ..< pairCount {
            viewModel.cardTapped(at: pairIndex * 2)
            viewModel.cardTapped(at: pairIndex * 2 + 1)
        }
    }
}
