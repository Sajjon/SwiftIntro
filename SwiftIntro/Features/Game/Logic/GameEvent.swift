//
//  GameEvent.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

/// All inputs that can change the game state.
///
/// Events flow into the Mobius loop's pure `update` function, which produces
/// a new `GameModel` and zero or more `GameEffect`s in response.
enum GameEvent {
    /// The player tapped a card at the given flat (row-major) index.
    case cardTapped(index: Int)
    /// The 1-second delay elapsed and two non-matching cards should flip back face-down.
    ///
    /// This event is dispatched by `GameEffectHandler` after `scheduleFlipBack` fires.
    case flipBackCards(index1: Int, index2: Int)
}
