//
//  DispatchExtensionTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up inputs and expectations (1–5 lines)
//  - Act:     call the function under test (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

@testable import SwiftIntro
import XCTest

final class DispatchExtensionTests: XCTestCase {
    // MARK: - onMain(_:)

    func test_onMain_executesClosureOnMainThread() {
        // Arrange
        let expectation = expectation(description: "closure runs")
        var isMain = false

        // Act
        onMain {
            isMain = Thread.isMainThread
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertTrue(isMain)
    }

    func test_onMain_closureIsExecuted() {
        // Arrange
        let expectation = expectation(description: "closure runs")
        var didRun = false

        // Act
        onMain {
            didRun = true
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertTrue(didRun)
    }

    // MARK: - onMain(delay:closure:)

    func test_onMain_delay_executesClosureAfterDelay() {
        // Arrange
        let expectation = expectation(description: "delayed closure runs")
        var didRun = false

        // Act
        onMain(delay: 0.001) {
            didRun = true
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertTrue(didRun)
    }

    func test_onMain_delay_closureRunsOnMainThread() {
        // Arrange
        let expectation = expectation(description: "delayed closure runs on main")
        var isMain = false

        // Act
        onMain(delay: 0.001) {
            isMain = Thread.isMainThread
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertTrue(isMain)
    }

    // MARK: - onMain(delay:workItem:)

    func test_onMain_delay_workItem_executesWorkItem() {
        // Arrange
        let expectation = expectation(description: "work item runs")
        var didRun = false
        let workItem = DispatchWorkItem {
            didRun = true
            expectation.fulfill()
        }

        // Act
        onMain(delay: 0.001, workItem: workItem)

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertTrue(didRun)
    }

    func test_onMain_delay_workItem_cancelledItemDoesNotExecute() {
        // Arrange
        var didRun = false
        let workItem = DispatchWorkItem { didRun = true }

        // Act — use a tiny delay so the test completes in < 100 ms
        onMain(delay: 0.001, workItem: workItem)
        workItem.cancel()

        // Assert — wait past the 0.01 s deadline; the cancelled item must not have fired
        let waiter = expectation(description: "wait past delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { waiter.fulfill() }
        waitForExpectations(timeout: 0.5)
        XCTAssertFalse(didRun)
    }
}
