//
//  CardDuplicates.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

/// The full deck of cards used during a game session — every card appears exactly twice,
/// and the order is always freshly shuffled.
///
/// Construction is constrained: there is no way to build a `CardDuplicates` whose
/// contents are not properly paired. The single private designated initializer asserts
/// the invariant; both public inits route through it after performing a shuffle.
struct CardDuplicates {
    /// The shuffled, paired array of cards. Count is always even and non-zero.
    let memoryCards: [Card]

    /// Designated initializer — asserts the pair invariant.
    ///
    /// Callers must have already shuffled `cards`; this is enforced by making the
    /// initializer `private` so every construction path funnels through a public
    /// init that shuffles first.
    private init(validated cards: [Card]) {
        precondition(!cards.isEmpty, "Deck must not be empty")
        precondition(cards.count.isMultiple(of: 2), "Deck must contain an even number of cards")
        var frequency: [URL: Int] = [:]
        for card in cards {
            frequency[card.imageUrl, default: 0] += 1
        }
        precondition(
            frequency.values.allSatisfy { $0 == 2 },
            "Every card must appear exactly twice"
        )
        memoryCards = cards
    }

    /// Creates a deck from unique cards, duplicating and shuffling to fill the board
    /// defined by `config.level`.
    ///
    /// Preconditions that `singles.cards.count >= config.level.cardCount / 2`; otherwise
    /// the deck would be shorter than the grid derived from `Level`, risking out-of-bounds
    /// access during cell configuration.
    init(
        singles: CardSingles,
        config: GameConfiguration
    ) {
        let requiredPairs = config.level.cardCount / 2
        let chosen = singles.cards.choose(requiredPairs)
        precondition(
            chosen.count == requiredPairs,
            "Not enough unique cards for level \(config.level): need \(requiredPairs) uniques, got \(chosen.count)"
        )
        // Each image appears exactly twice — once per matching pair.
        var shuffled = chosen.flatMap { [$0, $0] }
        shuffled.shuffle()
        self.init(validated: shuffled)
    }

    /// Rebuilds a deck from already-paired cards and re-shuffles them.
    ///
    /// Used on game-over → restart, so the player sees a fresh layout of the same images.
    init(reshuffling cards: [Card]) {
        var shuffled = cards
        shuffled.shuffle()
        self.init(validated: shuffled)
    }
}

extension CardDuplicates {
    /// Total number of cards in the deck (always even and non-zero).
    var count: Int {
        memoryCards.count
    }
}
