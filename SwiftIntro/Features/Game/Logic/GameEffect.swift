//
//  GameEffect.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  Note: this file is excluded from SwiftFormat (see `.swiftformat`) because
//  SwiftFormat 0.61 cannot correctly parse a `<let N: Int>`-generic enum body —
//  it loses track of scope and either crashes with "Unexpected token }" or
//  strips comments and mangles indentation. Keep the formatting by hand.
//

/// Side effects produced by the Mobius `update` function that require real-world work.
///
/// Effects are handled by `GameEffectHandler`, which executes animations, timers,
/// and navigation. They are intentionally kept separate from state so that
/// `GameLogic.update` remains a pure function that is easy to unit-test.
///
/// Generic over the compile-time card count `N` so that `.navigateToGameOver` can carry
/// a correctly-sized `GameOutcome<N>`.
enum GameEffect<let N: Int> {
    /// Animate a card at `index` to the given face-up or face-down state.
    case flipCard(index: Int, faceUp: Bool)

    /// Schedule a 1-second delay, then dispatch `flipBackCards` to flip both
    /// non-matching cards back to face-down.
    case scheduleFlipBack(index1: Int, index2: Int)

    /// Navigate to the game-over screen after a short delay, carrying the result.
    case navigateToGameOver(outcome: GameOutcome<N>)
}

// MARK: - CustomStringConvertible

extension GameEffect: CustomStringConvertible {
    var description: String {
        switch self {
        case let .flipCard(index, faceUp):
            "flipCard(index: \(index), faceUp: \(faceUp))"
        case let .scheduleFlipBack(index1, index2):
            "scheduleFlipBack(index1: \(index1), index2: \(index2))"
        case let .navigateToGameOver(outcome):
            "navigateToGameOver(outcome: \(String(describing: outcome)))"
        }
    }
}
