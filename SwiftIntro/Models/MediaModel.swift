//
//  MediaModel.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation


struct MediaModel {
    var cardModels: [CardModel]!
}

extension MediaModel: Model {
    init?(response: NSHTTPURLResponse, representation: AnyObject) {
        //swiftlint:disable force_cast
        self.cardModels = CardModel.collection(response: response, representation: representation.valueForKeyPath("items")!)
    }

    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [MediaModel] {
        return []
    }
}
