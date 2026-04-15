//
//  UIViewExtensionTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up the view under test (1–5 lines)
//  - Act:     call the property (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

@testable import SwiftIntro
import XCTest

@MainActor
final class UIViewExtensionTests: XCTestCase {
    // MARK: - isVisible getter

    func test_isVisible_returnsTrueWhenNotHidden() {
        // Arrange
        let view = UIView()
        view.isHidden = false

        // Act
        let result = view.isVisible

        // Assert
        XCTAssertTrue(result)
    }

    func test_isVisible_returnsFalseWhenHidden() {
        // Arrange
        let view = UIView()
        view.isHidden = true

        // Act
        let result = view.isVisible

        // Assert
        XCTAssertFalse(result)
    }

    // MARK: - isVisible setter

    func test_isVisible_setterTrue_setsIsHiddenFalse() {
        // Arrange
        let view = UIView()
        view.isHidden = true

        // Act
        view.isVisible = true

        // Assert
        XCTAssertFalse(view.isHidden)
    }

    func test_isVisible_setterFalse_setsIsHiddenTrue() {
        // Arrange
        let view = UIView()
        view.isHidden = false

        // Act
        view.isVisible = false

        // Assert
        XCTAssertTrue(view.isHidden)
    }
}
