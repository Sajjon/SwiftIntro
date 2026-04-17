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

/// Handles navigation triggered by `GameVC<N>` when the player wins.
///
/// The navigator takes an `AnyGameOutcome` (type-erased) so the conforming navigator
/// does not need to be generic over `N`.
protocol GameNavigatorProtocol: AnyObject {
    /// Called on the main thread once the final card-flip animation completes.
    func navigateToGameOver(outcome: AnyGameOutcome)
}

// MARK: - GameVC

/// The game screen view controller, generic over the compile-time card count `N`.
///
/// `GameVC<N>` is a pure view in the Mobius sense — it implements
/// `Connectable` to render `GameModel<N>` and dispatch `GameEvent`s, but owns
/// no loop infrastructure. The `MobiusController` and `GameEffectHandler<N>`
/// live inside `GameLoop<N>`.
final class GameVC<let N: Int>: UIViewController {
    // MARK: Properties

    /// Injected image cache — used to check whether card images are ready before
    /// allowing cell configuration to proceed.
    @Injected(\.imageCache) private var imageCache

    /// Owns the Mobius loop for this game session.
    private let loop: GameLoop<N>

    /// The root view; installed via `loadView()`.
    private let gameView = GameView()

    /// The UIKit data source and delegate — sized from `loop.level` in `init`.
    private let dataSourceAndDelegate: MemoryDataSourceAndDelegate

    /// Wraps a concrete `GameOutcome<N>` into an `AnyGameOutcome` for the navigator.
    /// Injected at init time because a generic method body cannot pick the correct
    /// `AnyGameOutcome` case from `N` without conditional extensions on specific `N` values.
    private let wrapOutcome: (GameOutcome<N>) -> AnyGameOutcome

    /// Wired by the presenting controller before the push.
    weak var navigator: GameNavigatorProtocol?

    // MARK: Inits

    init(
        _ game: PreparedGame<N>,
        wrapOutcome: @escaping (GameOutcome<N>) -> AnyGameOutcome
    ) {
        let cardModelsArray = game.cards.asArray.map(CardModel.init)
        let cardModels = InlineArray<N, CardModel> { i in cardModelsArray[i] }
        let loop = GameLoop<N>(initialModel: GameModel<N>(cards: cardModels, level: game.config.level))
        self.loop = loop
        self.wrapOutcome = wrapOutcome
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

    // MARK: Overrides

    //
    // Overrides live in the main class body rather than an extension because
    // extensions of generic classes cannot contain `@objc` members, and
    // `UIViewController`'s overridable lifecycle methods are `@objc`.

    /// Installs `GameView` as the root view instead of the default plain `UIView`.
    override func loadView() {
        view = gameView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // swiftformat:disable:next redundantSelf
        logGame.notice("Game started — level: \(self.loop.level.debugDescription)")
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
    typealias Input = GameModel<N>
    typealias Output = GameEvent

    func connect(_ consumer: @escaping (GameEvent) -> Void) -> Connection<GameModel<N>> {
        logGame.debug("GameVC connecting to Mobius loop — wiring card-tap dispatch")
        dataSourceAndDelegate.onCardTapped = { consumer(.cardTapped(index: $0)) }
        return Connection(
            acceptClosure: { [weak self] model in
                guard let self else { return }
                loop.update(with: model)
                gameView.render(model)
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
                guard let self else { return }
                navigator?.navigateToGameOver(outcome: wrapOutcome(outcome))
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
        dataSourceAndDelegate.canSelectCard = { [weak self] index in
            guard let self else { return false }
            return loop.canSelectCard(at: index)
        }
        dataSourceAndDelegate.configureCell = { [weak self] cell, index in
            guard let self else { return }
            loop.configureCell(cell, at: index)
        }
    }
}
