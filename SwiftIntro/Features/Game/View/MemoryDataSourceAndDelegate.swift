//
//  MemoryDataSourceAndDelegate.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// Pure UIKit adapter — no game state or logic lives here.
///
/// All decisions (can this cell be selected? how should it look?) are delegated
/// outward via closures, which are implemented by `GameViewModel`.
///
/// `NSObject` is required because `UICollectionViewDataSource` and
/// `UICollectionViewDelegate` are `@objc` protocols.
final class MemoryDataSourceAndDelegate: NSObject {
    typealias OnCardTapped = (Int) -> Void
    typealias CanSelectCard = (Int) -> Bool
    typealias ConfigureCell = (CardCVCell, Int) -> Void

    /// Number of rows on the board (= number of collection view sections).
    private let numberOfRows: Int

    /// Number of columns on the board (= number of items per section).
    private let numberOfColumns: Int

    /// Pure layout math for square card sizing.
    private let gridLayout: CardGridLayout

    /// Called when the player taps a valid, selectable card. Receives the flat index.
    let onCardTapped: OnCardTapped

    /// Returns `true` if the card at the given flat index may be selected right now.
    let canSelectCard: CanSelectCard

    /// Configures the given cell to match the current visual state of the card at `index`.
    let configureCell: ConfigureCell

    init(
        rows: Int,
        columns: Int,
        canSelectCard: @escaping CanSelectCard,
        configureCell: @escaping ConfigureCell,
        onCardTapped: @escaping OnCardTapped
    ) {
        numberOfRows = rows
        numberOfColumns = columns
        gridLayout = CardGridLayout(rows: rows, columns: columns)
        self.canSelectCard = canSelectCard
        self.configureCell = configureCell
        self.onCardTapped = onCardTapped
    }
}

// MARK: - Private Helpers

private extension MemoryDataSourceAndDelegate {
    /// Converts an `IndexPath` (section = row, item = column) to a row-major flat index.
    func flatIndex(for indexPath: IndexPath) -> Int {
        indexPath.item + numberOfColumns * indexPath.section
    }
}

// MARK: - UICollectionViewDataSource

extension MemoryDataSourceAndDelegate: UICollectionViewDataSource {
    /// One section per row keeps the index-path ↔ flat-index math simple:
    /// `flatIndex = section * columns + item`.
    func numberOfSections(in _: UICollectionView) -> Int {
        numberOfRows
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        numberOfColumns
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        // Dequeue only — actual configuration happens in `willDisplay` so that
        // cells are re-configured each time they enter the visible area.
        collectionView.dequeueReusableCell(
            withReuseIdentifier: CardCVCell.cellIdentifier,
            for: indexPath
        )
    }
}

// MARK: - UICollectionViewDelegate

extension MemoryDataSourceAndDelegate: UICollectionViewDelegate {
    func collectionView(
        _: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let index = flatIndex(for: indexPath)
        // Gate on canSelectCard so matched cards cannot be tapped a second time.
        guard canSelectCard(index) else { return }
        onCardTapped(index)
    }

    func collectionView(
        _: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        // `willDisplay` is preferred over `cellForItemAt` for configuration because
        // it fires every time a cell becomes visible, ensuring Kingfisher image loading
        // is triggered even after cells are recycled via the reuse pool.
        guard let cell = cell as? CardCVCell else { return }
        configureCell(cell, flatIndex(for: indexPath))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MemoryDataSourceAndDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt _: Int
    ) -> UIEdgeInsets {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        // Add a bottom inset equal to the line spacing so that row gaps are uniform.
        return UIEdgeInsets(top: 0, left: 0, bottom: flowLayout.minimumLineSpacing, right: 0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let side = gridLayout.squareSide(in: collectionView.bounds.size, flowLayout: flowLayout)
        return CGSize(width: side, height: side)
    }
}
