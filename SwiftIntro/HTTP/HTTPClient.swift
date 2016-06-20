//
//  HTTPClient.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import Alamofire

typealias JSON = [String: AnyObject]

class HTTPClient {
    static let sharedInstance: HTTPClientProtocol = HTTPClient()
}

extension HTTPClient: HTTPClientProtocol {
    func request<T: Model>(route: Router, done: (Result<T>) -> Void) {
        Alamofire.request(route)
        .validate()
            .responseObject {
                (response: Response<T, NSError>) in
                let model: T? = response.result.value
                let error: NSError? = response.result.error
                let result = Result(model: model, error: error)
                done(result)
        }
    }

    func collectionRequest<T: Model>(route: Router, done: (Result<T>) -> Void) {
        Alamofire.request(route)
            .validate()
            .responseCollection {
                (response: Response<[T], NSError>) in
                let models: [T]? = response.result.value
                let error: NSError? = response.result.error
                let result = Result(models: models, error: error)
                done(result)
        }
    }
}