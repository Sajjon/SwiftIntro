//
//  NSObjectExtensionTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up the subject (1–5 lines)
//  - Act:     call the property or method (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import XCTest
@testable import SwiftIntro

final class NSObjectExtensionTests: XCTestCase {

    // MARK: - className

    func test_className_stripsModulePrefix() {
        // Arrange — nothing to set up; className is a class property

        // Act
        let name = NSObjectExtensionTests.className

        // Assert
        XCTAssertEqual(name, "NSObjectExtensionTests")
    }

    func test_className_containsNoModuleSeparator() {
        // Arrange — nothing to set up

        // Act
        let name = NSObjectExtensionTests.className

        // Assert
        XCTAssertFalse(name.contains("."))
    }

    func test_className_usesUnqualifiedTypeName() {
        // Arrange — use a different NSObject subclass to confirm the property is generic

        // Act
        let name = XCTestCase.className

        // Assert
        XCTAssertEqual(name, "XCTestCase")
    }
}
