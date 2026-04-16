//
//  CardModel.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 2026-04-16.
//  Copyright © 2026 SwiftIntro. All rights reserved.
//

import Foundation

/// The view-facing representation of a single card during a game session.
///
/// Wraps a `Card`'s image URL with mutable flip and match state driven by the Mobius loop.
struct CardModel {
    /// The card with the remote URL of the image shown on the card's face.
    let card: Card

    /// Whether this card is currently face-up (visible to the player).
    var isFlipped: Bool

    /// Whether this card has been successfully matched and is locked face-up.
    var isMatched: Bool

    init(card: Card) {
        self.card = card
        isFlipped = false
        isMatched = false
    }
}

extension CardModel {
    /// Checks if this card forms a matching pair with `other`
    /// - Parameter other: another card
    /// - Returns: If the pair is a match
    func isMatchingPair(with other: Self) -> Bool {
        card == other.card
    }
}
