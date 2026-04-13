//
//  APIClient.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
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

    func getPhotos(_ searchQuery: String, done: @escaping Done<Cards>) {
        httpClient.request(.searchImages(searchQuery), done: done)
    }
}
