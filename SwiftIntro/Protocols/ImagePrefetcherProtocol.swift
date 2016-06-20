//
//  ImagePrefetcherProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 20/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit
import Alamofire

protocol ImagePrefetcherProtocol {
    func prefetchImages(urls: [URLRequestConvertible], done: Closure)
    func imageFromCache(url: NSURL) -> UIImage?
}