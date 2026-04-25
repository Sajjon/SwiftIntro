//
//  CardSingles.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 2026-04-14.
//  Copyright © 2026 SwiftIntro. All rights reserved.
//

/// An unordered collection of unique cards fetched from the API.
///
/// Each element appears exactly once — no pairs yet.
/// Use `CardDuplicates` when you need the shuffled, duplicated deck used during play.
struct CardSingles: Hashable {
    /// The unique cards returned by the API, one per image URL.
    let cards: [Card]
}

extension CardSingles {
    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        Set(lhs.cards) == Set(rhs.cards)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(Set(cards))
    }
}
