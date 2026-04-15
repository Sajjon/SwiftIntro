//
//  GameVC.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import MobiusCore
import UIKit

// MARK: GameVC

/// The game screen view controller.
///
/// `GameVC` is a pure view in the Mobius sense — it implements `Connectable` to
/// render `GameModel` and dispatch `GameEvent`s, but owns no loop infrastructure.
/// The `MobiusController` and `GameEffectHandler` live inside `GameLoop`.
final class GameVC: UIViewController {
    // MARK: Properties

    /// Injected image cache — used to check whether card images are ready before
    /// allowing cell configuration to proceed.
    @Injected(\.imageCache) private var imageCache

    /// Owns the Mobius loop for this game session. Update and query operations are
    /// forwarded through here so `GameVC` stays loop-infrastructure-free.
    private let loop: GameLoop

    /// The root view; installed via `loadView()`.
    private let gameView = GameView()

    /// The UIKit data source and delegate, created lazily so `loop.level` is available.
    private lazy var dataSourceAndDelegate: MemoryDataSourceAndDelegate = .init(
        rows: self.loop.level.rowCount,
        columns: self.loop.level.columnCount
    )

    // MARK: Inits

    init(
        config: GameConfiguration,
        cards: CardDuplicates
    ) {
        let cardModels = cards.memoryCards.map { CardModel(imageUrl: $0.imageUrl) }
        loop = GameLoop(initialModel: GameModel(cards: cardModels, level: config.level))
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: Override

extension GameVC {
    /// Installs `GameView` as the root view instead of the default plain `UIView`.
    override func loadView() {
        view = gameView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLoop()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    /// Stops the loop and cancels any pending timers when the screen leaves the hierarchy.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loop.stop()
    }
}

// MARK: - Connectable

extension GameVC: Connectable {
    typealias Input = GameModel
    typealias Output = GameEvent

    /// Called by `MobiusController` (via `GameLoop.start`) when the view connects.
    ///
    /// - Parameter consumer: Dispatch closure — call it with a `GameEvent` to inject
    ///   input into the loop (e.g. when a card is tapped).
    /// - Returns: A `Connection<GameModel>` whose `acceptClosure` renders each new model
    ///   and whose `disposeClosure` cleans up the tap handler on disconnect.
    func connect(_ consumer: @escaping (GameEvent) -> Void) -> Connection<GameModel> {
        dataSourceAndDelegate.onCardTapped = { consumer(.cardTapped(index: $0)) }

        return Connection(
            acceptClosure: { [weak self] model in
                // Keep the loop's effect handler in sync so canSelectCard /
                // configureCell reflect the latest game state.
                self?.loop.update(with: model)
                self?.gameView.render(model)
            },
            disposeClosure: { [weak self] in
                self?.dataSourceAndDelegate.onCardTapped = nil
            }
        )
    }
}

// MARK: - Private

extension GameVC {
    /// Wires the effect handler's UIKit dependencies and starts the Mobius loop.
    private func setupLoop() {
        loop.start(
            view: self,
            collectionView: gameView.collectionView,
            onNavigateToGameOver: { [weak self] outcome in
                self?.navigateToGameOver(outcome: outcome)
            }
        )
    }

    /// Assigns the data source and delegate, registers the cell class, and wires closures.
    private func setupCollectionView() {
        gameView.collectionView.dataSource = dataSourceAndDelegate
        gameView.collectionView.delegate = dataSourceAndDelegate
        gameView.collectionView.register(CardCVCell.self, forCellWithReuseIdentifier: CardCVCell.cellIdentifier)
        wireDataSourceClosures()
    }

    /// Connects the data source's query closures to the loop so it stays decoupled from `GameVC`.
    private func wireDataSourceClosures() {
        dataSourceAndDelegate.canSelectCard = { [weak self] index in
            self?.loop.canSelectCard(at: index) ?? false
        }
        dataSourceAndDelegate.configureCell = { [weak self] cell, index in
            self?.loop.configureCell(cell, at: index)
        }
    }

    /// Pushes `GameOverVC` onto the navigation stack with the completed game's outcome.
    private func navigateToGameOver(outcome: GameOutcome) {
        let config = GameConfiguration(level: loop.level)
        navigationController?.pushViewController(
            GameOverVC(config: config, outcome: outcome),
            animated: true
        )
    }
}
