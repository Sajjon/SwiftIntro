//
//  Router.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "https://commons.wikimedia.org/w/api.php"

    case searchImages(String)

    var method: HTTPMethod {
        switch self {
        case .searchImages:
            return .get
        }
    }

    var parameters: Parameters? {
        switch self {
        case .searchImages(let query):
            return [
                "action": "query",
                "generator": "search",
                "gsrsearch": query,
                "gsrnamespace": "6",
                "prop": "imageinfo",
                "iiprop": "url",
                "format": "json",
                "gsrlimit": "50"
            ]
        }
    }

    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest
    }
}
