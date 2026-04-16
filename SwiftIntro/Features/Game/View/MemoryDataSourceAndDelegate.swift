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
/// outward via closures, which are implemented by `GameEffectHandler`.
///
/// `NSObject` is required because `UICollectionViewDataSource` and
/// `UICollectionViewDelegate` are `@objc` protocols.
final class MemoryDataSourceAndDelegate: NSObject {
    /// Number of rows on the board (= number of collection view sections).
    private let numberOfRows: Int

    /// Number of columns on the board (= number of items per section).
    private let numberOfColumns: Int

    /// Called when the player taps a valid, selectable card. Receives the flat index.
    var onCardTapped: ((Int) -> Void)?

    /// Returns `true` if the card at the given flat index may be selected right now.
    var canSelectCard: ((Int) -> Bool)?

    /// Configures the given cell to match the current visual state of the card at `index`.
    var configureCell: ((CardCVCell, Int) -> Void)?

    init(
        rows: Int,
        columns: Int
    ) {
        numberOfRows = rows
        numberOfColumns = columns
    }
}

// MARK: - Private Helpers

private extension MemoryDataSourceAndDelegate {
    /// Converts an `IndexPath` (section = row, item = column) to a row-major flat index.
    func flatIndex(for indexPath: IndexPath) -> Int {
        indexPath.item + numberOfColumns * indexPath.section
    }

    /// Returns the square side length that fits all cards in the visible grid,
    /// respecting both the horizontal and vertical spacing constraints.
    func calculateCardSize(
        _ flowLayout: UICollectionViewFlowLayout,
        collectionView: UICollectionView
    ) -> CGSize {
        // Use the smaller of the two axis-maximum sizes so cards are always square
        // and never overflow in either direction.
        let side = min(
            calculateMinimumHeight(flowLayout, collectionView: collectionView),
            calculateMinimumWidth(flowLayout, collectionView: collectionView)
        )
        return CGSize(width: side, height: side)
    }

    /// Maximum card height that fits all rows in the available vertical space.
    func calculateMinimumHeight(
        _ flowLayout: UICollectionViewFlowLayout,
        collectionView: UICollectionView
    ) -> CGFloat {
        let rows = CGFloat(numberOfRows)
        // Total vertical space consumed by section insets and inter-row spacing.
        let spacing = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
            + flowLayout.minimumLineSpacing * (rows - 1)
        // `trunc` avoids sub-pixel cell sizes that can cause layout rounding artefacts.
        return trunc((collectionView.bounds.height - spacing) / rows)
    }

    /// Maximum card width that fits all columns in the available horizontal space.
    func calculateMinimumWidth(
        _ flowLayout: UICollectionViewFlowLayout,
        collectionView: UICollectionView
    ) -> CGFloat {
        let columns = CGFloat(numberOfColumns)
        // Total horizontal space consumed by section insets and inter-column spacing.
        let spacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right
            + flowLayout.minimumInteritemSpacing * (columns - 1)
        return trunc((collectionView.bounds.width - spacing) / columns)
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
        collectionView.dequeueReusableCell(withReuseIdentifier: CardCVCell.cellIdentifier, for: indexPath)
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
        guard canSelectCard?(index) == true else { return }
        onCardTapped?(index)
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
        configureCell?(cell, flatIndex(for: indexPath))
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
        return calculateCardSize(flowLayout, collectionView: collectionView)
    }
}
