//
//  LoadingDataVCTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: register stub APIClient + ImageCache, create the VC (1–5 lines)
//  - Act:     access vc.view to trigger viewDidLoad (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

import Factory
@testable import SwiftIntro
import UIKit
import XCTest

// MARK: - Stubs

private final class StubWikimediaClient: WikimediaClientProtocol, @unchecked Sendable {
    var result: Result<CardSingles, Error> = .failure(URLError(.unknown))
    var getPhotosQuery: ((String) -> Void)?

    func getPhotos(
        _ searchQuery: String,
        done: @escaping (Result<CardSingles, Error>) -> Void
    ) {
        getPhotosQuery?(searchQuery)
        done(result)
    }
}

private final class StubImageCache: ImageCacheProtocol, @unchecked Sendable {
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

private final class SpyNavigator: LoadingDataNavigatorProtocol {
    private(set) var navigateToGameCallCount = 0
    private(set) var lastConfig: GameConfiguration?
    private(set) var lastCards: CardDuplicates?
    var onNavigateToGame: (() -> Void)?

    func navigateToGame(
        config: GameConfiguration,
        cards: CardDuplicates
    ) {
        navigateToGameCallCount += 1
        lastConfig = config
        lastCards = cards
        onNavigateToGame?()
    }
}

// MARK: - Helpers

private func makeCards(count: Int) -> CardSingles {
    CardSingles(cards: (0 ..< count).map { Card(imageUrl: URL(string: "https://a.test/\($0).jpg")!) })
}

// MARK: - Tests

@MainActor
final class LoadingDataVCTests: XCTestCase {
    private nonisolated(unsafe) var apiStub: StubWikimediaClient!
    private nonisolated(unsafe) var cacheStub: StubImageCache!

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
    ) -> LoadingDataVC {
        LoadingDataVC(config: GameConfiguration(level: level, searchQuery: query))
    }

    // MARK: - viewDidLoad → fetchData

    func test_viewDidLoad_callsGetPhotos() {
        // Arrange
        let vc = makeVC(query: "dogs")
        var receivedQuery: String?
        apiStub.result = .failure(URLError(.unknown))
        apiStub.getPhotosQuery = { receivedQuery = $0 }

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

        // Act — drain one main-queue cycle so the async main-queue dispatch in fetchData fires
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

        // Act — drain one main-queue cycle so the async main-queue dispatch in fetchData fires
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

        // Act — drain one main-queue cycle so the async main-queue dispatch in fetchData fires
        _ = vc.view
        let exp = expectation(description: "main queue drain")
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1)

        // Assert
        XCTAssertEqual(Set(cacheStub.prefetchedURLs), Set(cards.cards.map(\.imageUrl)))
    }

    // MARK: - startGame → navigator

    func test_startGame_callsNavigatorAfterPrefetch() {
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

    func test_startGame_passesCorrectConfigToNavigator() {
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
        XCTAssertEqual(spy.lastConfig?.level, .easy)
        XCTAssertEqual(spy.lastConfig?.searchQuery, "trees")
    }

    func test_startGame_passesNonEmptyCardsToNavigator() {
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
        XCTAssertNotNil(spy.lastCards)
        XCTAssertFalse(spy.lastCards?.memoryCards.isEmpty ?? true)
    }

    func test_startGame_withNoNavigator_doesNotCrash() {
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

    func test_startGame_onAPIFailure_doesNotCallNavigator() {
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
}
