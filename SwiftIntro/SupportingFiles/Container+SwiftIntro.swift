//
//  Container+SwiftIntro.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import Kingfisher

/// Factory dependency registrations for the SwiftIntro app.
///
/// Each computed property creates and caches a single shared instance (`.singleton`),
/// meaning the same object is returned for every `@Injected` property wrapper that
/// references the key path. Registrations are resolved lazily on first access.
extension Container {
    /// The low-level HTTP transport used by `APIClient` to make raw network requests.
    var httpClient: Factory<HTTPClientProtocol> {
        self { HTTPClient() }.singleton
    }

    /// The high-level API client that fetches and decodes Wikimedia image search results.
    var apiClient: Factory<APIClientProtocol> {
        self { APIClient() }.singleton
    }

    /// Kingfisher-backed image cache used to pre-load card images before a game starts.
    var imageCache: Factory<ImageCacheProtocol> {
        self { Cache() }.singleton
    }

    /// The image retriever used by `Cache` to pre-fetch card images into memory.
    var imageRetriever: Factory<ImageRetrieverProtocol> {
        self { KingfisherManager.shared }.singleton
    }

    /// The clock used for all time-delayed dispatches (flip-back timer, navigation delay).
    ///
    /// Tests register `ImmediateClock` via `Container.shared.clock.register { ImmediateClock() }`
    /// to skip real-time waits entirely.
    var clock: Factory<Clock> {
        self { MainQueueClock() }.singleton
    }
}
