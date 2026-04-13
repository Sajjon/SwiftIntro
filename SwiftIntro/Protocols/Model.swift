//
//  Model.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 21/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

protocol Model: ResponseCollectionSerializable, ResponseObjectSerializable {
    init?(response: HTTPURLResponse, json: JSON)
}

extension Model {
    init?(response: HTTPURLResponse, representation: Any) {
        guard let json = representation as? JSON else { return nil }
        self.init(response: response, json: json)
    }
}
