//
//  ImageCacheTests.swift
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
@testable import SwiftIntro
import XCTest

// MARK: - Stub

private final class StubRetriever: ImageFetcherProtocol, @unchecked Sendable {
    /// URLs whose retrieval should be delayed instead of completing immediately.
    var delayedURLs: Set<URL> = []
    /// All URLs that have been requested, in order.
    private(set) var retrievedURLs: [URL] = []

    func fetchImage(
        with url: URL,
        done: @escaping @Sendable () -> Void
    ) {
        retrievedURLs.append(url)
        if !delayedURLs.contains(url) {
            done()
        }
        // Delayed URLs never call done — simulating a stalled network request.
    }
}

// MARK: - Tests

@MainActor
final class CacheTests: XCTestCase {
    private nonisolated(unsafe) var stub: StubRetriever!

    override func setUp() {
        super.setUp()
        stub = StubRetriever()
        let stub = stub!
        Container.shared.imageRetriever.register { stub }
    }

    override func tearDown() {
        Container.shared.imageRetriever.reset()
        stub = nil
        super.tearDown()
    }

    // MARK: - imageFromCache

    func test_imageFromCache_returnsNilForUnknownURL() {
        // Arrange
        let cache = ImageCache()

        // Act
        let image = cache.imageFromCache(URL(string: "https://a.test/unknown.jpg"))

        // Assert — nothing has been loaded yet
        XCTAssertNil(image)
    }

    func test_imageFromCache_returnsNilForNilURL() {
        // Arrange
        let cache = ImageCache()

        // Act
        let image = cache.imageFromCache(nil)

        // Assert
        XCTAssertNil(image)
    }

    // MARK: - prefetchImages

    func test_prefetchImages_callsDoneAfterAllURLsRetrieved() throws {
        // Arrange
        let urls = try [
            XCTUnwrap(URL(string: "https://a.test/1.jpg")),
            XCTUnwrap(URL(string: "https://a.test/2.jpg")),
        ]
        let cache = ImageCache()
        let exp = expectation(description: "done called")

        // Act
        cache.prefetchImages(urls) { exp.fulfill() }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(stub.retrievedURLs.count, 2)
    }

    func test_prefetchImages_callsDoneForEmptyArray() {
        // Arrange
        let cache = ImageCache()
        let exp = expectation(description: "done called")

        // Act
        cache.prefetchImages([]) { exp.fulfill() }

        // Assert
        waitForExpectations(timeout: 1)
    }

    func test_prefetchImages_retrievesEachURL() throws {
        // Arrange
        let urls = try [
            XCTUnwrap(URL(string: "https://a.test/a.jpg")),
            XCTUnwrap(URL(string: "https://a.test/b.jpg")),
            XCTUnwrap(URL(string: "https://a.test/c.jpg")),
        ]
        let cache = ImageCache()
        let exp = expectation(description: "done called")

        // Act
        cache.prefetchImages(urls) { exp.fulfill() }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(Set(stub.retrievedURLs), Set(urls))
    }

    func test_prefetchImages_doesNotCallDoneUntilAllComplete() throws {
        // Arrange — stall the second URL; done must NOT fire
        let url1 = try XCTUnwrap(URL(string: "https://a.test/1.jpg"))
        let url2 = try XCTUnwrap(URL(string: "https://a.test/2.jpg"))
        stub.delayedURLs = [url2]
        let cache = ImageCache()
        let doneNotExpected = expectation(description: "done must not be called")
        doneNotExpected.isInverted = true

        // Act
        cache.prefetchImages([url1, url2]) { doneNotExpected.fulfill() }

        // Assert — inverted expectation fails (test fails) if done fires within the timeout
        waitForExpectations(timeout: 0.5)
    }

    func test_prefetchImages_nilDoneDoesNotCrash() throws {
        // Arrange
        let cache = ImageCache()

        // Act + Assert
        XCTAssertNoThrow(try cache.prefetchImages([XCTUnwrap(URL(string: "https://a.test/1.jpg"))], done: nil))
        // Allow the group.notify to fire before tearDown resets the stub
        let waiter = expectation(description: "main queue drain")
        DispatchQueue.main.async { waiter.fulfill() }
        waitForExpectations(timeout: 0.5)
    }

    // MARK: - prefetchImage (single URL)

    func test_prefetchImage_callsDoneAfterRetrieval() throws {
        // Arrange
        let url = try XCTUnwrap(URL(string: "https://a.test/single.jpg"))
        let cache = ImageCache()
        let exp = expectation(description: "done called")

        // Act
        cache.prefetchImage(url) { exp.fulfill() }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(stub.retrievedURLs, [url])
    }
}
