//
//  UIView_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 02/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

extension UIView {

    /// A convenience inverse of `isHidden`.
    ///
    /// Setting `isVisible = true` is equivalent to `isHidden = false`, and vice versa.
    /// Prefer this over negated `isHidden` assignments to keep call sites readable.
    var isVisible: Bool {
        set { self.isHidden = !newValue }
        get { return !self.isHidden }
    }
}
