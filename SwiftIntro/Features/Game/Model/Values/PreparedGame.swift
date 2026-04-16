//
//  PreparedGame.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

/// A ready-to-play game: the player's chosen configuration paired with a
/// fully-fetched, shuffled card deck. Produced by `LoadingViewModel` and
/// consumed by `GameVC`.
struct PreparedGame {
    let config: GameConfiguration
    let cards: CardDuplicates
}
