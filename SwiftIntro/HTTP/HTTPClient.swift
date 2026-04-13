//
//  HTTPClient.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation
import Alamofire

typealias JSON = [String: Any]

class HTTPClient {}

extension HTTPClient: HTTPClientProtocol {
    func request<T: Model>(_ route: Router, done: @escaping Done<T>) {
        AF.request(route)
            .validate()
            .responseObject { (result: Swift.Result<T, MyError>) in
                switch result {
                case .success(let model):
                    done(Result.success([model]))
                case .failure(let myError):
                    done(Result.failure(myError))
                }
        }
    }

    func collectionRequest<T: Model>(_ route: Router, done: @escaping Done<T>) {
        AF.request(route)
            .validate()
            .responseCollection { (result: Swift.Result<[T], MyError>) in
                switch result {
                case .success(let models):
                    done(Result.success(models))
                case .failure(let myError):
                    done(Result.failure(myError))
                }
        }
    }
}
