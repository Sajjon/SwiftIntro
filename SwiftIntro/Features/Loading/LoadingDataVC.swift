//
//  LoadingDataVC.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 19/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import UIKit

// MARK: - LoadingDataNavigatorProtocol

/// Handles navigation triggered by `LoadingDataVC` once data loading is complete.
///
/// Conforming to this protocol rather than coupling directly to `UINavigationController`
/// keeps `LoadingDataVC` navigation-agnostic and makes it trivially testable.
protocol LoadingDataNavigatorProtocol: AnyObject {
    /// Called on the main thread after images are in the memory cache and the game
    /// is ready to start. The conformer is responsible for replacing `LoadingDataVC`
    /// in the navigation stack with `GameVC`.
    func navigateToGame(config: GameConfiguration, cards: CardDuplicates)
}

// MARK: - LoadingDataVC

/// Orchestrates the data-loading phase between the settings screen and the game screen.
///
/// Responsibilities (in order):
/// 1. Fetch card images from the Wikimedia API via `APIClient`.
/// 2. Pre-warm the Kingfisher memory cache so images display instantly on the first card flip.
/// 3. Call `navigator.navigateToGame` once loading is complete.
///
/// The VC is thin — all business decisions (which cards to use, how many) are delegated
/// to `APIClient`, `CardDuplicates`, and the `ImageCacheProtocol`. Navigation is delegated
/// to `navigator` so this VC has no dependency on `UINavigationController`.
final class LoadingDataVC: UIViewController {

    @Injected(\.apiClient) private var apiClient
    @Injected(\.imageCache) private var imageCache

    private let config: GameConfiguration
    /// Stored temporarily while images are being pre-fetched; cleared after navigation.
    private var cards: CardDuplicates?

    /// Wired by the presenting controller (e.g. `SettingsVC`) before the push.
    weak var navigator: LoadingDataNavigatorProtocol?

    init(config: GameConfiguration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = LoadingView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
}

// MARK: - Private

private extension LoadingDataVC {

    func fetchData() {
        apiClient.getPhotos(config.searchQuery) { result in
            switch result {
            case .failure(let error):
                log.error("Failed to get photos: \(error)")
            case .success(let cardSingles):
                self.setupWithModel(cardSingles: cardSingles)
            }
        }
    }

    /// Builds the duplicated deck from the fetched singles, then kicks off image pre-fetching.
    func setupWithModel(cardSingles singles: CardSingles) {
        self.cards = CardDuplicates(singles: singles, config: config)
        prefetchImagesForCards(urls: singles.cards.map(\.imageUrl))
    }

    /// Ensures every card image is in the Kingfisher memory cache before starting the game.
    ///
    /// Pre-fetching prevents the visible lag that would occur if Kingfisher had to hit the
    /// network (or even disk) on the first card flip during gameplay.
    func prefetchImagesForCards(urls: [URL]) {
        imageCache.prefetchImages(urls) {
            log.info("Images in memory cache — starting game")
            self.startGame()
        }
    }

    /// Delegates to `navigator` so `LoadingDataVC` stays navigation-agnostic.
    func startGame() {
        guard let cards = cards else { return }
        onMain {
            self.navigator?.navigateToGame(config: self.config, cards: cards)
        }
    }
}
