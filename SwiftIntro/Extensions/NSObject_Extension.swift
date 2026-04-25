//
//  NSObject_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

extension NSObject {
    /// The unqualified class name, without the module prefix.
    ///
    /// For example, `SwiftIntro.CardCVCell` becomes `"CardCVCell"`.
    static var className: String {
        String(describing: self)
    }
}
