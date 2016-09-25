//
//  ImagePrefetcher.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 02/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import Kingfisher

import Foundation
import Kingfisher

protocol ImageCacheProtocol {
    func prefetchImages(_ urls: [URL], done: Closure?)
    func prefetchImage(_ url: URL, done: Closure?)
    func imageFromCache(_ url: URL?) -> UIImage?
}

class Cache: NSObject {


    fileprivate var cache: ImageCache {
        return ImageCache.default
    }
}

extension Cache: ImageCacheProtocol {

    func imageFromCache(_ url: URL?) -> UIImage? {
        guard let url = url else { return nil }
        let imageFromCache = cache.retrieveImageInDiskCache(forKey: url.absoluteString)
        return imageFromCache
    }

    func prefetchImages(_ urls: [URL], done: Closure? = nil) {
        let prefetcher = ImagePrefetcher(urls: urls, options: nil, progressBlock: nil) {
            (skipped, failed, completed) in
            print("Prefetching of image done, skipped \(skipped.count), failed: \(failed.count), completed: \(completed.count)")
            done?()
        }
        prefetcher.start()
    }

    func prefetchImage(_ url: URL, done: Closure? = nil) {
        prefetchImages([url], done: done)
    }
}
