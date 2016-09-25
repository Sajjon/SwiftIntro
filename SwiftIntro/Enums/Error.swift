//
//  Error.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 21/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

struct MyError: Error, CustomStringConvertible {
    let description: String
    let type: MyErrorType
    let code: Int

    init(_ type: MyErrorType = .unknown, description: String? = nil) {
        self.type = type
        self.code = type.rawValue
        self.description = description ?? type.errorMessage
    }

    init(_ type: MyErrorType = .unknown, error: Error) {
        self.type = type
        self.code = type.rawValue
        self.description = error.localizedDescription
    }

    var nsError: NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: description]
        let error = NSError(domain: "SwiftIntro", code: code, userInfo: userInfo)
        return error
    }
}

enum MyErrorType: Int {
    case unknown = 10000
    case network = 10001
    case jsonParsing = 10002
    case modelMapping = 10003

    var errorMessage: String {
        switch self {
        case .jsonParsing:
            return "JSON could not be parsed"
        case .unknown:
            return "unknown"
        case .network:
            return "network error"
        case .modelMapping:
            return "JSON could not be mapped to a model"
        }
    }
}
