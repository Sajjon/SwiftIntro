//
//  SettingsVC.swift
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// The settings screen view controller — the app's entry point after launch.
///
/// Thin by design: installs `SettingsView` as the root view and reacts to
/// its `onStartGame` callback to push the loading screen.
///
/// `SettingsVC` also acts as the app-wide navigation coordinator: it conforms to
/// `LoadingDataNavigatorProtocol`, `GameNavigatorProtocol`, and `GameOverNavigatorProtocol`,
/// centralising all navigation-stack manipulation in one place.
final class SettingsVC: UIViewController {
    private let settingsView = SettingsView()

    override func loadView() {
        view = settingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsView.onStartGame = { [weak self] config in
            guard let self else { return }
            let loadingVC = LoadingVC(config: config)
            loadingVC.navigator = self
            navigationController?.pushViewController(loadingVC, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The navigation bar is hidden app-wide; keep it hidden when returning to settings.
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - LoadingNavigatorProtocol

extension SettingsVC: LoadingNavigatorProtocol {
    /// Replaces `LoadingVC` in the navigation stack with `GameVC` so the player
    /// cannot navigate back to the loading screen with the back gesture.
    func navigateToGame(
        config: GameConfiguration,
        cards: CardDuplicates
    ) {
        let gameVC = GameVC(config: config, cards: cards)
        gameVC.navigator = self
        guard var viewControllers = navigationController?.viewControllers else { return }
        viewControllers[viewControllers.count - 1] = gameVC
        navigationController?.setViewControllers(viewControllers, animated: false)
    }
}

// MARK: - GameNavigatorProtocol

extension SettingsVC: GameNavigatorProtocol {
    /// Pushes `GameOverVC` onto the navigation stack after the final flip animation.
    func navigateToGameOver(outcome: GameOutcome) {
        let config = GameConfiguration(level: outcome.level)
        let gameOverVC = GameOverVC(config: config, outcome: outcome)
        gameOverVC.navigator = self
        navigationController?.pushViewController(gameOverVC, animated: true)
    }
}

// MARK: - GameOverNavigatorProtocol

extension SettingsVC: GameOverNavigatorProtocol {
    /// Replaces the current `GameOverVC` + `GameVC` pair with a new `GameVC` using
    /// the same images shuffled in a fresh order, so the player skips the loading screen.
    func restartGame(
        config: GameConfiguration,
        cards: CardDuplicates
    ) {
        var shuffled = cards
        shuffled.shuffle()
        let gameVC = GameVC(config: config, cards: shuffled)
        gameVC.navigator = self
        guard var viewControllers = navigationController?.viewControllers else { return }
        viewControllers.removeLast(2)
        viewControllers.append(gameVC)
        navigationController?.setViewControllers(viewControllers, animated: false)
    }

    /// Pops back to the settings screen (the root view controller).
    func quitGame() {
        navigationController?.popToRootViewController(animated: true)
    }
}
