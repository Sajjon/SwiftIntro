//
//  GameSetupVC.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 20/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

// MARK: - GameSetupNavigatorProtocol

/// Handles navigation triggered by `GameSetupVC` when the player taps "Start Game".
protocol GameSetupNavigatorProtocol: AnyObject {
    func navigateToLoading(config: GameConfiguration)
}

// MARK: - GameSetupVC

/// The game-setup screen — collects the player's search query and difficulty level,
/// then delegates navigation to `RootVC` via `GameSetupNavigatorProtocol`.
final class GameSetupVC: UIViewController {
    private let gameSetupView = GameSetupView()

    weak var navigator: GameSetupNavigatorProtocol?
}

// MARK: Override

extension GameSetupVC {
    override func loadView() {
        view = gameSetupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logGame.debug("GameSetupVC loaded — waiting for player to start a game")
        gameSetupView.onStartGame = { [weak self] config in
            logGame.info("Player tapped Start Game — query: '\(config.searchQuery)', level: \(config.level)")
            self?.navigator?.navigateToLoading(config: config)
        }
    }
}
