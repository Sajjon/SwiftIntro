//
//  Router.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "https://www.instagram.com/"

    case photos(String)

    var method: Alamofire.HTTPMethod {
        switch self {
        case .photos:
            return .get
        }
    }

    var path: String {
        switch self {
        case .photos(let username):
            return "\(username)/media/"
        }
    }

    var parameters: Parameters? {
        return nil
    }

    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest
    }
}
