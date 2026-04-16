//
//  GameVC.swift
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import MobiusCore
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

    /// The UIKit data source and delegate — sized from `loop.level` in `init`.
    private let dataSourceAndDelegate: MemoryDataSourceAndDelegate

    /// Wired by the presenting controller (e.g. `GameSetupVC`) before the push.
    weak var navigator: GameNavigatorProtocol?

    // MARK: Inits

    init(_ game: PreparedGame) {
        let cardModels = game.cards.memoryCards.map(CardModel.init)
        let loop = GameLoop(initialModel: GameModel(cards: cardModels, level: game.config.level))
        self.loop = loop
        dataSourceAndDelegate = MemoryDataSourceAndDelegate(
            rows: loop.level.rowCount,
            columns: loop.level.columnCount
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

    override func viewDidLoad() {
        super.viewDidLoad()
        logGame.notice("Game started — level: \(loop.level.debugDescription)")
        setupCollectionView()
        setupLoop()
    }

    /// Stops the loop and cancels any pending timers when the screen leaves the hierarchy.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logGame.debug("GameVC disappeared — stopping Mobius loop")
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
        logGame.debug("GameVC connecting to Mobius loop — wiring card-tap dispatch")
        dataSourceAndDelegate.onCardTapped = { consumer(.cardTapped(index: $0)) }
        let gameLoop = loop
        return Connection(
            acceptClosure: { [weak self] model in
                // Keep the loop's effect handler in sync so canSelectCard /
                // configureCell reflect the latest game state.
                gameLoop.update(with: model)
                self?.gameView.render(model)
            },
            disposeClosure: { [weak self] in
                logGame.debug("GameVC disconnecting from Mobius loop — removing card-tap handler")
                self?.dataSourceAndDelegate.onCardTapped = nil
            }
        )
    }
}

// MARK: - Private

private extension GameVC {
    /// Wires the effect handler's UIKit dependencies and starts the Mobius loop.
    func setupLoop() {
        loop.start(
            view: self,
            collectionView: gameView.collectionView,
            onNavigateToGameOver: { [weak self] outcome in
                self?.navigator?.navigateToGameOver(outcome: outcome)
            }
        )
    }

    /// Assigns the data source and delegate, registers the cell class, and wires closures.
    func setupCollectionView() {
        gameView.collectionView.dataSource = dataSourceAndDelegate
        gameView.collectionView.delegate = dataSourceAndDelegate
        gameView.collectionView.register(CardCVCell.self, forCellWithReuseIdentifier: CardCVCell.cellIdentifier)
        wireDataSourceClosures()
    }

    /// Connects the data source's query closures to the loop so it stays decoupled from `GameVC`.
    func wireDataSourceClosures() {
        let gameLoop = loop
        dataSourceAndDelegate.canSelectCard = { index in
            gameLoop.canSelectCard(at: index)
        }
        dataSourceAndDelegate.configureCell = { cell, index in
            gameLoop.configureCell(cell, at: index)
        }
    }
}
