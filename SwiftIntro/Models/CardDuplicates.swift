//
//  Cards.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

/// The full deck of cards used during a game session — every card appears exactly twice.
///
/// Created by taking `CardSingles`, choosing enough unique cards to fill the board,
/// duplicating each one, and shuffling the result.
struct CardDuplicates {

    /// The shuffled, duplicated array of cards. Count is always even.
    var memoryCards: [Card]

    /// Creates a deck directly from a pre-built array of (already duplicated) cards.
    init(memoryCards: [Card]) {
        self.memoryCards = memoryCards
    }

    /// Creates a deck from unique cards, duplicating and shuffling to fill the board
    /// defined by `config.level`.
    init(singles: CardSingles, config: GameConfiguration) {
        self.init(memoryCards: makeMemoryCards(
            from: singles,
            cardCount: config.level.cardCount
        ))
    }
}

extension CardDuplicates {

    /// Total number of cards in the deck (always even).
    var count: Int { memoryCards.count }

    /// Accesses a card by its flat (row-major) index in the deck.
    subscript(index: Int) -> Card {
        memoryCards[index]
    }

    /// Shuffles the deck in-place. Used when restarting a game with the same images.
    mutating func shuffle() {
        memoryCards.shuffle()
    }
}

/// Builds a shuffled, paired deck from a set of unique cards.
///
/// - Parameters:
///   - singles: The pool of unique cards to draw from.
///   - cardCount: Total cards the board requires (must be even; half this many unique images are used).
/// - Returns: A shuffled array where each chosen image appears exactly twice.
private func makeMemoryCards(
    from singles: CardSingles,
    cardCount: Int
) -> [Card] {
    let singles = singles.cards
    // Pick half as many unique images as the board needs total slots.
    // `choose` already caps at the pool size if the pool is smaller.
    let chosen = singles.choose(cardCount / 2)
    var duplicated: [Card] = []
    for card in chosen {
        // Each image appears exactly twice — once for each half of the matching pair.
        duplicated.append(contentsOf: [card, card])
    }
    duplicated.shuffle()
    return duplicated
}
