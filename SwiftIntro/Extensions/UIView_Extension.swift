//
//  UIView_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 02/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

extension UIView {
    var isVisible: Bool {
        set {
            self.isHidden = !newValue
        }

        get {
            return !self.isHidden
        }
    }
}
