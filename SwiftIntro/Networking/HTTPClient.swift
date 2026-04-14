//
//  HTTPClient.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation

/// Abstraction over raw HTTP GET requests.
///
/// Decoupled from `URLSession` so the implementation can be swapped out in tests
/// without touching any networking infrastructure.
protocol HTTPClientProtocol {
    /// Performs an HTTP GET request and delivers raw response data or an error.
    ///
    /// The completion closure is always called exactly once, on an arbitrary queue.
    ///
    /// - Parameters:
    ///   - url: The endpoint to fetch.
    ///   - done: Called with `.success(Data)` on a 2xx response with a body,
    ///     or `.failure(Error)` on a network error or missing response body.
    func get(url: URL, done: @escaping (Result<Data, Swift.Error>) -> Void)
}

/// Concrete HTTP client backed by `URLSession`.
///
/// Registered as a `.singleton` in the Factory container so the same session is
/// reused across all requests within a single app session.
final class HTTPClient: HTTPClientProtocol {
    /// The underlying session. Defaults to `.shared` so no extra configuration is needed.
    private let urlSession: URLSession

    /// - Parameter urlSession: The session to use for requests. Defaults to `URLSession.shared`.
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
}

extension HTTPClient {
    /// Performs an HTTP GET request and delivers raw response data or an error.
    ///
    /// The completion closure is always called exactly once, on an arbitrary queue.
    ///
    /// - Parameters:
    ///   - url: The endpoint to fetch.
    ///   - done: Called with `.success(Data)` on a 2xx response with a body,
    ///     or `.failure(Error)` on a network error or missing response body.
    func get(
        url: URL,
        done: @escaping (Result<Data, Swift.Error>) -> Void
    ) {
        // `dataTask` runs asynchronously on a background URLSession delegate queue.
        // `.resume()` must be called explicitly — tasks start suspended by default.
        urlSession.dataTask(with: url) { data, _, error in
            if let error {
                done(.failure(error))
            } else if let data {
                done(.success(data))
            } else {
                // No error and no data — treat as an unexpected empty response.
                done(.failure(URLError(.badServerResponse)))
            }
        }.resume()
    }
}
