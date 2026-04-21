//
//  Card.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

/// A unique card in the memory game, identified solely by the image shown on its face.
///
/// Two `Card` values with the same `imageUrl` are considered a matching pair.
struct Card: Equatable, Hashable {
    /// The remote URL of the image displayed when this card is face-up.
    let imageUrl: URL
}
