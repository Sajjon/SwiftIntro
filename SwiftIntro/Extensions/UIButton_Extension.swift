//
//  UIButton_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 18/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

extension UIButton {

    func setLocalizedTitle(_ key: L10n) {
        let title = tr(key: key)
        setTitle(title)
    }

    func setTitle(_ title: String) {
        setTitle(title, for: UIControlState())
        setTitle(title, for: .highlighted)
    }
}
