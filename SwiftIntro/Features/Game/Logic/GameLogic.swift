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

        case .cardTapped(let index):
            log.debug("Card tapped at index \(index)")

            // Ignore taps beyond the card array bounds (defensive guard).
            guard index < model.cards.count else { return .noChange }
            let card = model.cards[index]

            // Ignore taps on cards that are already face-up or matched.
            guard !card.isFlipped, !card.isMatched else { return .noChange }

            var newModel = model
            newModel.clickCount += 1
            newModel.cards[index].isFlipped = true

            if let pendingIndex = model.pendingCardIndex {
                // A first card was already waiting — evaluate the pair.
                newModel.pendingCardIndex = nil
                let pendingCard = model.cards[pendingIndex]

                if card.imageUrl == pendingCard.imageUrl {
                    // ── Match ──────────────────────────────────────────────────────
                    newModel.cards[index].isMatched = true
                    newModel.cards[pendingIndex].isMatched = true
                    newModel.matches += 1

                    if newModel.matches == newModel.totalPairs {
                        // All pairs found — reconstruct the deck from the model's image
                        // URLs so the game-over screen can offer a restart with the
                        // same images in a freshly shuffled order.
                        let cards = model.cards.map(\.imageUrl).map(Card.init)
                        let outcome = GameOutcome(
                            level: model.level,
                            clickCount: newModel.clickCount,
                            cards: CardDuplicates(memoryCards: cards)
                        )
                        return .next(newModel, effects: [
                            .flipCard(index: index, faceUp: true),
                            .navigateToGameOver(outcome: outcome)
                        ])
                    } else {
                        return .next(newModel, effects: [
                            .flipCard(index: index, faceUp: true)
                        ])
                    }
                } else {
                    // ── No match — schedule a delayed flip-back ───────────────────
                    return .next(newModel, effects: [
                        .flipCard(index: index, faceUp: true),
                        .scheduleFlipBack(index1: pendingIndex, index2: index)
                    ])
                }
            } else {
                // First card of a new turn — store it as pending.
                newModel.pendingCardIndex = index
                return .next(newModel, effects: [.flipCard(index: index, faceUp: true)])
            }

        case .flipBackCards(let index1, let index2):
            // Dispatched by the effect handler after the 1-second delay expires.
            var newModel = model
            newModel.cards[index1].isFlipped = false
            newModel.cards[index2].isFlipped = false
            return .next(newModel, effects: [
                .flipCard(index: index1, faceUp: false),
                .flipCard(index: index2, faceUp: false)
            ])
        }
    }
}
