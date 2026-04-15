//
//  LoadingViewSnapshotTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import SnapshotTesting
@testable import SwiftIntro
import XCTest

@MainActor
final class LoadingViewSnapshotTests: XCTestCase {
    private let size = CGSize(width: 393, height: 852)

    func test_loadingView_defaultAppearance() {
        // Arrange
        let view = LoadingView()

        // Act + Assert
        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: view, as: .image(size: size))
        }
    }
}
