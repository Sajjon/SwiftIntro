//
//  NSObject_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

extension NSObject {

    /// The unqualified class name, derived by stripping the module prefix from `NSStringFromClass`.
    ///
    /// For example, `SwiftIntro.CardCVCell` becomes `"CardCVCell"`.
    /// Used as a stable reuse identifier for collection view cells via `CellProtocol`.
    final class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
