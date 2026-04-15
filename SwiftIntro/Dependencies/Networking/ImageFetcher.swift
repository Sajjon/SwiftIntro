//
//  ImageFetcher.swift
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
protocol ImageFetcherProtocol {
    /// Fetches the image at `url` (memory → disk → network) and calls `done` when complete.
    func fetchImage(
        with url: URL,
        done: @escaping Closure
    )
}

// MARK: KingfisherManager + ImageFetcherProtocol

extension KingfisherManager: ImageFetcherProtocol {
    /// Wraps `KingfisherManager.retrieveImage(with:completionHandler:)`, discarding the result
    /// and calling `done` once the fetch (memory → disk → network) completes.
    func fetchImage(
        with url: URL,
        done: @escaping Closure
    ) {
        retrieveImage(with: url) { _ in done() }
    }
}
