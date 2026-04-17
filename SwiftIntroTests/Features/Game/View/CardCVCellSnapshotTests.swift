//
//  CardCVCellSnapshotTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import SnapshotTesting
@testable import SwiftIntro
import XCTest

final class CardCVCellSnapshotTests: XCTestCase {
    private let cellSize = CGSize(width: 90, height: 120)

    func test_cardCVCell_faceDown() throws {
        // Arrange
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: cellSize))
        let card = try CardModel(card: Card(imageUrl: XCTUnwrap(URL(string: "https://a.test/img.jpg"))))
        cell.configure(with: card)

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: cell, as: .image)
        }
    }

    func test_cardCVCell_afterPrepareForReuse() {
        // Arrange
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: cellSize))

        // Act
        cell.prepareForReuse()

        // Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: cell, as: .image)
        }
    }
}
