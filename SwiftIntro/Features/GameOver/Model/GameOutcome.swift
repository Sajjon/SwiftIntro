//
//  GameOutcome.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

/// The result of a completed game session, passed to the game-over screen.
///
/// Generic over the compile-time card count `N` so the restart path can reuse the
/// same deck type without re-validating its size.
struct GameOutcome<let N: Int> {
    /// The difficulty level that was played.
    let level: Level

    /// Total number of card taps the player made during the session.
    let clickCount: Int

    /// The deck used during the session, available so the player can restart with the same images.
    var cards: CardDuplicates<N>
}

// MARK: CustomStringConvertible

extension GameOutcome: CustomStringConvertible {
    var description: String {
        "\(level) - \(clickCount) taps"
    }
}

// MARK: - AnyGameOutcome

/// Runtime-dispatched wrapper over a `GameOutcome<N>` whose `N` is one of the three
/// `Level` sizes. Used at boundaries (navigation, non-generic VCs) where the
/// compile-time `N` is not in scope.
enum AnyGameOutcome {
    case easy(GameOutcome<6>)
    case normal(GameOutcome<12>)
    case hard(GameOutcome<20>)

    var level: Level {
        switch self {
        case let .easy(o): o.level
        case let .normal(o): o.level
        case let .hard(o): o.level
        }
    }

    var clickCount: Int {
        switch self {
        case let .easy(o): o.clickCount
        case let .normal(o): o.clickCount
        case let .hard(o): o.clickCount
        }
    }
}

extension AnyGameOutcome: CustomStringConvertible {
    var description: String {
        "\(level) - \(clickCount) taps"
    }
}
