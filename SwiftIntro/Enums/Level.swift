//
//  Level.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 19/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

enum Level {
    case Easy, Normal, Hard

    var nbrOfCards: Int {
        return self.rowCount*self.columnCount
    }

    var title: String {
        let localizedKey: String
        switch self {
        case .Easy:
            localizedKey = "Easy"
        case .Normal:
            localizedKey = "Normal"
        case .Hard:
            localizedKey = "Hard"
        }
        let title = localizedString(localizedKey)
        return title
    }

    init(segmentedControlIndex: Int) {
        switch segmentedControlIndex {
        case 0:
            self = .Easy
        case 1:
            self = .Normal
        case 2:
            self = .Hard
        default:
            fatalError("Should not be possible")
        }
    }

    var segmentedControlIndex: Int {
        let index: Int
        switch self {
        case .Easy:
            index = 0
        case .Normal:
            index = 1
        case .Hard:
            index = 2
        }
        return index
    }

    var columnCount: Int {
        switch self {
        case .Easy:
            return 2
        case .Normal:
            return 3
        case .Hard:
            return 4
        }
    }

    var rowCount: Int {
        switch self {
        case .Easy:
            return 3
        case .Normal:
            return 4
        case .Hard:
            return 5
        }
    }
}
