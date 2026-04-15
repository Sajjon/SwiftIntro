//
//  APIClient.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import Foundation

/// Abstraction over the Wikimedia Commons image search API.
///
/// Decoupled from the concrete `APIClient` so call sites (e.g. `LoadingDataVC`)
/// can be tested with a stub that returns canned `CardSingles` without hitting the network.
protocol APIClientProtocol {
    /// Searches Wikimedia Commons for images matching `searchQuery` and returns
    /// the results as a set of unique `Card` values.
    ///
    /// - Parameters:
    ///   - searchQuery: The search term (e.g. "cats") forwarded to the Wikimedia API.
    ///   - done: Called on an arbitrary background queue with `.success(CardSingles)`
    ///     on success, or `.failure(Error)` if the network request or JSON decoding fails.
    func getPhotos(
        _ searchQuery: String,
        done: @escaping @Sendable (Result<CardSingles, Swift.Error>) -> Void
    )
}

/// Concrete implementation of `APIClientProtocol` backed by Wikimedia Commons.
///
/// Uses `HTTPClientProtocol` (injected via Factory) to fetch raw JSON, then decodes
/// it with `Codable` into `CardSingles`. The Wikimedia response types are private
/// to this file — callers only ever see `CardSingles`.
final class APIClient: APIClientProtocol {
    /// Injected HTTP transport layer. Using the protocol allows test doubles to be
    /// substituted without touching URLSession or any real networking.
    @Injected(\.httpClient) private var httpClient

    func getPhotos(
        _ searchQuery: String,
        done: @escaping @Sendable (Result<CardSingles, Swift.Error>) -> Void
    ) {
        let url = Router.searchImages(searchQuery).url
        httpClient.get(url: url) { result in APIClient.decodeAndDeliver(result, done: done) }
    }
}

// MARK: - Private helpers

private extension APIClient {
    static func decodeAndDeliver(
        _ result: Result<Data, Error>,
        done: @escaping (Result<CardSingles, Error>) -> Void
    ) {
        switch result {
        case let .failure(error):
            done(.failure(error))
        case let .success(data):
            do {
                try done(.success(APIClient.parse(data)))
            } catch {
                done(.failure(error))
            }
        }
    }
}

// MARK: - Wikimedia response types (file-private, Decodable only)

/// Mirrors the Wikimedia API response structure used only for decoding.
/// Kept private so the rest of the app never depends on this shape.
private struct WikimediaResponse: Decodable {
    let query: WikimediaQuery
}

private struct WikimediaQuery: Decodable {
    /// A dictionary keyed by page ID. Values are the actual page metadata.
    let pages: [String: WikimediaPage]
}

private struct WikimediaPage: Decodable {
    /// One entry per image revision; only the most recent (`first`) is used.
    let imageinfo: [WikimediaImageInfo]?
}

private struct WikimediaImageInfo: Decodable {
    let url: String
}

// MARK: - JSON Parsing

private extension APIClient {
    /// Decodes raw JSON and filters out non-image URLs, returning a `CardSingles` collection.
    static func parse(_ data: Data) throws -> CardSingles {
        let response = try JSONDecoder().decode(WikimediaResponse.self, from: data)
        let cards = response.query.pages.values.compactMap { page -> Card? in
            guard
                let urlString = page.imageinfo?.first?.url,
                isImageURL(urlString),
                let url = URL(string: urlString)
            else { return nil }
            return Card(imageUrl: url)
        }
        return CardSingles(cards: cards)
    }

    /// Returns `true` if the URL string ends with a supported image extension.
    ///
    /// Wikimedia pages sometimes link to PDFs or OGG files — this guard keeps
    /// only JPEG and PNG URLs that `Kingfisher` can display as `UIImage`.
    static func isImageURL(_ urlString: String) -> Bool {
        let lower = urlString.lowercased()
        return ["jpg", "jpeg", "png"].contains { lower.hasSuffix($0) }
    }
}
