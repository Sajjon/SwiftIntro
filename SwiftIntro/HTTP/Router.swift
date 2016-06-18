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

    case Photos(String)

    var method: Alamofire.Method {
        switch self {
        case .Photos:
            return .GET
        }
    }

    var path: String {
        switch self {
        case .Photos(let username):
            return "\(username)/media/"
        }
    }

    // MARK: URLRequestConvertible
    //swiftlint:disable variable_name
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

//        if let token = Router.OAuthToken {
//            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }

        switch self {
        case .Photos:
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: nil).0
        }
    }
}