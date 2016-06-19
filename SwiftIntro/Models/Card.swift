//
//  Card.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

final class Card {
    let imageUrl: NSURL

    var flipped: Bool = false

    init(imageUrl: NSURL) {
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

    convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        guard let media = representation["images"] as? JSON else { return nil }
        guard let image = media["standard_resolution"] as? JSON else { return nil }
        guard let imageUrlString = image["url"] as? String else { return nil }
        guard let imageUrl = NSURL(string: imageUrlString) else { return nil }
        self.init(imageUrl: imageUrl)
    }

    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Card] {
        guard let representation = representation as? [JSON] else { return [] }
        var cardModels: [Card] = []
        for cardRepresentation in representation {
            guard let card = Card(response: response, representation: cardRepresentation) else { continue }
            cardModels.append(card)
        }

        return cardModels
    }
}
