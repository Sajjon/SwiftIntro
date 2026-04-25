//
//  GameOutcome.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

/// The result of a completed game session, passed to the game-over screen.
struct GameOutcome {
    /// The configuration that produced this session — threaded through to the restart flow
    /// so the next game starts with the same difficulty and search query, without reconstruction.
    let config: GameConfiguration

    /// Total number of card taps the player made during the session.
    let clickCount: Int

    /// The deck used during the session, available so the player can restart with the same images.
    var cards: CardDuplicates

    /// The difficulty level that was played — derived from `config`.
    var level: Level {
        config.level
    }
}

// MARK: CustomStringConvertible

extension GameOutcome: CustomStringConvertible {
    var description: String {
        "\(level) - \(clickCount) taps"
    }
}
