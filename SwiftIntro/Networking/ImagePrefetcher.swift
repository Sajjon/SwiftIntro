//
//  ImagePrefetcher.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 02/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import Foundation
import Kingfisher
import UIKit

// MARK: - ImageRetrieverProtocol

/// Abstracts the single `KingfisherManager` call used by `Cache` for pre-fetching,
/// so that tests can inject a stub that completes synchronously without hitting the network.
protocol ImageRetrieverProtocol {
    /// Fetches the image at `url` (memory → disk → network) and calls `done` when complete.
    func retrieveImage(with url: URL, done: @escaping () -> Void)
}

// MARK: KingfisherManager + ImageRetrieverProtocol

extension KingfisherManager: ImageRetrieverProtocol {
    /// Wraps `KingfisherManager.retrieveImage(with:completionHandler:)`, discarding the result
    /// and calling `done` once the fetch (memory → disk → network) completes.
    func retrieveImage(with url: URL, done: @escaping () -> Void) {
        retrieveImage(with: url) { _ in done() }
    }
}

// MARK: ImageCacheProtocol

/// Abstraction over Kingfisher's image cache, used for pre-loading and retrieval.
///
/// Decoupled from `Cache` so `LoadingDataVC` can be tested with a stub that
/// reports instant completion without touching the network or disk.
protocol ImageCacheProtocol {
    /// Ensures all `urls` are present in the **memory** cache, then calls `done`.
    func prefetchImages(_ urls: [URL], done: Closure?)

    /// Ensures a single `url` is present in the memory cache, then calls `done`.
    func prefetchImage(_ url: URL, done: Closure?)

    /// Returns the cached `UIImage` for `url` if it is already in the memory cache,
    /// or `nil` if the image has not been loaded yet.
    func imageFromCache(_ url: URL?) -> UIImage?
}

// MARK: Cache

/// Concrete image cache backed by Kingfisher's `ImageCache` and `KingfisherManager`.
final class Cache {
    /// Kingfisher's shared cache, which manages both memory and disk storage.
    private var cache: ImageCache {
        ImageCache.default
    }

    /// Injected retriever — defaults to `KingfisherManager.shared` in production,
    /// replaced with a stub in tests to avoid network calls.
    @Injected(\.imageRetriever) private var retriever
}

extension Cache: ImageCacheProtocol {
    /// Performs a synchronous memory-cache lookup via `ImageCache.retrieveImageInMemoryCache`.
    func imageFromCache(_ url: URL?) -> UIImage? {
        guard let url else { return nil }
        // `retrieveImageInMemoryCache` is synchronous and returns immediately —
        // safe to call from any thread.
        return cache.retrieveImageInMemoryCache(forKey: url.absoluteString)
    }

    /// Uses a `DispatchGroup` to fan out concurrent retrieval requests and calls `done` on the
    /// main queue once every URL has been resolved through memory, disk, or network.
    func prefetchImages(_ urls: [URL], done: Closure? = nil) {
        // `KingfisherManager.retrieveImage` walks memory → disk → network, guaranteeing
        // each image lands in the **memory** cache before `done()` is called.
        //
        // Kingfisher's own `ImagePrefetcher` is not used here because it skips images
        // that are already on disk, leaving them out of the memory cache and causing a
        // visible lag on the first card flip.
        let group = DispatchGroup()
        for url in urls {
            group.enter()
            // The result is intentionally discarded — we only care that the fetch completes.
            retriever.retrieveImage(with: url) { group.leave() }
        }
        // `notify` fires on the main queue once every `group.leave()` has been called.
        group.notify(queue: .main) { done?() }
    }

    /// Convenience wrapper that pre-fetches a single URL by delegating to `prefetchImages`.
    func prefetchImage(_ url: URL, done: Closure? = nil) {
        prefetchImages([url], done: done)
    }
}
