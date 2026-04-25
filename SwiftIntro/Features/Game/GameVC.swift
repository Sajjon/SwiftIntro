//
//  GameVC.swift
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

// MARK: - GameNavigatorProtocol

/// Handles navigation triggered by `GameVC` when the player wins.
///
/// Conforming to this protocol rather than coupling directly to `UINavigationController`
/// keeps `GameVC` navigation-agnostic and makes it trivially testable.
protocol GameNavigatorProtocol: AnyObject {
    /// Called on the main thread once the final card-flip animation completes.
    func navigateToGameOver(outcome: GameOutcome)
}

// MARK: - GameVC

/// The game screen view controller.
///
/// `GameVC` is a thin MVVM view controller — it installs `GameView`, wires the
/// data source closures to `GameViewModel`, and forwards lifecycle events. All
/// game state and logic live in the view model.
final class GameVC: UIViewController {
    // MARK: Properties

    /// Holds all game state and logic for this session.
    private let viewModel: GameViewModel

    /// The root view; installed via `loadView()`.
    private lazy var gameView = GameView(
        collectionViewDataSource: dataSourceAndDelegate,
        collectionViewDelegate: dataSourceAndDelegate
    )

    /// The UIKit data source and delegate — sized from `viewModel.level` in `init`.
    private let dataSourceAndDelegate: MemoryDataSourceAndDelegate

    /// Wired by the presenting controller (e.g. `RootVC`) before the push.
    weak var navigator: GameNavigatorProtocol?

    // MARK: Inits

    init(_ game: PreparedGame) {
        let viewModel = GameViewModel(game)
        self.viewModel = viewModel
        dataSourceAndDelegate = MemoryDataSourceAndDelegate(
            rows: viewModel.level.rowCount,
            columns: viewModel.level.columnCount,
            canSelectCard: { index in viewModel.canSelectCard(at: index) },
            configureCell: { cell, index in viewModel.configureCell(cell, at: index) },
            onCardTapped: { index in viewModel.cardTapped(at: index) }
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: - Override

extension GameVC {
    /// Installs `GameView` as the root view instead of the default plain `UIView`.
    override func loadView() {
        view = gameView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.start(
            onModelChanged: { [weak self] model in
                self?.gameView.render(model)
            },
            onFlipCard: { [weak self] index, isFaceUp in
                self?.animateFlip(at: index, isFaceUp: isFaceUp)
            },
            onNavigateToGameOver: { [weak self] outcome in
                self?.navigator?.navigateToGameOver(outcome: outcome)
            }
        )
    }

    /// Stops the view model — cancels pending timers and clears callbacks.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logGame.debug("GameVC disappeared — stopping view model")
        viewModel.stop()
    }
}

// MARK: - Private

private extension GameVC {
    /// Looks up the cell at the given flat index and plays the flip animation.
    func animateFlip(
        at flatIndex: Int,
        isFaceUp: Bool
    ) {
        let indexPath = IndexPath(
            item: flatIndex % viewModel.level.columnCount,
            section: flatIndex / viewModel.level.columnCount
        )

        gameView.animateFlip(at: indexPath, isFaceUp: isFaceUp)
    }
}
