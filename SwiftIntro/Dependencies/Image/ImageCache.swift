//
//  ImageCache.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 2026-04-15.
//  Copyright © 2026 SwiftIntro. All rights reserved.
//

import Factory
import Kingfisher

/// A zero-argument, no-return closure — used throughout the app for completion callbacks
/// and button-action handlers where no parameters need to be passed.
typealias Closure = () -> Void

// MARK: ImageCacheProtocol

/// Abstraction over Kingfisher's image cache, used for pre-loading and retrieval.
///
/// Decoupled from `Cache` so `LoadingVC` can be tested with a stub that
/// reports instant completion without touching the network or disk.
protocol ImageCacheProtocol {
    /// Ensures all `urls` are present in the **memory** cache, then calls `done`.
    func prefetchImages(
        _ urls: [URL],
        done: Closure?
    )
}

// MARK: Cache

/// Concrete image cache backed by Kingfisher's `ImageCache` and `KingfisherManager`.
final class ImageCache {
    /// Injected retriever — defaults to `KingfisherManager.shared` in production,
    /// replaced with a stub in tests to avoid network calls.
    @Injected(\.imageFetcher) private var fetcher

    /// Kingfisher's shared cache, which manages both memory and disk storage.
    private var cache: Kingfisher.ImageCache {
        Kingfisher.ImageCache.default
    }
}

extension ImageCache: ImageCacheProtocol {
    /// Uses a `DispatchGroup` to fan out concurrent retrieval requests and calls `done` on the
    /// main queue once every URL has been resolved through memory, disk, or network.
    func prefetchImages(
        _ urls: [URL],
        done: Closure? = nil
    ) {
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
            fetcher.fetchImage(with: url) { group.leave() }
        }
        // `notify` fires on the main queue once every `group.leave()` has been called.
        group.notify(queue: .main) { done?() }
    }
}
