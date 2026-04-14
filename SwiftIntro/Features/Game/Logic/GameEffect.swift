//
//  GameEffect.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

/// Side effects produced by the Mobius `update` function that require real-world work.
///
/// Effects are handled by `GameEffectHandler`, which executes animations, timers,
/// and navigation. They are intentionally kept separate from state so that
/// `GameLogic.update` remains a pure function that is easy to unit-test.
enum GameEffect {
    /// Animate a card at `index` to the given face-up or face-down state.
    case flipCard(index: Int, faceUp: Bool)

    /// Schedule a 1-second delay, then dispatch `flipBackCards` to flip both
    /// non-matching cards back to face-down.
    case scheduleFlipBack(index1: Int, index2: Int)

    /// Navigate to the game-over screen after a short delay, carrying the result.
    case navigateToGameOver(outcome: GameOutcome)
}
