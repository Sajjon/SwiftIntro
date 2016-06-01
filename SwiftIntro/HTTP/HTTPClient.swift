//
//  HTTPClient.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation

typealias Params = [String: AnyObject]

protocol HTTPClient {
    func get(path: String, parameters: Params?, done: Done)
}