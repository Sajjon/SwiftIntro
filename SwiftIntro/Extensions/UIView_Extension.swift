//
//  UIView_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 02/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

extension UIView {
    var visible: Bool {
        set {
            self.hidden = !newValue
        }

        get {
            return !self.hidden
        }
    }
}