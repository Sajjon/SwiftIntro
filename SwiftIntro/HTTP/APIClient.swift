//
//  APIClient.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

typealias Done = (AnyObject) -> Void

protocol APIClientProtocol {
    func getPhotos(done: Done)
}