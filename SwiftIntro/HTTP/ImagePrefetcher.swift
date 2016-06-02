//
//  ImagePrefetcher.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 02/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

protocol ImagePrefetcherProtocol {
    func prefetchImages(urls: [URLRequestConvertible], done: Closure)
}

class ImagePrefetcher {

    static let sharedInstance: ImagePrefetcherProtocol = ImagePrefetcher()
    private let imageDownloader: ImageDownloader

    init() {
        self.imageDownloader = ImageDownloader(
            configuration: ImageDownloader.defaultURLSessionConfiguration(),
            downloadPrioritization: .FIFO,
            maximumActiveDownloads: 4,
            imageCache: AutoPurgingImageCache()
        )
    }
}

extension ImagePrefetcher: ImagePrefetcherProtocol {

    func prefetchImages(urls: [URLRequestConvertible], done: Closure) {

        let queue = dispatch_queue_create("my_serial_background_thread", DISPATCH_QUEUE_SERIAL)

        imageDownloader.downloadImages(URLRequests: urls, filter: nil, progress: { (bytesRead, totalBytesRead, totalExpectedBytesToRead) in
            print("Size: \(totalExpectedBytesToRead), read: \(totalBytesRead)")
        }, progressQueue: queue) {
            response in
            done()
        }
    }
}