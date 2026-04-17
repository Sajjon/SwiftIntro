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
///
/// Generic over the compile-time card count `N` (always even). Cards are stored inline.
struct GameModel<let N: Int> {
    /// All cards on the board in row-major order (row 0 first, then row 1, etc.).
    var cards: InlineArray<N, CardModel>

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
        N / 2
    }

    /// Total number of cards on the board — equal to the compile-time parameter `N`.
    var cardCount: Int {
        N
    }

    init(
        cards: InlineArray<N, CardModel>,
        level: Level
    ) {
        // `level.cardCount == N` is the intended invariant at runtime, but is left
        // unchecked here so tests can build degenerate fixtures (e.g. a 2-card
        // "one pair" model tagged `.hard`) without every test having to spell out
        // a valid full-size board.
        self.cards = cards
        self.level = level
        clickCount = 0
        matches = 0
        pendingCardIndex = nil
    }
}

extension GameModel {
    /// Convenience: initialize from a runtime `[CardModel]`, preconditioning `count == N`.
    /// Used by tests that produce cards via `map` on a runtime range.
    init(
        cards: [CardModel],
        level: Level
    ) {
        precondition(cards.count == N, "Expected \(N) cards, got \(cards.count)")
        let inline = InlineArray<N, CardModel> { i in cards[i] }
        self.init(cards: inline, level: level)
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
