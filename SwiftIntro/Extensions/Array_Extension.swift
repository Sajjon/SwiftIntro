//
//  Array_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 18/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

extension Array {
    var shuffled: Array {
        var elements = self
        for index in indices.dropLast() {
            guard
                case let swapIndex = Int(arc4random_uniform(UInt32(count - index))) + index,
                swapIndex != index
                else { continue }
			elements.swapAt(index, swapIndex)
        }
        return elements
    }
    mutating func shuffle() {
        self = shuffled
    }

    var chooseOne: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    func choose(_ count: Int) -> [Element] {
        return Array(shuffled.prefix(count))
    }
}
