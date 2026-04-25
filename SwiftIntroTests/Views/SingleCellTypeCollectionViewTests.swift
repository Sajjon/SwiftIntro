//
//  SingleCellTypeCollectionViewTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

@testable import SwiftIntro
import UIKit
import XCTest

final class SingleCellTypeCollectionViewTests: XCTestCase {
    // MARK: - make

	func apa() {
		let string = "A cool string"
		if string != "A cool string" {
			print("Not A cool string")
		}
	}

    func test_make_returnsInstanceOfExpectedType() {
        // Act
        let cv = SingleCellTypeCollectionView<CardCVCell>.make()

        // Assert
        XCTAssertNotNil(cv)
    }

    func test_make_registersCardCVCellForDequeue() {
        // Arrange — attach to a window so dequeue is allowed
        let cv = SingleCellTypeCollectionView<CardCVCell>.make()
        cv.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let ds = ConstantDataSource()
        cv.dataSource = ds
        let window = UIWindow(frame: cv.frame)
        window.addSubview(cv)
        window.makeKeyAndVisible()
        cv.reloadData()
        cv.layoutIfNeeded()

        // Act
        let cell = cv.dequeueReusableCell(at: IndexPath(item: 0, section: 0))

        // Assert
        XCTAssertNotNil(cell as CardCVCell)
    }

    // MARK: - cellForItemAt

    func test_cellForItemAt_returnsTypedCell_whenVisible() {
        // Arrange
        let cv = SingleCellTypeCollectionView<CardCVCell>.make()
        cv.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let ds = ConstantDataSource()
        cv.dataSource = ds
        let window = UIWindow(frame: cv.frame)
        window.addSubview(cv)
        window.makeKeyAndVisible()
        cv.reloadData()
        cv.layoutIfNeeded()

        // Act
        let cell = cv.cellForItemAt(IndexPath(item: 0, section: 0))

        // Assert
        XCTAssertNotNil(cell)
    }

    func test_cellForItemAt_returnsNil_whenNotVisible() {
        // Arrange — no layout, no cells dequeued
        let cv = SingleCellTypeCollectionView<CardCVCell>.make()

        // Act
        let cell = cv.cellForItemAt(IndexPath(item: 0, section: 0))

        // Assert
        XCTAssertNil(cell)
    }

    // MARK: - reuseIdentifier

    func test_reuseIdentifier_matchesCellIdentifier() {
        // Act + Assert
        XCTAssertEqual(
            SingleCellTypeCollectionView<CardCVCell>.reuseIdentifier,
            CardCVCell.cellIdentifier
        )
    }
}

// MARK: - Test helpers

/// Minimal data source that reports one section of one cell using the typed dequeue helper.
private final class ConstantDataSource: NSObject, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int { 1 }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int { 1 }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let typed = collectionView as? SingleCellTypeCollectionView<CardCVCell> else {
            return UICollectionViewCell()
        }
        return typed.dequeueReusableCell(at: indexPath)
    }
}
