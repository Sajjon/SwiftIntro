//
//  Router.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

// MARK: Router

/// Builds fully-qualified `URL`s for each API endpoint.
///
/// Adding a new endpoint means adding a new case and its corresponding `queryItems`.
enum Router {
    /// Search Wikimedia Commons for files matching the given query string.
    case searchImages(String)
}

// MARK: Computed Properties

extension Router {
    /// The fully-constructed `URL` for this route, ready to pass to `HTTPClientProtocol.get`.
    var url: URL {
        // `URLComponents` handles percent-encoding of the query string automatically,
        // which avoids manual encoding bugs when the search term contains spaces or
        // special characters.
        var components = URLComponents(string: "https://commons.wikimedia.org/w/api.php")!
        switch self {
        case let .searchImages(query):
            components.queryItems = [
                URLQueryItem(name: "action", value: "query"),
                // `generator=search` lets us fetch both search results and image metadata
                // in a single API call instead of two round trips.
                URLQueryItem(name: "generator", value: "search"),
                URLQueryItem(name: "gsrsearch", value: query),
                // Namespace 6 = "File:" — restricts results to media files only.
                URLQueryItem(name: "gsrnamespace", value: "6"),
                URLQueryItem(name: "prop", value: "imageinfo"),
                // `iiprop=url` requests the direct file URL in each page's imageinfo array.
                URLQueryItem(name: "iiprop", value: "url"),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "gsrlimit", value: "50"),
            ]
        }
        return components.url!
    }
}
