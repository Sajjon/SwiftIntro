//
//  UILabel_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 18/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

extension UILabel {

    func setLocalizedText(_ key: L10n) {
        let localizedText = tr(key: key)
        text = localizedText
    }
}
