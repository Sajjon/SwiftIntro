//
//  GameViewTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

@testable import SwiftIntro
import UIKit
import XCTest

final class GameViewTests: XCTestCase {
    private func makeCard(_ index: Int) -> Card {
        Card(imageUrl: URL(string: "https://a.test/\(index).jpg")!)
    }

    // MARK: - animateFlip

    func test_animateFlip_visibleCell_doesNotCrash() {
        // Arrange — mount the view in a window so the collection view lays out cells
        let ds = MemoryDataSourceAndDelegate(
            rows: 3,
            columns: 2,
            canSelectCard: { _ in true },
            configureCell: { _, _ in },
            onCardTapped: { _ in }
        )
        let view = GameView(collectionViewDataSource: ds, collectionViewDelegate: ds)
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        let window = UIWindow(frame: view.frame)
        window.addSubview(view)
        window.makeKeyAndVisible()
        view.layoutIfNeeded()

        // Act + Assert — cell is visible, flip path runs without hitting the
        // off-screen guard and the warning log.
        XCTAssertNoThrow(view.animateFlip(at: IndexPath(item: 0, section: 0), isFaceUp: true))
    }

    func test_animateFlip_offScreen_doesNotCrash() {
        // Arrange — no window, no layout, nothing dequeued
        let view = GameView()

        // Act + Assert — guard-let fall-through logs and returns without crashing
        XCTAssertNoThrow(view.animateFlip(at: IndexPath(item: 0, section: 0), isFaceUp: true))
    }
}
