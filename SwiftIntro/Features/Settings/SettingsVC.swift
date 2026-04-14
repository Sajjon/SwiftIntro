//
//  SettingsVC.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// The settings screen view controller — the app's entry point after launch.
///
/// Thin by design: installs `SettingsView` as the root view and reacts to
/// its `onStartGame` callback to push the loading screen.
final class SettingsVC: UIViewController {
    private let settingsView = SettingsView()

    override func loadView() {
        view = settingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsView.onStartGame = { [weak self] config in
            guard let self else { return }
            let loadingVC = LoadingDataVC(config: config)
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

// MARK: - LoadingDataNavigatorProtocol

extension SettingsVC: LoadingDataNavigatorProtocol {
    /// Replaces `LoadingDataVC` in the navigation stack with `GameVC` so the player
    /// cannot navigate back to the loading screen with the back gesture.
    func navigateToGame(config: GameConfiguration, cards: CardDuplicates) {
        let gameVC = GameVC(config: config, cards: cards)
        guard var viewControllers = navigationController?.viewControllers else { return }
        viewControllers[viewControllers.count - 1] = gameVC
        navigationController?.setViewControllers(viewControllers, animated: false)
    }
}
