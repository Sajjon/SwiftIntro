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
/// The compile-time value-generic parameter `N` is the total number of cards on the
/// board and must be even. Stored inline (no heap allocation) via `InlineArray`.
///
/// Construction is constrained: there is no way to build a `CardDuplicates` whose
/// contents are not properly paired. The single private designated initializer asserts
/// the invariant; every public init routes through it after performing a shuffle.
struct CardDuplicates<let N: Int> {
    /// The shuffled, paired cards stored inline. `N` is the total card count (always even).
    let memoryCards: InlineArray<N, Card>

    /// Designated initializer — asserts the pair invariant.
    ///
    /// Callers must have already shuffled `cards`; this is enforced by making the
    /// initializer `private` so every construction path funnels through a public
    /// init that shuffles first.
    private init(validated cards: InlineArray<N, Card>) {
        precondition(N > 0, "Deck must not be empty")
        precondition(N.isMultiple(of: 2), "Deck must contain an even number of cards")
        var frequency: [URL: Int] = [:]
        for i in cards.indices {
            frequency[cards[i].imageUrl, default: 0] += 1
        }
        precondition(
            frequency.values.allSatisfy { $0 == 2 },
            "Every card must appear exactly twice"
        )
        memoryCards = cards
    }

    // swiftlint:disable function_body_length

    /// Creates a deck from unique cards, duplicating and shuffling to fill the board.
    ///
    /// The caller must already know the compile-time `N`. `config.level.cardCount`
    /// must equal `N`, otherwise this traps — validating that the runtime-selected
    /// level matches the compile-time deck size is the caller's responsibility
    /// (done in `LoadingViewModel` by dispatching on `Level`).
    init(
        singles: CardSingles,
        config: GameConfiguration
    ) {
        precondition(
            config.level.cardCount == N,
            "Level \(config.level) needs \(config.level.cardCount) cards but N is \(N)"
        )
        let requiredPairs = N / 2
        let chosen = singles.cards.choose(requiredPairs)
        precondition(
            chosen.count == requiredPairs,
            "Not enough unique cards for level \(config.level): need \(requiredPairs) uniques, got \(chosen.count)"
        )
        // Each image appears exactly twice — once per matching pair.
        var paired = chosen.flatMap { [$0, $0] }
        paired.shuffle()
        var inline = InlineArray<N, Card> { i in paired[i] }
        Self.shuffleInline(&inline)
        self.init(validated: inline)
    }

    // swiftlint:enable function_body_length

    /// Rebuilds a deck from an `InlineArray` of already-paired cards and re-shuffles them.
    ///
    /// Used on game-over → restart, so the player sees a fresh layout of the same images.
    init(reshuffling cards: InlineArray<N, Card>) {
        var shuffled = cards
        Self.shuffleInline(&shuffled)
        self.init(validated: shuffled)
    }

    /// Runtime-sized convenience — accepts `[Card]`, preconditions `count == N`, then
    /// shuffles. Used by tests and by code paths that start from an `Array<Card>` and
    /// have already decided on the compile-time `N`.
    init(reshuffling cards: [Card]) {
        precondition(cards.count == N, "Expected \(N) cards, got \(cards.count)")
        let inline = InlineArray<N, Card> { i in cards[i] }
        self.init(reshuffling: inline)
    }

    /// Fisher-Yates shuffle on an `InlineArray`. Extracted as a helper because
    /// `InlineArray` does not conform to `MutableCollection` in Swift 6.2,
    /// so the standard-library `shuffle()` is unavailable.
    private static func shuffleInline(_ arr: inout InlineArray<N, Card>) {
        guard N > 1 else { return }
        for i in stride(from: N - 1, to: 0, by: -1) {
            let j = Int.random(in: 0 ... i)
            arr.swapAt(i, j)
        }
    }
}

extension CardDuplicates {
    /// Total number of cards in the deck — equal to the compile-time parameter `N`.
    var count: Int {
        N
    }

    /// Number of matching pairs — `N / 2`.
    var pairCount: Int {
        N / 2
    }

    /// Materialize the deck into a plain `[Card]` array. Used at boundaries
    /// where existing Array-based APIs (e.g. test helpers, filter/map) are needed.
    var asArray: [Card] {
        var out: [Card] = []
        out.reserveCapacity(N)
        for i in memoryCards.indices {
            out.append(memoryCards[i])
        }
        return out
    }
}

// MARK: - AnyCardDuplicates

/// Runtime-dispatched wrapper around a `CardDuplicates<N>` whose `N` is one of the
/// three `Level` sizes. Used at boundaries (navigation, view-model callbacks) where
/// the compile-time `N` is not yet known.
enum AnyCardDuplicates {
    case easy(CardDuplicates<6>)
    case normal(CardDuplicates<12>)
    case hard(CardDuplicates<20>)

    var level: Level {
        switch self {
        case .easy: .easy
        case .normal: .normal
        case .hard: .hard
        }
    }

    var count: Int {
        switch self {
        case let .easy(d): d.count
        case let .normal(d): d.count
        case let .hard(d): d.count
        }
    }
}
