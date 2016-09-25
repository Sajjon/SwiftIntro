//
//  Level.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 19/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

enum Level {
    case easy, normal, hard

    var cardCount: Int {
        return self.rowCount*self.columnCount
    }

    var title: String {
        let localizedKey: String
        switch self {
        case .easy:
            localizedKey = "Easy"
        case .normal:
            localizedKey = "Normal"
        case .hard:
            localizedKey = "Hard"
        }
        let title = localizedString(localizedKey)
        return title
    }

    init(segmentedControlIndex: Int) {
        switch segmentedControlIndex {
        case 0:
            self = .easy
        case 1:
            self = .normal
        case 2:
            self = .hard
        default:
            fatalError("Should not be possible")
        }
    }

    var segmentedControlIndex: Int {
        let index: Int
        switch self {
        case .easy:
            index = 0
        case .normal:
            index = 1
        case .hard:
            index = 2
        }
        return index
    }

    var columnCount: Int {
        switch self {
        case .easy:
            return 2
        case .normal:
            return 3
        case .hard:
            return 4
        }
    }

    var rowCount: Int {
        switch self {
        case .easy:
            return 3
        case .normal:
            return 4
        case .hard:
            return 5
        }
    }
}
