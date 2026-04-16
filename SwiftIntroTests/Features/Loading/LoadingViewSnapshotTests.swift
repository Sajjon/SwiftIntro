//
//  LoadingViewSnapshotTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import SnapshotTesting
@testable import SwiftIntro
import XCTest

final class LoadingViewSnapshotTests: XCTestCase {
    private let size = CGSize(width: 393, height: 852)

    func test_loadingView_loadingState() {
        // Arrange — default state shows spinner
        let view = LoadingView()

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }

    func test_loadingView_errorState() {
        // Arrange
        let view = LoadingView()

        // Act
        view.render(.failed(URLError(.notConnectedToInternet)))

        // Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }
}
