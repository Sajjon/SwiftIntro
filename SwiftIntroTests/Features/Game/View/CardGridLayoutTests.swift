//
//  CardGridLayoutTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

@testable import SwiftIntro
import UIKit
import XCTest

final class CardGridLayoutTests: XCTestCase {
    private func makeFlow(
        lineSpacing: CGFloat = 8,
        itemSpacing: CGFloat = 8,
        insets: UIEdgeInsets = .zero
    ) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = itemSpacing
        layout.sectionInset = insets
        return layout
    }

    // MARK: - squareSide

    func test_squareSide_withSquareBounds_returnsSameForWidthAndHeight() {
        // Arrange — 3 rows × 3 columns, square bounds, zero spacing
        let layout = CardGridLayout(rows: 3, columns: 3)
        let flow = makeFlow(lineSpacing: 0, itemSpacing: 0)

        // Act
        let side = layout.squareSide(in: CGSize(width: 300, height: 300), flowLayout: flow)

        // Assert
        XCTAssertEqual(side, 100)
    }

    func test_squareSide_widerThanTall_limitsByHeight() {
        // Arrange — 2 rows × 5 columns; wider space but only 2 rows
        let layout = CardGridLayout(rows: 2, columns: 5)
        let flow = makeFlow(lineSpacing: 0, itemSpacing: 0)

        // Act
        let side = layout.squareSide(in: CGSize(width: 1000, height: 200), flowLayout: flow)

        // Assert — height / 2 = 100 is the limit
        XCTAssertEqual(side, 100)
    }

    func test_squareSide_subtractsSpacing() {
        // Arrange — 2 rows × 2 columns with 10-pt gaps
        let layout = CardGridLayout(rows: 2, columns: 2)
        let flow = makeFlow(lineSpacing: 10, itemSpacing: 10)

        // Act — (200 - 10) / 2 = 95
        let side = layout.squareSide(in: CGSize(width: 200, height: 200), flowLayout: flow)

        // Assert
        XCTAssertEqual(side, 95)
    }

    func test_squareSide_truncatesSubPixelValues() {
        // Arrange — 3 rows, height 100 / 3 = 33.33 → trunc = 33
        let layout = CardGridLayout(rows: 3, columns: 3)
        let flow = makeFlow(lineSpacing: 0, itemSpacing: 0)

        // Act
        let side = layout.squareSide(in: CGSize(width: 100, height: 100), flowLayout: flow)

        // Assert
        XCTAssertEqual(side, 33)
    }
}
