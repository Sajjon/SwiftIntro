//
//  WikimediaClientProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 2026-04-16.
//  Copyright © 2026 SwiftIntro. All rights reserved.
//

/// Abstraction over the Wikimedia Commons image search API.
///
/// Decoupled from the concrete `WikimediaClient` so call sites (e.g. `LoadingVC`)
/// can be tested with a stub that returns canned `CardSingles` without hitting the network.
protocol WikimediaClientProtocol {
    /// Searches Wikimedia Commons for images matching `searchQuery` and returns
    /// the results as a set of unique `Card` values.
    ///
    /// - Parameters:
    ///   - searchQuery: The search term (e.g. "cats") forwarded to the Wikimedia API.
    ///   - done: Called on an arbitrary background queue with `.success(CardSingles)`
    ///     on success, or `.failure(Error)` if the network request or JSON decoding fails.
    func findImages(
        with searchQuery: String,
        done: @escaping @Sendable (Result<CardSingles, Swift.Error>) -> Void
    )
}
