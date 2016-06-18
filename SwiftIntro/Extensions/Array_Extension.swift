//
//  Array_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 18/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

extension Array {
    var shuffled: Array {
        var elements = self
        for index in indices.dropLast() {
            guard
                case let swapIndex = Int(arc4random_uniform(UInt32(count - index))) + index
                where swapIndex != index else { continue }
            swap(&elements[index], &elements[swapIndex])
        }
        return elements
    }
    mutating func shuffle() {
        self = shuffled
    }

    var chooseOne: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    func choose(count: Int) -> [Element] {
        return Array(shuffled.prefix(count))
    }
}
