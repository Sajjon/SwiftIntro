//
//  CellProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

/// A collection view cell that can supply its own reuse identifier.
///
/// A default implementation derives the identifier from the type name via
/// `String(describing:)`, so conforming cells do not have to declare one
/// explicitly. The identifier has no module prefix and no force-unwraps.
protocol CellProtocol {
    /// The string used to register and dequeue this cell type.
    static var cellIdentifier: String { get }
}

extension CellProtocol {
    static var cellIdentifier: String {
        String(describing: Self.self)
    }
}
