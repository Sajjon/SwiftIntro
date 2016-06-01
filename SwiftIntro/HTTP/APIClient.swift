//
//  APIClient.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

protocol APIClientProtocol {
    func getPhotos<T: Model>(done: (Result<T>) -> Void)
}

class APIClient {

    static let sharedInstance: APIClientProtocol = APIClient()

    private let httpClient: HTTPClientProtocol = HTTPClient.sharedInstance
}

extension APIClient: APIClientProtocol {

    func getPhotos<T: Model>(done: (Result<T>) -> Void) {
        httpClient.collectionRequest(.Photos, done: done)
    }
}