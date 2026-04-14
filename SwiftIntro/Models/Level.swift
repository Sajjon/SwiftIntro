//
//  Level.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 19/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

/// The difficulty level of a game session, controlling board dimensions.
enum Level {
	/// 2 × 3 grid — 6 cards, 3 pairs.
	case easy
	/// 3 × 4 grid — 12 cards, 6 pairs.
	case normal
	/// 4 × 5 grid — 20 cards, 10 pairs.
	case hard
}

// MARK: Init
extension Level {

	/// Creates a `Level` from a `UISegmentedControl` segment index.
	///
	/// Segment order: 0 = easy, 1 = normal, 2 = hard.
	init(segmentedControlIndex: Int) {
		switch segmentedControlIndex {
		case 0:  self = .easy
		case 1:  self = .normal
		case 2:  self = .hard
		default: fatalError("Should not be possible")
		}
	}
}

// MARK: Computed properties
extension Level {
    /// Total number of cards on the board (columns × rows).
    var cardCount: Int {
        return self.rowCount * self.columnCount
    }

    /// The localized display title shown in the segmented control.
    var title: String {
        switch self {
        case .easy:   return L10n.easy
        case .normal: return L10n.normal
        case .hard:   return L10n.hard
        }
    }

    /// The segment index that corresponds to this level in a `UISegmentedControl`.
    var segmentedControlIndex: Int {
        switch self {
        case .easy:   return 0
        case .normal: return 1
        case .hard:   return 2
        }
    }

    /// Number of card columns on the board.
    var columnCount: Int {
        switch self {
        case .easy:   return 2
        case .normal: return 3
        case .hard:   return 4
        }
    }

    /// Number of card rows on the board.
    var rowCount: Int {
        switch self {
        case .easy:   return 3
        case .normal: return 4
        case .hard:   return 5
        }
    }
}
