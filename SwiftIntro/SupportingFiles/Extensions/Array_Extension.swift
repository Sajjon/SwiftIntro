//
//  Array_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 18/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

extension Array {
    /// A new array with the same elements in a random order (Fisher-Yates shuffle).
    var shuffled: Array {
        var elements = self
        // Iterate every index except the last — the last element is already in its
        // final position once all preceding swaps are done.
        for index in indices.dropLast() {
            // Pick a random index in the range [index, count) and swap it with `index`.
            // `arc4random_uniform` avoids modulo bias that `% count` would introduce.
            guard
                case let swapIndex = Int.random(in: index ..< count),
                swapIndex != index
            else { continue }
            elements.swapAt(index, swapIndex)
        }
        return elements
    }

    /// Shuffles the array in-place using the Fisher-Yates algorithm.
    mutating func shuffle() {
        self = shuffled
    }

    /// A single randomly chosen element. Crashes if the array is empty.
    var chooseOne: Element {
        self[Int.random(in: 0 ..< count)]
    }

    /// Returns `count` randomly chosen elements, without replacement.
    ///
    /// If `count` exceeds the array length, the entire array is returned shuffled.
    func choose(_ count: Int) -> [Element] {
        Array(shuffled.prefix(count))
    }
}
