//
//  WikimediaClientTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: register a mock HTTPClient, build the WikimediaClient (1–5 lines)
//  - Act:     call getPhotos(_:done:) (1 line)
//  - Assert:  verify a single outcome delivered to the done closure (1 line)
//

import Factory
@testable import SwiftIntro
import XCTest

// MARK: - Mock HTTPClient

private final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var result: Result<Data, Error> = .failure(URLError(.unknown))

    func get(
        url _: URL,
        done: @escaping (Result<Data, Error>) -> Void
    ) {
        done(result)
    }
}

// MARK: - Valid Wikimedia JSON fixture

private let validWikimediaJSON = Data(
    """
    {
      "query": {
        "pages": {
          "1": {
            "imageinfo": [
              { "url": "https://upload.wikimedia.org/a.jpg" }
            ]
          },
          "2": {
            "imageinfo": [
              { "url": "https://upload.wikimedia.org/b.jpg" }
            ]
          }
        }
      }
    }
    """.utf8
)

private let invalidJSON = Data("not json".utf8)

// MARK: - Tests

@MainActor
final class WikimediaClientTests: XCTestCase {
    private let mock = MockHTTPClient()
    private nonisolated(unsafe) var wikimediaClient: WikimediaClient!

    override func setUp() {
        super.setUp()
        // Override the Factory-injected httpClient with the mock for this test.
        let mock = mock
        Container.shared.httpClient.register { mock }
        wikimediaClient = WikimediaClient()
    }

    override func tearDown() {
        Container.shared.httpClient.reset()
        wikimediaClient = nil
        super.tearDown()
    }

    // MARK: - Success

    func test_getPhotos_callsDoneWithCardSinglesOnValidResponse() {
        // Arrange
        mock.result = .success(validWikimediaJSON)
        let exp = expectation(description: "done called")
        nonisolated(unsafe) var receivedSingles: CardSingles?

        // Act
		wikimediaClient.findImages(with: "cats") { result in
            if case let .success(singles) = result { receivedSingles = singles }
            exp.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedSingles)
    }

    func test_getPhotos_parsedSinglesContainExpectedCardCount() {
        // Arrange — fixture contains 2 image pages
        mock.result = .success(validWikimediaJSON)
        let exp = expectation(description: "done called")
        nonisolated(unsafe) var count = 0

        // Act
        wikimediaClient.findImages(with: "cats") { result in
            if case let .success(singles) = result { count = singles.cards.count }
            exp.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(count, 2)
    }

    // MARK: - HTTP failure

    func test_getPhotos_callsDoneWithErrorOnHTTPFailure() {
        // Arrange
        mock.result = .failure(URLError(.notConnectedToInternet))
        let exp = expectation(description: "done called")
        nonisolated(unsafe) var receivedError: Error?

        // Act
        wikimediaClient.findImages(with: "cats") { result in
            if case let .failure(error) = result { receivedError = error }
            exp.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedError)
    }

    // MARK: - JSON decoding failure

    func test_getPhotos_callsDoneWithErrorOnInvalidJSON() {
        // Arrange
        mock.result = .success(invalidJSON)
        let exp = expectation(description: "done called")
        nonisolated(unsafe) var receivedError: Error?

        // Act
        wikimediaClient.findImages(with: "cats") { result in
            if case let .failure(error) = result { receivedError = error }
            exp.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedError)
    }
}
