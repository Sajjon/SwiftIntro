//
//  GameLogic.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import MobiusCore

/// Pure update function — the single source of truth for game-state evolution.
///
/// `GameLogic` is a namespace (caseless enum) for the Mobius `update` function.
/// It is stateless and side-effect-free, making it straightforward to unit-test
/// without mocking any UIKit or networking infrastructure.
enum GameLogic {
    /// Produces the next `GameModel` and any `GameEffect`s in response to a `GameEvent`.
    ///
    /// Called by the Mobius loop on its internal queue — never on the main thread.
    ///
    /// - Parameters:
    ///   - model: The current game state.
    ///   - event: The input that triggered this update.
    /// - Returns: A `Next` value containing the updated model and/or effects to run.
    static func update(
        model: GameModel,
        event: GameEvent
    ) -> Next<GameModel, GameEffect> {
        switch event {
        case let .cardTapped(index):
            handleCardTapped(index: index, model: model)
        case let .flipBackCards(index1, index2):
            handleFlipBack(index1: index1, index2: index2, model: model)
        }
    }
}

// MARK: - Private helpers

private extension GameLogic {
    /// Validates the tap, then delegates to `applyFlip`.
    static func handleCardTapped(
        index: Int,
        model: GameModel
    ) -> Next<GameModel, GameEffect> {
        logGame.debug("Card tapped at index \(index)")
        guard index < model.cards.count else {
            logGame.debug("Tap ignored — index \(index) is out of bounds (card count: \(model.cards.count))")
            return .noChange
        }
        guard !model.cards[index].isFlipped, !model.cards[index].isMatched else {
            logGame.debug("Tap ignored — card at index \(index) is already flipped or matched")
            return .noChange
        }
        return applyFlip(index: index, model: model)
    }

    /// Increments click count, flips the card, then routes to pair evaluation or stores it as pending.
    static func applyFlip(
        index: Int,
        model: GameModel
    ) -> Next<GameModel, GameEffect> {
        var newModel = model
        newModel.clickCount += 1
        newModel.cards[index].isFlipped = true
        guard let pendingIndex = model.pendingCardIndex else {
            logGame.debug("First card flipped at index \(index) — waiting for second 🃏 (click #\(newModel.clickCount))")
            newModel.pendingCardIndex = index
            return .next(newModel, effects: [.flipCard(index: index, faceUp: true)])
        }
        logGame
            .debug("Second card of pair flipped at index \(index) — evaluating against pending index \(pendingIndex)")
        newModel.pendingCardIndex = nil
        return evaluatePair(index: index, pendingIndex: pendingIndex, newModel: newModel)
    }

    /// Compares the two face-up cards and returns either a match or a flip-back effect.
    static func evaluatePair(
        index: Int,
        pendingIndex: Int,
        newModel: GameModel
    ) -> Next<GameModel, GameEffect> {
        let isMatchingPair = newModel.isCard(at: index, matchingCardAt: pendingIndex)
        if isMatchingPair {
            logGame.debug("Pair match! Indices \(pendingIndex) and \(index) are the same card")
            return handleMatch(index: index, pendingIndex: pendingIndex, newModel: newModel)
        }
        logGame.debug("No match — scheduling flip-back for indices \(pendingIndex) and \(index)")
        return .next(newModel, effects: [
            .flipCard(index: index, faceUp: true),
            .scheduleFlipBack(index1: pendingIndex, index2: index),
        ])
    }

    /// Marks both cards matched; triggers game-over if all pairs are found.
    static func handleMatch(
        index: Int,
        pendingIndex: Int,
        newModel: GameModel
    ) -> Next<GameModel, GameEffect> {
        var newModel = newModel
        newModel.cards[index].isMatched = true
        newModel.cards[pendingIndex].isMatched = true
        newModel.matches += 1
        logGame
            .info(
                "Match confirmed — \(newModel.matches)/\(newModel.totalPairs) pairs found (click #\(newModel.clickCount))"
            )
        guard newModel.matches == newModel.totalPairs else {
            return .next(newModel, effects: [.flipCard(index: index, faceUp: true)])
        }
        return gameOverNext(index: index, newModel: newModel)
    }

    /// Builds the game-over `Next` value, reconstructing the deck for a potential restart.
    static func gameOverNext(
        index: Int,
        newModel: GameModel
    ) -> Next<GameModel, GameEffect> {
        logGame
            .notice(
                "Game over — all \(newModel.totalPairs) pairs matched in \(newModel.clickCount) clicks (level: \(newModel.level))"
            )
        // Reconstruct the deck from image URLs so the game-over screen can restart
        // with the same images in a freshly shuffled order.
        let cards = newModel.cards.map(\.card)
        let outcome = GameOutcome(
            level: newModel.level,
            clickCount: newModel.clickCount,
            cards: CardDuplicates(memoryCards: cards)
        )
        return .next(newModel, effects: [.flipCard(index: index, faceUp: true), .navigateToGameOver(outcome: outcome)])
    }

    /// Flips both cards face-down after the delayed timer fires.
    static func handleFlipBack(
        index1: Int,
        index2: Int,
        model: GameModel
    ) -> Next<GameModel, GameEffect> {
        logGame.debug("Flip-back timer fired — returning cards \(index1) and \(index2) face-down")
        var newModel = model
        newModel.cards[index1].isFlipped = false
        newModel.cards[index2].isFlipped = false
        return .next(newModel, effects: [
            .flipCard(index: index1, faceUp: false),
            .flipCard(index: index2, faceUp: false),
        ])
    }
}
