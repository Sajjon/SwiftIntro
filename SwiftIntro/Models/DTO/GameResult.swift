//
//  GameResult.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 20/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

struct GameResult {
    let level: Level
    let clickCount: Int
    var cards: Cards!

    init(level: Level, clickCount: Int) {
        self.level = level
        self.clickCount = clickCount
    }
}