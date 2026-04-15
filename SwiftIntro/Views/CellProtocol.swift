//
//  CellProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// A collection view cell that can supply its own reuse identifier.
///
/// Conforming types (e.g. `CardCVCell`) derive `cellIdentifier` from `NSObject.className`,
/// keeping the identifier and the `register(_:forCellWithReuseIdentifier:)` call in sync
/// automatically.
@MainActor
protocol CellProtocol {
    /// The string used to register and dequeue this cell type.
    static var cellIdentifier: String { get }
}
