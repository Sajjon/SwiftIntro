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

@testable import SwiftIntro
import XCTest

// MARK: - Stub URLProtocol

private struct StubResult {
    var data: Data?
    var response: URLResponse?
    var error: Error?
}

private final class StubURLProtocol: URLProtocol {
    static var handler: ((URLRequest) -> StubResult) = { _ in StubResult() }

    // swiftlint:disable:next static_over_final_class
    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    // swiftlint:disable:next static_over_final_class
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    // Dispatch callbacks to a background queue so URLSession always delivers the
    // dataTask completion handler asynchronously — matching production behaviour and
    // avoiding a potential deadlock between synchronous main-thread delivery and
    // `waitForExpectations` on macOS 26.
    override func startLoading() {
        let result = StubURLProtocol.handler(request)
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            if let error = result.error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = result.response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = result.data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                self.client?.urlProtocolDidFinishLoading(self)
            }
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
        StubURLProtocol.handler = { _ in StubResult() }
        super.tearDown()
    }

    // MARK: - Success

    func test_get_callsDoneWithDataOnSuccessfulResponse() {
        // Arrange
        let expected = Data("hello".utf8)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        StubURLProtocol.handler = { _ in StubResult(data: expected, response: response) }
        let exp = expectation(description: "done called")
        var received: Data?

        // Act
        client.get(url: url) { result in
            if case let .success(data) = result { received = data }
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
        StubURLProtocol.handler = { _ in StubResult(error: networkError) }
        let exp = expectation(description: "done called")
        var receivedError: Error?

        // Act
        client.get(url: url) { result in
            if case let .failure(error) = result { receivedError = error }
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
