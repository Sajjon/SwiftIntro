//
//  Card.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

final class Card {
    let imageUrl: URL

    var isFlipped: Bool = false
    var isMatched: Bool = false

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
        guard let imageInfoArray = json["imageinfo"] as? [JSON],
              let imageInfo = imageInfoArray.first,
              let urlString = imageInfo["url"] as? String,
              let imageUrl = URL(string: urlString),
              Card.isImageURL(urlString) else { return nil }
        self.init(imageUrl: imageUrl)
    }

    private static func isImageURL(_ urlString: String) -> Bool {
        let lower = urlString.lowercased()
        return lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg") || lower.hasSuffix(".png")
    }
}
