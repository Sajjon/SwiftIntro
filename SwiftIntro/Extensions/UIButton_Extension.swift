//
//  UIButton_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 18/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

extension UIButton {
    /// Sets the button's title from a localized string for both `.normal` and `.highlighted` states.
    func setLocalizedTitle(_ text: String) {
        setTitle(text)
    }

    /// Sets the button's title string for both `.normal` and `.highlighted` states at once.
    ///
    /// Without setting the highlighted state explicitly, the button title can flash or
    /// disappear momentarily when the user holds a tap.
    func setTitle(_ title: String) {
        setTitle(title, for: .normal)
        setTitle(title, for: .highlighted)
    }
}
