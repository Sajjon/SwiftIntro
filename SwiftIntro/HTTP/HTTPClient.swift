//
//  HTTPClient.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import Alamofire

typealias JSON = [String: Any]

class HTTPClient {}

extension HTTPClient: HTTPClientProtocol {
    func request<T: Model>(_ route: Router, done: @escaping Done<T>) {
        Alamofire.request(route)
            .validate()
            .responseObject {
                (response: DataResponse<T>) in
                if let model = response.result.value {
                    done(Result.success([model]))
                } else {
                    let myError: MyError = (response.result.error as? MyError) ?? MyError(.unknown)
                    done(Result.failure(myError))
                }
        }
    }

    func collectionRequest<T: Model>(_ route: Router, done: @escaping Done<T>) {
        Alamofire.request(route)
            .validate()
            .responseCollection {
                (response: DataResponse<[T]>) in
                if let model = response.result.value {
                    done(Result.success(model))
                } else {
                    let myError: MyError = (response.result.error as? MyError) ?? MyError(.unknown)
                    done(Result.failure(myError))
                }
        }
    }
}
