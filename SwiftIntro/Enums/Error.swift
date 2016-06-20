//
//  Error.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 21/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

enum Error: Int {
    case JSONSerializationError = 10000

    var errorMessage: String {
        switch self {
        case .JSONSerializationError:
            return "JSON could not be serialized into response object"
        }
    }
}