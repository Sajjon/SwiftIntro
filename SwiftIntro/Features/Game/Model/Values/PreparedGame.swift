//
//  PreparedGame.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

/// A ready-to-play game: the player's chosen configuration paired with a
/// fully-fetched, shuffled card deck. Produced by `LoadingViewModel` and
/// consumed by `GameVC<N>`.
///
/// Generic over the compile-time card count `N` so the `cards` deck size is
/// known statically once the runtime `Level` has been dispatched on.
struct PreparedGame<let N: Int> {
    let config: GameConfiguration
    let cards: CardDuplicates<N>
}

// MARK: - AnyPreparedGame

/// Runtime-dispatched wrapper over a `PreparedGame<N>` whose `N` is one of the three
/// `Level` sizes. `LoadingViewModel` produces one of these and `RootVC` switches on
/// the case to construct the matching `GameVC<N>`.
enum AnyPreparedGame {
    case easy(PreparedGame<6>)
    case normal(PreparedGame<12>)
    case hard(PreparedGame<20>)

    var config: GameConfiguration {
        switch self {
        case let .easy(g): g.config
        case let .normal(g): g.config
        case let .hard(g): g.config
        }
    }

    var cardCount: Int {
        switch self {
        case let .easy(g): g.cards.count
        case let .normal(g): g.cards.count
        case let .hard(g): g.cards.count
        }
    }
}
