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
    let headerView = GameHeaderView()

    /// The grid of card cells. Exposed so `GameVC` can assign its data source and delegate.
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        // Uniform spacing between rows and between columns.
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    /// Updates all model-driven UI — called by the Mobius loop `acceptClosure` on every model update.
    func render(_ model: GameModel) {
        headerView.scoreLabel.text = String(
            localized: .Game.pairsFoundUnformatted(pairsFound: model.matches, totalPairs: model.totalPairs)
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
