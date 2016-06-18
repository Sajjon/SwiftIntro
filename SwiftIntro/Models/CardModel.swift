//
//  CardModel.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

final class CardModel {
    let imageUrl: NSURL

    var flipped: Bool = false

    init(imageUrl: NSURL) {
        self.imageUrl = imageUrl
    }
}

//MARK: Equatable
extension CardModel: Equatable {}
func == (lhs: CardModel, rhs: CardModel) -> Bool {
    let same = lhs.imageUrl == rhs.imageUrl
    return same
}

//MARK: Model
extension CardModel: Model {

    convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        guard let media = representation["images"] as? JSON else { return nil }
        guard let image = media["standard_resolution"] as? JSON else { return nil }
        guard let imageUrlString = image["url"] as? String else { return nil }
        guard let imageUrl = NSURL(string: imageUrlString) else { return nil }
        self.init(imageUrl: imageUrl)
    }

    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [CardModel] {
        guard let representation = representation as? [JSON] else { return [] }
        var cardModels: [CardModel] = []
        for cardRepresentation in representation {
            guard let card = CardModel(response: response, representation: cardRepresentation) else { continue }
            cardModels.append(card)
        }

        return cardModels
    }
}
