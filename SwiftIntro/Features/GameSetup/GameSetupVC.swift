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
    func startGame(config: GameConfiguration)
}

// MARK: - GameSetupVC

/// The game-setup screen — collects the player's search query and difficulty level,
/// then delegates navigation to `RootVC` via `GameSetupNavigatorProtocol`.
final class GameSetupVC: UIViewController {
    private let gameSetupView = GameSetupView()

    weak var navigator: GameSetupNavigatorProtocol?

    override func loadView() {
        view = gameSetupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gameSetupView.onStartGame = { [weak self] config in
            self?.navigator?.startGame(config: config)
        }
    }
}
