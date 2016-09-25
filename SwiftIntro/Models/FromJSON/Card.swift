//
//  Card.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

final class Card {
    let imageUrl: URL

    var flipped: Bool = false
    var matched: Bool = false

    init(imageUrl: URL) {
        self.imageUrl = imageUrl
    }
}

//MARK: Equatable
extension Card: Equatable {}
func == (lhs: Card, rhs: Card) -> Bool {
    let same = lhs.imageUrl == rhs.imageUrl
    return same
}

//MARK: Model
extension Card: Model {

    convenience init?(response: HTTPURLResponse, json: JSON) {
        guard let
            media = json["images"] as? JSON,
            let image = media["standard_resolution"] as? JSON,
            let imageUrlString = image["url"] as? String,
            let imageUrl = URL(string: imageUrlString) else { return nil }
        self.init(imageUrl: imageUrl)
    }
}
