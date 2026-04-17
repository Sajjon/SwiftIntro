//
//  GameConfiguration.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

/// Parameters chosen by the player on the GameSetup screen before a game starts.
struct GameConfiguration {
    /// The board difficulty that determines grid dimensions and total card count.
    var level: Level = .normal

    /// The Wikimedia Commons search term used to fetch card images.
    var searchQuery: String = "dogs"
}

extension GameConfiguration: CustomStringConvertible {
    var description: String {
        "query: '\(searchQuery)', level: \(level)"
    }
}
