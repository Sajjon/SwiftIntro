//
//  APIClientProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 20/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

typealias Done<T: Model> = (Result<T>) -> Void
protocol APIClientProtocol {
    func getPhotos(_ username: String, done: @escaping Done<Cards>)
}
