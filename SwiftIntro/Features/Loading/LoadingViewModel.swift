//
//  LoadingViewModel.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Diffuser
import Factory
import UIKit

/// Drives the loading screen — fetches data, pre-warms the image cache, and
/// navigates to the game when ready.
///
/// `LoadingVC` creates a `Diffuser<Phase>` and injects it at init time, so state
/// changes flow directly to `LoadingView` with no optionality or separate `start` wiring.
final class LoadingViewModel {
    // MARK: - Phase

    /// The two visual states the loading screen can be in.
    enum Phase {
        /// Spinner shown — either fetching data or pre-warming the image cache.
        case loading
        /// Something went wrong — show the error message and retry button.
        case failed(Error)
    }

    // MARK: - Dependencies

    @Injected(\.wikimediaClient) private var wikimediaClient
    @Injected(\.imageCache) private var imageCache

    // MARK: - State

    private let config: GameConfiguration
    private let diffuser: Diffuser<Phase>

    /// Current visual phase. Every assignment is automatically pushed to the view
    /// via the diffuser — no optional unwrap, no manual `run` call at the call site.
    private var phase: Phase = .loading {
        didSet { diffuser.run(phase) }
    }

    // MARK: - Navigation

    /// Called on the main thread when images are cached and the game is ready to start.
    var onNavigateToGame: ((PreparedGame) -> Void)?

    // MARK: - Init

    init(
        config: GameConfiguration,
        diffuser: Diffuser<Phase>
    ) {
        self.config = config
        self.diffuser = diffuser
    }
}

// MARK: - Lifecycle

extension LoadingViewModel {
    /// Renders the initial state and kicks off the data fetch.
    func start() {
        diffuser.run(phase)
        fetchData()
    }

    /// Clears callbacks. Call from `viewDidDisappear`.
    func stop() {
        onNavigateToGame = nil
    }

    // MARK: - User actions

    /// Called when the player taps "Retry" after a failure.
    func retry() {
        phase = .loading
        fetchData()
    }
}

// MARK: - Private

extension LoadingViewModel {
    private func fetchData() {
        wikimediaClient.findImages(with: config.searchQuery) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(singles):
                    self.handleFetchSuccess(singles: singles)
                case let .failure(error):
                    log.error("Failed to fetch images: \(error)")
                    self.phase = .failed(error)
                }
            }
        }
    }

    private func handleFetchSuccess(singles: CardSingles) {
        let cards = CardDuplicates(singles: singles, config: config)
        let urls = singles.cards.map(\.imageUrl)
        imageCache.prefetchImages(urls) { [weak self] in
            log.info("Images in memory cache — starting game")
            guard let self else { return }
            onNavigateToGame?(PreparedGame(config: config, cards: cards))
        }
    }
}
