//
//  APIClient.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

class APIClient {

    fileprivate let httpClient: HTTPClientProtocol

    init(
        httpClient: HTTPClientProtocol
    ) {
        self.httpClient = httpClient
    }
}

extension APIClient: APIClientProtocol {

    func getPhotos(_ username: String, done: @escaping Done<Cards>) {
        httpClient.request(.photos(username), done: done)
    }
}
