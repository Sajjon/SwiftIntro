//
//  LoadingViewModelTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
@testable import SwiftIntro
import UIKit
import XCTest

// MARK: - Stubs

private final class StubWikimediaClient: WikimediaClientProtocol {
    var result: Result<CardSingles, Error> = .failure(URLError(.unknown))

    func findImages(
        with _: String,
        done: @escaping (Result<CardSingles, Swift.Error>) -> Void
    ) {
        done(result)
    }
}

private final class StubImageCache: ImageCacheProtocol {
    func prefetchImages(
        _: [URL],
        done: Closure?
    ) {
        done?()
    }
}

// MARK: - Tests

final class LoadingViewModelTests: XCTestCase {
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

    private func makeCards(count: Int) -> CardSingles {
        CardSingles(cards: (0 ..< count).map { Card(imageUrl: URL(string: "https://a.test/\($0).jpg")!) })
    }

    // MARK: - Phase.description

    func test_phaseDescription_loading_isLoading() {
        // Act + Assert
        XCTAssertEqual(String(describing: LoadingViewModel.Phase.loading), "Loading")
    }

    func test_phaseDescription_failed_containsFailedPrefix() {
        // Act
        let description = String(describing: LoadingViewModel.Phase.failed(URLError(.unknown)))

        // Assert
        XCTAssertTrue(description.hasPrefix("Failed:"))
    }

    // MARK: - stop

    func test_stop_clearsCallbacks_navigationDoesNotFire() {
        // Arrange — delay the prefetch completion so stop() runs before it fires
        final class DelayingCache: ImageCacheProtocol {
            var pending: Closure?
            func prefetchImages(
                _: [URL],
                done: Closure?
            ) { pending = done }
        }
        let delaying = DelayingCache()
        Container.shared.imageCache.register { delaying }
        apiStub.result = .success(makeCards(count: 3))
        let vm = LoadingViewModel(config: GameConfiguration(level: .easy))
        var navigateCount = 0
        vm.start(
            onPhaseChange: { _ in },
            onNavigateToGame: { _ in navigateCount += 1 }
        )
        // Drain the async dispatch so handleFetchSuccess runs and pending is set.
        let drain = expectation(description: "drain")
        DispatchQueue.main.async { drain.fulfill() }
        waitForExpectations(timeout: 1)

        // Act — stop clears the callback; firing the pending prefetch hits the
        // nil-navigation branch instead of notifying.
        vm.stop()
        delaying.pending?()

        // Assert
        XCTAssertEqual(navigateCount, 0)
    }

    // MARK: - retry

    func test_retry_callsFindImagesAgain() {
        // Arrange
        apiStub.result = .failure(URLError(.unknown))
        let vm = LoadingViewModel(config: GameConfiguration(level: .easy))
        vm.start(onPhaseChange: { _ in }, onNavigateToGame: { _ in })

        // Drain the first failing fetch
        let firstDrain = expectation(description: "first drain")
        DispatchQueue.main.async { firstDrain.fulfill() }
        waitForExpectations(timeout: 1)

        // Act — flip to success and retry
        apiStub.result = .success(makeCards(count: 3))
        let navExp = expectation(description: "navigate after retry")
        vm.onNavigateToGame = { _ in navExp.fulfill() }
        vm.retry()

        // Assert
        waitForExpectations(timeout: 1)
    }
}
