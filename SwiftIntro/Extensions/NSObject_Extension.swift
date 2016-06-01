//
//  NSObject_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

extension NSObject {
    class var className: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}