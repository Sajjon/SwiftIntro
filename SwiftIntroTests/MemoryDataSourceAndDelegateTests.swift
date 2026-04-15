//
//  MemoryDataSourceAndDelegateTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: build a MemoryDataSourceAndDelegate and a UICollectionView (1–5 lines)
//  - Act:     call the data source / delegate method under test (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

@testable import SwiftIntro
import UIKit
import XCTest

@MainActor
final class MemoryDataSourceAndDelegateTests: XCTestCase {
    // MARK: - Helpers

    private func makeDS(
        rows: Int = 2,
        columns: Int = 3
    ) -> MemoryDataSourceAndDelegate {
        MemoryDataSourceAndDelegate(rows: rows, columns: columns)
    }

    private func makeCV(
        width: CGFloat = 300,
        height: CGFloat = 400
    ) -> (UICollectionView, UICollectionViewFlowLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: width, height: height),
            collectionViewLayout: layout
        )
        cv.register(CardCVCell.self, forCellWithReuseIdentifier: CardCVCell.cellIdentifier)
        return (cv, layout)
    }

    // MARK: - UICollectionViewDataSource

    func test_cellForItemAt_returnsCardCVCell() {
        // Arrange — attach cv + ds to a UIWindow so dequeueReusableCell works
        let ds = makeDS(rows: 2, columns: 3)
        let (cv, _) = makeCV()
        cv.dataSource = ds
        let window = UIWindow(frame: cv.frame)
        window.addSubview(cv)
        window.makeKeyAndVisible()
        cv.reloadData()
        cv.layoutIfNeeded()

        // Act
        let cell = cv.cellForItem(at: IndexPath(item: 0, section: 0))

        // Assert
        XCTAssertTrue(cell is CardCVCell)
    }

    func test_numberOfSections_returnsRowCount() {
        // Arrange
        let ds = makeDS(rows: 3, columns: 4)
        let (cv, _) = makeCV()

        // Act
        let result = ds.numberOfSections(in: cv)

        // Assert
        XCTAssertEqual(result, 3)
    }

    func test_numberOfItemsInSection_returnsColumnCount() {
        // Arrange
        let ds = makeDS(rows: 2, columns: 5)
        let (cv, _) = makeCV()

        // Act
        let result = ds.collectionView(cv, numberOfItemsInSection: 0)

        // Assert
        XCTAssertEqual(result, 5)
    }

    // MARK: - UICollectionViewDelegate — didSelectItemAt

    func test_didSelectItemAt_callsOnCardTapped_whenCanSelect() {
        // Arrange
        let ds = makeDS(rows: 2, columns: 3)
        let (cv, _) = makeCV()
        var tappedIndex: Int?
        ds.canSelectCard = { _ in true }
        ds.onCardTapped = { tappedIndex = $0 }

        // Act — section=0, item=1 → flatIndex = 0*3 + 1 = 1
        ds.collectionView(cv, didSelectItemAt: IndexPath(item: 1, section: 0))

        // Assert
        XCTAssertEqual(tappedIndex, 1)
    }

    func test_didSelectItemAt_doesNotCallOnCardTapped_whenCannotSelect() {
        // Arrange
        let ds = makeDS(rows: 2, columns: 3)
        let (cv, _) = makeCV()
        var tappedIndex: Int?
        ds.canSelectCard = { _ in false }
        ds.onCardTapped = { tappedIndex = $0 }

        // Act
        ds.collectionView(cv, didSelectItemAt: IndexPath(item: 2, section: 1))

        // Assert
        XCTAssertNil(tappedIndex)
    }

    func test_didSelectItemAt_doesNotCallOnCardTapped_whenCanSelectIsNil() {
        // Arrange
        let ds = makeDS(rows: 2, columns: 3)
        let (cv, _) = makeCV()
        var tappedIndex: Int?
        // canSelectCard deliberately not set
        ds.onCardTapped = { tappedIndex = $0 }

        // Act
        ds.collectionView(cv, didSelectItemAt: IndexPath(item: 0, section: 0))

        // Assert
        XCTAssertNil(tappedIndex)
    }

    func test_didSelectItemAt_flatIndexIsCorrect() {
        // Arrange — rows=3, columns=4 → section=2, item=3 → flatIndex = 2*4+3 = 11
        let ds = makeDS(rows: 3, columns: 4)
        let (cv, _) = makeCV()
        var tappedIndex: Int?
        ds.canSelectCard = { _ in true }
        ds.onCardTapped = { tappedIndex = $0 }

        // Act
        ds.collectionView(cv, didSelectItemAt: IndexPath(item: 3, section: 2))

        // Assert
        XCTAssertEqual(tappedIndex, 11)
    }

    // MARK: - UICollectionViewDelegate — willDisplay

    func test_willDisplay_callsConfigureCell_withCorrectIndex() {
        // Arrange — section=0, item=2 → flatIndex = 0*3+2 = 2
        let ds = makeDS(rows: 2, columns: 3)
        let (cv, _) = makeCV()
        var configuredIndex: Int?
        ds.configureCell = { _, index in configuredIndex = index }
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))

        // Act
        ds.collectionView(cv, willDisplay: cell, forItemAt: IndexPath(item: 2, section: 0))

        // Assert
        XCTAssertEqual(configuredIndex, 2)
    }

    func test_willDisplay_doesNotCallConfigureCell_forNonCardCVCell() {
        // Arrange
        let ds = makeDS()
        let (cv, _) = makeCV()
        var configuredIndex: Int?
        ds.configureCell = { _, index in configuredIndex = index }
        let cell = UICollectionViewCell() // not a CardCVCell

        // Act
        ds.collectionView(cv, willDisplay: cell, forItemAt: IndexPath(item: 0, section: 0))

        // Assert
        XCTAssertNil(configuredIndex)
    }

    func test_willDisplay_flatIndexIsCorrect() {
        // Arrange — rows=2, columns=3 → section=1, item=2 → flatIndex = 1*3+2 = 5
        let ds = makeDS(rows: 2, columns: 3)
        let (cv, _) = makeCV()
        var configuredIndex: Int?
        ds.configureCell = { _, index in configuredIndex = index }
        let cell = CardCVCell(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 100)))

        // Act
        ds.collectionView(cv, willDisplay: cell, forItemAt: IndexPath(item: 2, section: 1))

        // Assert
        XCTAssertEqual(configuredIndex, 5)
    }

    // MARK: - UICollectionViewDelegateFlowLayout — insetForSectionAt

    func test_insetForSection_returnsBottomEqualToLineSpacing() {
        // Arrange
        let ds = makeDS()
        let (cv, layout) = makeCV()
        layout.minimumLineSpacing = 12

        // Act
        let insets = ds.collectionView(cv, layout: layout, insetForSectionAt: 0)

        // Assert
        XCTAssertEqual(insets, UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
    }

    func test_insetForSection_returnsZeroForNonFlowLayout() {
        // Arrange
        let ds = makeDS()
        let nonFlowLayout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: nonFlowLayout)

        // Act
        let insets = ds.collectionView(cv, layout: nonFlowLayout, insetForSectionAt: 0)

        // Assert
        XCTAssertEqual(insets, .zero)
    }

    // MARK: - UICollectionViewDelegateFlowLayout — sizeForItemAt

    func test_sizeForItemAt_returnsSquareSize() {
        // Arrange
        let ds = makeDS(rows: 2, columns: 3)
        let (cv, layout) = makeCV()

        // Act
        let size = ds.collectionView(cv, layout: layout, sizeForItemAt: IndexPath(item: 0, section: 0))

        // Assert — card cells must always be square
        XCTAssertEqual(size.width, size.height)
    }

    func test_sizeForItemAt_returnsNonZeroSize() {
        // Arrange
        let ds = makeDS(rows: 2, columns: 3)
        let (cv, layout) = makeCV()

        // Act
        let size = ds.collectionView(cv, layout: layout, sizeForItemAt: IndexPath(item: 0, section: 0))

        // Assert
        XCTAssertGreaterThan(size.width, 0)
    }

    func test_sizeForItemAt_returnsZeroForNonFlowLayout() {
        // Arrange
        let ds = makeDS()
        let nonFlowLayout = UICollectionViewLayout()
        let cv = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 300, height: 400),
            collectionViewLayout: nonFlowLayout
        )

        // Act
        let size = ds.collectionView(cv, layout: nonFlowLayout, sizeForItemAt: IndexPath(item: 0, section: 0))

        // Assert
        XCTAssertEqual(size, .zero)
    }
}
