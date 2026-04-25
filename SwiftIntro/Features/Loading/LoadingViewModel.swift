//
//  LoadingViewModel.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import UIKit

/// Drives the loading screen — fetches data, pre-warms the image cache, and
/// navigates to the game when ready.
///
/// The view model is the single source of truth for the loading phase. `LoadingVC`
/// only renders snapshots delivered through `onPhaseChange` and navigates via
/// `onNavigateToGame` — no state lives in the view layer.
final class LoadingViewModel {
    typealias OnPhaseChange = (Phase) -> Void
    typealias OnNavigateToGame = (PreparedGame) -> Void

    // MARK: - Dependencies

    @Injected(\.wikimediaClient) private var wikimediaClient: WikimediaClientProtocol
    @Injected(\.imageCache) private var imageCache: ImageCacheProtocol

    // MARK: - State

    private let config: GameConfiguration

    /// Current visual phase. Every assignment is pushed to the view via `onPhaseChange`.
    private var phase: Phase = .loading {
        didSet {
            // swiftformat:disable:next redundantSelf
            logApp.debug("phase: \(self.phase)")
            onPhaseChange?(phase)
        }
    }

    // MARK: - Callbacks

    /// Fires whenever the phase changes — used by `LoadingView.render(_:)`.
    var onPhaseChange: OnPhaseChange?

    /// Fires once images are cached and the game is ready to start.
    var onNavigateToGame: OnNavigateToGame?

    // MARK: - Init

    init(config: GameConfiguration) {
        self.config = config
    }
}

// MARK: - Phase

extension LoadingViewModel {
    /// The two visual states the loading screen can be in.
    enum Phase {
        /// Spinner shown — either fetching data or pre-warming the image cache.
        case loading
        /// Something went wrong — show the error message and retry button.
        case failed(Swift.Error)
    }
}

extension LoadingViewModel.Phase: CustomStringConvertible {
    var description: String {
        switch self {
        case .loading: "Loading"
        case let .failed(error): "Failed: \(error)"
        }
    }
}

// MARK: - Lifecycle

extension LoadingViewModel {
    /// Wires the callbacks, pushes the initial phase out, and kicks off the data fetch.
    ///
    /// The initial `.loading` render flows through `fetchData()` → `phase = .loading` →
    /// `didSet`, so there's no explicit `onPhaseChange(phase)` call here to avoid
    /// double-firing the callback for the same phase.
    func start(
        onPhaseChange: @escaping OnPhaseChange,
        onNavigateToGame: @escaping OnNavigateToGame
    ) {
        self.onPhaseChange = onPhaseChange
        self.onNavigateToGame = onNavigateToGame
        // swiftformat:disable:next redundantSelf
        logNet.info("LoadingViewModel starting — config: \(self.config)")
        fetchData()
    }

    /// Clears callbacks. Call from `viewDidDisappear`.
    func stop() {
        logNet.debug("LoadingViewModel stopping — clearing callbacks")
        onPhaseChange = nil
        onNavigateToGame = nil
    }

    // MARK: - User actions

    /// Called when the player taps "Retry" after a failure.
    ///
    /// `fetchData()` sets `phase = .loading` internally, which drives the `didSet`
    /// that notifies the view, so no explicit phase assignment is needed here.
    func retry() {
        logNet.info("Player tapped Retry — re-fetching images")
        fetchData()
    }
}

// MARK: - Private

extension LoadingViewModel {
    private func fetchData() {
        phase = .loading
        // swiftformat:disable:next redundantSelf
        logNet.debug("Fetching images from Wikimedia for query: '\(self.config.searchQuery)'")
        wikimediaClient.findImages(with: config.searchQuery) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(singles):
                    logNet.info("Wikimedia returned \(singles.cards.count) image(s) — starting cache prefetch")
                    self.handleFetchSuccess(singles: singles)
                case let .failure(error):
                    logNet.error("Failed to fetch images: \(error)")
                    self.phase = .failed(error)
                }
            }
        }
    }

    private func handleFetchSuccess(singles: CardSingles) {
        let cards = CardDuplicates(singles: singles, config: config)
        let urls = singles.cards.map(\.imageUrl)
        logNet.debug("Prefetching \(urls.count) image URL(s) into cache")
        imageCache.prefetchImages(urls) { [weak self] in
            guard let self else { return }
            guard let onNavigateToGame else {
                logNav.warning("Image prefetch completed but onNavigateToGame is nil — navigation skipped")
                return
            }
            logNet.info("All images in memory cache — navigating to game")
            onNavigateToGame(PreparedGame(config: config, cards: cards))
        }
    }
}
