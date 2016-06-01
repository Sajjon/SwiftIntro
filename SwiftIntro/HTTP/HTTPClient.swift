//
//  HTTPClient.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import Alamofire

typealias Params = [String: AnyObject]

protocol HTTPClientProtocol {
    func get(path: String, parameters: Params?, done: Done)
}

class HTTPClient {

}

extension HTTPClient: HTTPClientProtocol {
    func get(path: String, parameters: Params?, done: Done) {
//        Alamo
    }
}