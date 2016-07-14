//
//  APIClient.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

class APIClient {

    private let httpClient: HTTPClientProtocol

    init(
        httpClient: HTTPClientProtocol
    ) {
        self.httpClient = httpClient
    }
}

extension APIClient: APIClientProtocol {

    func getPhotos<T: Model>(username: String, done: (Result<T>) -> Void) {
        httpClient.request(.Photos(username), done: done)
    }
}