//
//  CardCVCellTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern.
//
//  Notes on approach:
//  - `cardFrontImageView` and `cardBackImageView` are internal, so they are
//    accessible directly via @testable import.
//  - `isFlipped` is private; its effects are observed through the image views'
//    `isHidden` properties, which the property observer keeps in sync.
//  - Kingfisher's `kf.setImage` is invoked by `configure(with:)` but its
//    network result is not awaited; only the synchronous visibility state is asserted.
//

@testable import SwiftIntro
import UIKit
import XCTest

@MainActor
final class CardCVCellTests: XCTestCase {
    // MARK: - Helpers

    private let cellSize = CGSize(width: 90, height: 120)

    private func makeCell() -> CardCVCell {
        CardCVCell(frame: CGRect(origin: .zero, size: cellSize))
    }

    private func makeCardModel(isFlipped: Bool = false) -> CardModel {
        var card = CardModel(imageUrl: URL(string: "https://a.test/img.jpg")!)
        card.isFlipped = isFlipped
        return card
    }

    // MARK: - init

    func test_init_cardFrontImageViewIsHidden() {
        // Act + Assert
        XCTAssertTrue(makeCell().cardFrontImageView.isHidden)
    }

    func test_init_cardBackImageViewIsVisible() {
        // Act + Assert
        XCTAssertFalse(makeCell().cardBackImageView.isHidden)
    }

    func test_init_cardBackImageViewHasBrownBackground() {
        // Act + Assert
        XCTAssertEqual(makeCell().cardBackImageView.backgroundColor, .brown)
    }

    func test_init_cardFrontImageIsNil() {
        // Act + Assert
        XCTAssertNil(makeCell().cardFrontImageView.image)
    }

    // MARK: - configure — face-down

    func test_configure_faceDownCard_frontIsHidden() {
        // Arrange
        let cell = makeCell()

        // Act
        cell.configure(with: makeCardModel(isFlipped: false))

        // Assert
        XCTAssertTrue(cell.cardFrontImageView.isHidden)
    }

    func test_configure_faceDownCard_backIsVisible() {
        // Arrange
        let cell = makeCell()

        // Act
        cell.configure(with: makeCardModel(isFlipped: false))

        // Assert
        XCTAssertFalse(cell.cardBackImageView.isHidden)
    }

    // MARK: - configure — face-up

    func test_configure_faceUpCard_frontIsVisible() {
        // Arrange
        let cell = makeCell()

        // Act
        cell.configure(with: makeCardModel(isFlipped: true))

        // Assert
        XCTAssertFalse(cell.cardFrontImageView.isHidden)
    }

    func test_configure_faceUpCard_backIsHidden() {
        // Arrange
        let cell = makeCell()

        // Act
        cell.configure(with: makeCardModel(isFlipped: true))

        // Assert
        XCTAssertTrue(cell.cardBackImageView.isHidden)
    }

    // MARK: - prepareForReuse

    func test_prepareForReuse_nilsImage() {
        // Arrange
        let cell = makeCell()
        cell.cardFrontImageView.image = UIImage()

        // Act
        cell.prepareForReuse()

        // Assert
        XCTAssertNil(cell.cardFrontImageView.image)
    }

    func test_prepareForReuse_frontBecomesHidden() {
        // Arrange
        let cell = makeCell()
        cell.configure(with: makeCardModel(isFlipped: true))

        // Act
        cell.prepareForReuse()

        // Assert
        XCTAssertTrue(cell.cardFrontImageView.isHidden)
    }

    func test_prepareForReuse_backBecomesVisible() {
        // Arrange
        let cell = makeCell()
        cell.configure(with: makeCardModel(isFlipped: true))

        // Act
        cell.prepareForReuse()

        // Assert
        XCTAssertFalse(cell.cardBackImageView.isHidden)
    }

    // MARK: - animateFlip

    func test_animateFlip_faceUp_doesNotCrash() {
        // Act + Assert
        XCTAssertNoThrow(makeCell().animateFlip(faceUp: true))
    }

    func test_animateFlip_faceDown_doesNotCrash() {
        // Act + Assert
        XCTAssertNoThrow(makeCell().animateFlip(faceUp: false))
    }

    // MARK: - CellProtocol

    func test_cellIdentifier_isNonEmpty() {
        // Act + Assert
        XCTAssertFalse(CardCVCell.cellIdentifier.isEmpty)
    }

    func test_cellIdentifier_containsClassName() {
        // Act + Assert
        XCTAssertTrue(CardCVCell.cellIdentifier.contains("CardCVCell"))
    }
}
