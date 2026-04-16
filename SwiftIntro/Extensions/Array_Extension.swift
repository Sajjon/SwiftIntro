//
//  Array_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 18/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

extension Array {
    /// Returns `count` randomly chosen elements, without replacement.
    ///
    /// If `count` exceeds the array length, the entire array is returned shuffled.
    func choose(_ count: Int) -> [Element] {
        Array(shuffled().prefix(count))
    }
}
