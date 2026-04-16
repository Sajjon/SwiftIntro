//
//  GameModel.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 14/04/26.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

/// The complete snapshot of the game at any point in time.
///
/// This is the single source of truth in the Mobius loop. Every UI update is derived
/// exclusively from this value — no UI state is stored separately.
struct GameModel {
    /// All cards on the board in row-major order (row 0 first, then row 1, etc.).
    var cards: [CardModel]

    /// The difficulty level, used to derive grid dimensions and total pair count.
    let level: Level

    /// Running total of all card taps (including misses). Shown on the game-over screen.
    var clickCount: Int

    /// Number of pairs the player has matched so far.
    var matches: Int

    /// The flat index of the first card flipped in the current turn, if any.
    ///
    /// `nil` means no card is waiting for a second tap.
    /// When the player taps a second card, this index is compared to determine a match.
    var pendingCardIndex: Int?

    /// Total number of pairs on the board. Game ends when `matches == totalPairs`.
    var totalPairs: Int {
        cards.count / 2
    }

    init(
        cards: [CardModel],
        level: Level
    ) {
        self.cards = cards
        self.level = level
        clickCount = 0
        matches = 0
        pendingCardIndex = nil
    }
}

extension GameModel {
    func isCard(
        at index: Int,
        matchingCardAt otherCardIndex: Int
    ) -> Bool {
        cards[index].isMatchingPair(with: cards[otherCardIndex])
    }
}
