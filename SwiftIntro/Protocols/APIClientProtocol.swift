//
//  APIClientProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 20/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

protocol APIClientProtocol {
    func getPhotos<T: Model>(username: String, done: (Result<T>) -> Void)
}