//
//  CardGridLayout.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// Pure layout math for the card grid — computes square cell sizes that fit the
/// available space given row/column counts, section insets, and inter-item spacing.
///
/// Kept free of `UICollectionView` so it can be unit-tested directly.
struct CardGridLayout {
    let rows: Int
    let columns: Int
}

extension CardGridLayout {
    /// Returns the largest square side length that fits all cards within `bounds`,
    /// respecting both horizontal and vertical spacing from `flowLayout`.
    func squareSide(
        in bounds: CGSize,
        flowLayout: UICollectionViewFlowLayout
    ) -> CGFloat {
        min(
            maxHeight(in: bounds.height, flowLayout: flowLayout),
            maxWidth(in: bounds.width, flowLayout: flowLayout)
        )
    }

    /// Maximum card height that fits all rows within `availableHeight`.
    func maxHeight(
        in availableHeight: CGFloat,
        flowLayout: UICollectionViewFlowLayout
    ) -> CGFloat {
        let rowCount = CGFloat(rows)
        let spacing = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
            + flowLayout.minimumLineSpacing * (rowCount - 1)
        // `trunc` avoids sub-pixel cell sizes that cause layout rounding artefacts.
        return trunc((availableHeight - spacing) / rowCount)
    }

    /// Maximum card width that fits all columns within `availableWidth`.
    func maxWidth(
        in availableWidth: CGFloat,
        flowLayout: UICollectionViewFlowLayout
    ) -> CGFloat {
        let columnCount = CGFloat(columns)
        let spacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right
            + flowLayout.minimumInteritemSpacing * (columnCount - 1)
        return trunc((availableWidth - spacing) / columnCount)
    }
}
