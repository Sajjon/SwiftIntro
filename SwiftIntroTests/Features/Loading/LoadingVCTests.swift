//
//  LoadingVCTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  Integration tests for `LoadingVC` → `LoadingViewModel` → async side-effects.
//  These tests verify that the wiring between the VC and view model
//  produces the correct observable outcomes.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: register stub dependencies, create the VC (1–5 lines)
//  - Act:     access `vc.view` to trigger `viewDidLoad` (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import Factory
@testable import SwiftIntro
import UIKit
import XCTest

// MARK: - Stubs

private final class StubWikimediaClient: WikimediaClientProtocol {
    var result: Result<CardSingles, Error> = .failure(URLError(.unknown))
    var findImagesQuery: ((String) -> Void)?

    func findImages(
        with searchQuery: String,
        done: @escaping (Result<CardSingles, Swift.Error>) -> Void
    ) {
        findImagesQuery?(searchQuery)
        done(result)
    }
}

private final class StubImageCache: ImageCacheProtocol {
    private(set) var prefetchedURLs: [URL] = []

    func prefetchImages(
        _ urls: [URL],
        done: Closure?
    ) {
        prefetchedURLs.append(contentsOf: urls)
        done?()
    }

    func prefetchImage(
        _ url: URL,
        done: Closure?
    ) {
        prefetchImages([url], done: done)
    }

    func imageFromCache(_: URL?) -> UIImage? {
        nil
    }
}

private final class SpyNavigator: LoadingNavigatorProtocol {
    private(set) var navigateToGameCallCount = 0
    private(set) var lastGame: AnyPreparedGame?
    var onNavigateToGame: (() -> Void)?

    func navigateToGame(_ game: AnyPreparedGame) {
        navigateToGameCallCount += 1
        lastGame = game
        onNavigateToGame?()
    }
}

// MARK: - Helpers

private func makeCards(count: Int) -> CardSingles {
    CardSingles(cards: (0 ..< count).map { Card(imageUrl: URL(string: "https://a.test/\($0).jpg")!) })
}

// MARK: - Tests

final class LoadingVCTests: XCTestCase {
    private var apiStub: StubWikimediaClient!
    private var cacheStub: StubImageCache!

    override func setUp() {
        super.setUp()
        apiStub = StubWikimediaClient()
        cacheStub = StubImageCache()
        let apiStub = apiStub!
        let cacheStub = cacheStub!
        Container.shared.wikimediaClient.register { apiStub }
        Container.shared.imageCache.register { cacheStub }
    }

    override func tearDown() {
        Container.shared.wikimediaClient.reset()
        Container.shared.imageCache.reset()
        apiStub = nil
        cacheStub = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeVC(
        level: Level = .easy,
        query: String = "cats"
    ) -> LoadingVC {
        LoadingVC(config: GameConfiguration(level: level, searchQuery: query))
    }

    // MARK: - viewDidLoad → fetchData

    func test_viewDidLoad_callsFindImages() {
        // Arrange
        let vc = makeVC(query: "dogs")
        var receivedQuery: String?
        apiStub.result = .failure(URLError(.unknown))
        apiStub.findImagesQuery = { receivedQuery = $0 }

        // Act
        _ = vc.view

        // Assert
        XCTAssertEqual(receivedQuery, "dogs")
    }

    func test_viewDidLoad_onAPIFailure_doesNotCrash() {
        // Arrange
        let vc = makeVC()
        apiStub.result = .failure(URLError(.notConnectedToInternet))

        // Act + Assert
        XCTAssertNoThrow({ _ = vc.view }())
    }

    func test_viewDidLoad_onAPISuccess_prefetchesImageURLs() {
        // Arrange
        let cards = makeCards(count: 3)
        apiStub.result = .success(cards)
        let vc = makeVC()

        // Act — drain one main-queue cycle so the async dispatch in LoadingViewModel fires
        _ = vc.view
        let exp = expectation(description: "main queue drain")
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1)

        // Assert
        XCTAssertFalse(cacheStub.prefetchedURLs.isEmpty)
    }

    func test_viewDidLoad_onAPISuccess_prefetchesCorrectURLCount() {
        // Arrange — 3 unique cards → 3 URLs prefetched
        let cards = makeCards(count: 3)
        apiStub.result = .success(cards)
        let vc = makeVC()

        // Act
        _ = vc.view
        let exp = expectation(description: "main queue drain")
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1)

        // Assert
        XCTAssertEqual(cacheStub.prefetchedURLs.count, cards.cards.count)
    }

    func test_viewDidLoad_onAPISuccess_prefetchesCorrectURLs() {
        // Arrange
        let cards = makeCards(count: 3)
        apiStub.result = .success(cards)
        let vc = makeVC()

        // Act
        _ = vc.view
        let exp = expectation(description: "main queue drain")
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1)

        // Assert
        XCTAssertEqual(Set(cacheStub.prefetchedURLs), Set(cards.cards.map(\.imageUrl)))
    }

    // MARK: - navigateToGame → navigator

    func test_navigateToGame_callsNavigatorAfterPrefetch() {
        // Arrange
        let cards = makeCards(count: 3)
        apiStub.result = .success(cards)
        let vc = makeVC(level: .easy)
        let spy = SpyNavigator()
        vc.navigator = spy
        let exp = expectation(description: "navigateToGame called")
        spy.onNavigateToGame = { exp.fulfill() }

        // Act
        _ = vc.view

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(spy.navigateToGameCallCount, 1)
    }

    func test_navigateToGame_passesCorrectConfigToNavigator() {
        // Arrange
        let cards = makeCards(count: 3)
        apiStub.result = .success(cards)
        let vc = makeVC(level: .easy, query: "trees")
        let spy = SpyNavigator()
        vc.navigator = spy
        let exp = expectation(description: "navigateToGame called")
        spy.onNavigateToGame = { exp.fulfill() }

        // Act
        _ = vc.view

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(spy.lastGame?.config.level, .easy)
        XCTAssertEqual(spy.lastGame?.config.searchQuery, "trees")
    }

    func test_navigateToGame_passesNonEmptyCardsToNavigator() {
        // Arrange
        let cards = makeCards(count: 3)
        apiStub.result = .success(cards)
        let vc = makeVC(level: .easy)
        let spy = SpyNavigator()
        vc.navigator = spy
        let exp = expectation(description: "navigateToGame called")
        spy.onNavigateToGame = { exp.fulfill() }

        // Act
        _ = vc.view

        // Assert — easy level carries a 6-card deck; the wrapper exposes its count.
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(spy.lastGame)
        XCTAssertGreaterThan(spy.lastGame?.cardCount ?? 0, 0)
    }

    func test_navigateToGame_withNoNavigator_doesNotCrash() {
        // Arrange — navigator intentionally not set
        let cards = makeCards(count: 3)
        apiStub.result = .success(cards)
        let vc = makeVC()

        // Act + Assert
        let exp = expectation(description: "main queue drain")
        exp.assertForOverFulfill = false
        _ = vc.view
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1)
    }

    func test_navigateToGame_onAPIFailure_doesNotCallNavigator() {
        // Arrange
        apiStub.result = .failure(URLError(.unknown))
        let vc = makeVC()
        let spy = SpyNavigator()
        vc.navigator = spy

        // Act
        _ = vc.view
        let waiter = expectation(description: "main queue drain")
        DispatchQueue.main.async { waiter.fulfill() }
        waitForExpectations(timeout: 1)

        // Assert
        XCTAssertEqual(spy.navigateToGameCallCount, 0)
    }

    // MARK: - retry

    func test_retry_afterFailure_callsFindImagesAgain() {
        // Arrange — first call fails, second call succeeds
        apiStub.result = .failure(URLError(.unknown))
        let vc = makeVC(query: "cats")
        var queryCount = 0
        apiStub.findImagesQuery = { _ in queryCount += 1 }
        _ = vc.view

        // Drain first fetch (fails)
        let firstDrain = expectation(description: "first drain")
        DispatchQueue.main.async { firstDrain.fulfill() }
        waitForExpectations(timeout: 1)

        // Now switch to success so the retry navigates
        apiStub.result = .success(makeCards(count: 3))
        let spy = SpyNavigator()
        vc.navigator = spy
        let navExp = expectation(description: "navigateToGame after retry")
        spy.onNavigateToGame = { navExp.fulfill() }

        // Act — simulate the retry button tap via onRetry on the LoadingView
        // swiftlint:disable:next force_cast
        (vc.view as! LoadingView).onRetry?()

        // Assert
        waitForExpectations(timeout: 1)
        XCTAssertEqual(spy.navigateToGameCallCount, 1)
    }
}
