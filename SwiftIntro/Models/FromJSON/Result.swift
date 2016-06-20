//
//  Result.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 21/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

struct Result<T: Model> {
    var model: T?
    var models: [T]?
    var error: NSError?

    init(model: T? = nil, models: [T]? = nil, error: NSError? = nil) {
        self.model = model
        self.models = models
        self.error = error
    }
}