//
//  CacheTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: register a stub ImageRetrieverProtocol that completes synchronously (1–5 lines)
//  - Act:     call prefetchImages / prefetchImage / imageFromCache (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import Factory
import XCTest
@testable import SwiftIntro

// MARK: - Stub

private final class StubRetriever: ImageRetrieverProtocol {
    /// URLs whose retrieval should be delayed instead of completing immediately.
    var delayedURLs: Set<URL> = []
    /// All URLs that have been requested, in order.
    private(set) var retrievedURLs: [URL] = []

    func retrieveImage(with url: URL, done: @escaping () -> Void) {
        retrievedURLs.append(url)
        if !delayedURLs.contains(url) {
            done()
        }
        // Delayed URLs never call done — simulating a stalled network request.
    }
}

// MARK: - Tests

final class CacheTests: XCTestCase {

    private var stub: StubRetriever!

    override func setUp() {
        super.setUp()
        stub = StubRetriever()
        Container.shared.imageRetriever.register { [unowned self] in self.stub }
    }

    override func tearDown() {
        Container.shared.imageRetriever.reset()
        stub = nil
        super.tearDown()
    }

    // MARK: - imageFromCache

    func test_imageFromCache_returnsNilForUnknownURL() {
        // Arrange
        let cache = Cache()

        // Act
        let image = cache.imageFromCache(URL(string: "https://a.test/unknown.jpg"))

        // Assert — nothing has been loaded yet
        XCTAssertNil(image)
    }

    func test_imageFromCache_returnsNilForNilURL() {
        // Arrange
        let cache = Cache()

        // Act
        let image = cache.imageFromCache(nil)

        // Assert
        XCTAssertNil(image)
    }

    // MARK: - prefetchImages

    func test_prefetchImages_callsDoneAfterAllURLsRetrieved() {
        // Arrange
        let urls = [
            URL(string: "https://a.test/1.jpg")!,
            URL(string: "https://a.test/2.jpg")!,
        ]
        let cache = Cache()
        let exp = expectation(description: "done called")

        // Act
        cache.prefetchImages(urls) { exp.fulfill() }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(stub.retrievedURLs.count, 2)
    }

    func test_prefetchImages_callsDoneForEmptyArray() {
        // Arrange
        let cache = Cache()
        let exp = expectation(description: "done called")

        // Act
        cache.prefetchImages([]) { exp.fulfill() }

        // Assert
        waitForExpectations(timeout: 1)
    }

    func test_prefetchImages_retrievesEachURL() {
        // Arrange
        let urls = [
            URL(string: "https://a.test/a.jpg")!,
            URL(string: "https://a.test/b.jpg")!,
            URL(string: "https://a.test/c.jpg")!,
        ]
        let cache = Cache()
        let exp = expectation(description: "done called")

        // Act
        cache.prefetchImages(urls) { exp.fulfill() }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(Set(stub.retrievedURLs), Set(urls))
    }

    func test_prefetchImages_doesNotCallDoneUntilAllComplete() {
        // Arrange — stall the second URL
        let url1 = URL(string: "https://a.test/1.jpg")!
        let url2 = URL(string: "https://a.test/2.jpg")!
        stub.delayedURLs = [url2]
        let cache = Cache()
        var doneCalled = false

        // Act
        cache.prefetchImages([url1, url2]) { doneCalled = true }

        // Assert — url2 never completed, so done must not have fired
        let waiter = expectation(description: "brief wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { waiter.fulfill() }
        waitForExpectations(timeout: 1)
        XCTAssertFalse(doneCalled)
    }

    func test_prefetchImages_nilDoneDoesNotCrash() {
        // Arrange
        let cache = Cache()

        // Act + Assert
        XCTAssertNoThrow(cache.prefetchImages([URL(string: "https://a.test/1.jpg")!], done: nil))
        // Allow the group.notify to fire before tearDown resets the stub
        let waiter = expectation(description: "drain")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { waiter.fulfill() }
        waitForExpectations(timeout: 1)
    }

    // MARK: - prefetchImage (single URL)

    func test_prefetchImage_callsDoneAfterRetrieval() {
        // Arrange
        let url = URL(string: "https://a.test/single.jpg")!
        let cache = Cache()
        let exp = expectation(description: "done called")

        // Act
        cache.prefetchImage(url) { exp.fulfill() }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(stub.retrievedURLs, [url])
    }
}
