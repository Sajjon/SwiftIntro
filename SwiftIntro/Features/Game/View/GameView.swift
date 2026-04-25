//
//  GameView.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// The root view of the game screen.
///
/// Contains a fixed-height score header above a full-bleed card grid.
/// All visual state is derived from `GameModel` via `render(_:)` — no state is stored here.
final class GameView: UIView {
    /// The header bar that displays the current match score.
    lazy var headerView = GameHeaderView()

    /// The grid of card cells. The data source and delegate are injected at init
    /// time, so this stays encapsulated inside `GameView`.
    private let collectionView: SingleCellTypeCollectionView<CardCVCell>

    init(
        collectionViewDataSource: (any UICollectionViewDataSource)? = nil,
        collectionViewDelegate: (any UICollectionViewDelegate)? = nil
    ) {
        collectionView = SingleCellTypeCollectionView(
            dataSource: collectionViewDataSource,
            delegate: collectionViewDelegate
        )
        super.init(frame: .zero)
        backgroundColor = .black
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

extension GameView {
    func animateFlip(
        at indexPath: IndexPath,
        isFaceUp: Bool
    ) {
        guard let cell = collectionView.cellForItemAt(indexPath) else {
            logGame.warning("animateFlip skipped — no visible cell at \(indexPath) (likely off-screen)")
            return
        }
        cell.animateFlip(faceUp: isFaceUp)
    }

    /// Updates all model-driven UI — invoked from `GameViewModel.onModelChanged`
    /// whenever the view model emits a new `GameModel` snapshot (first via
    /// `GameViewModel.start`, then on every subsequent state change).
    func render(_ model: GameModel) {
        headerView.scoreLabel.text = String(
            localized: .Game.pairsFoundUnformatted(
                pairsFound: model.matches,
                totalPairs: model.totalPairs
            )
        )
    }
}

// MARK: - Private

private extension GameView {
    /// Adds the header and collection view as subviews and activates their constraints.
    func setupLayout() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerView)
        addSubview(collectionView)
        activateLayoutConstraints()
    }

    /// Pins the header below the safe area and the collection view to fill the remaining space.
    func activateLayoutConstraints() {
        NSLayoutConstraint.activate([
            // Header sits directly below the safe-area top (avoids the status bar / notch).
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            // Collection view fills everything below the header, edge to edge.
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
