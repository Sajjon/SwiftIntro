//
//  APIClientProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

typealias Done<T: Model> = (Result<T>) -> Void
protocol APIClientProtocol {
    func getPhotos(_ searchQuery: String, done: @escaping Done<Cards>)
}
