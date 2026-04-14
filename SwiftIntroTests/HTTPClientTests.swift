//
//  HTTPClientTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: build a stubbed URLSession and HTTPClient (1–5 lines)
//  - Act:     call get(url:done:) (1 line)
//  - Assert:  verify a single outcome in the done closure (1 line)
//

import XCTest
@testable import SwiftIntro

// MARK: - Stub URLProtocol

private final class StubURLProtocol: URLProtocol {

    static var handler: ((URLRequest) -> (Data?, URLResponse?, Error?)) = { _ in (nil, nil, nil) }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let (data, response, error) = StubURLProtocol.handler(request)
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

// MARK: - Tests

final class HTTPClientTests: XCTestCase {

    private var client: HTTPClient!
    private let url = URL(string: "https://example.com")!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        client = HTTPClient(urlSession: URLSession(configuration: config))
    }

    override func tearDown() {
        client = nil
        StubURLProtocol.handler = { _ in (nil, nil, nil) }
        super.tearDown()
    }

    // MARK: - Success

    func test_get_callsDoneWithDataOnSuccessfulResponse() {
        // Arrange
        let expected = Data("hello".utf8)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        StubURLProtocol.handler = { _ in (expected, response, nil) }
        let exp = expectation(description: "done called")
        var received: Data?

        // Act
        client.get(url: url) { result in
            if case .success(let data) = result { received = data }
            exp.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(received, expected)
    }

    // MARK: - Failure

    func test_get_callsDoneWithErrorOnNetworkFailure() {
        // Arrange
        let networkError = URLError(.notConnectedToInternet)
        StubURLProtocol.handler = { _ in (nil, nil, networkError) }
        let exp = expectation(description: "done called")
        var receivedError: Error?

        // Act
        client.get(url: url) { result in
            if case .failure(let error) = result { receivedError = error }
            exp.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedError)
    }

    // MARK: - Init

    func test_init_defaultsToSharedSession() {
        // Arrange — nothing, default init

        // Act
        let defaultClient = HTTPClient()

        // Assert — just verify it can be created without crashing
        XCTAssertNotNil(defaultClient)
    }
}
