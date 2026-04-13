//
//  HTTPClientProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

protocol HTTPClientProtocol {
    func request<T: Model>(_ route: Router, done: @escaping Done<T>)
    func collectionRequest<T: Model>(_ route: Router, done: @escaping Done<T>)
}
