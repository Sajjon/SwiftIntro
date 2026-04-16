//
//  WikimediaRouterTests.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//
//  All tests follow the Arrange-Act-Assert (AAA) pattern:
//  - Arrange: set up the route and any helpers (1–5 lines)
//  - Act:     compute the URL (1 line)
//  - Assert:  verify a single observable outcome (1 line)
//

@testable import SwiftIntro
import XCTest

final class WikimediaRouterTests: XCTestCase {
    // MARK: - Helpers

    /// Extracts query items from a `URL` as a `[name: value]` dictionary.
    private func queryItems(for url: URL) -> [String: String] {
        guard let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: items.compactMap { item in
            item.value.map { (item.name, $0) }
        })
    }

    // MARK: - Base URL

    func test_searchImages_url_schemeIsHttps() {
        // Arrange
        let route = WikimediaRouter.searchImages("cats")

        // Act
        let scheme = route.url.scheme

        // Assert
        XCTAssertEqual(scheme, "https")
    }

    func test_searchImages_url_hostIsWikimediaCommons() {
        // Arrange
        let route = WikimediaRouter.searchImages("cats")

        // Act
        let host = route.url.host

        // Assert
        XCTAssertEqual(host, "commons.wikimedia.org")
    }

    func test_searchImages_url_pathIsApiPhp() {
        // Arrange
        let route = WikimediaRouter.searchImages("cats")

        // Act
        let path = route.url.path

        // Assert
        XCTAssertEqual(path, "/w/api.php")
    }

    // MARK: - Query parameters

    func test_searchImages_url_actionIsQuery() {
        // Arrange
        let url = WikimediaRouter.searchImages("dogs").url

        // Act
        let action = queryItems(for: url)["action"]

        // Assert
        XCTAssertEqual(action, "query")
    }

    func test_searchImages_url_generatorIsSearch() {
        // Arrange
        let url = WikimediaRouter.searchImages("dogs").url

        // Act
        let generator = queryItems(for: url)["generator"]

        // Assert
        XCTAssertEqual(generator, "search")
    }

    func test_searchImages_url_gsrsearchMatchesQuery() {
        // Arrange
        let url = WikimediaRouter.searchImages("swift programming").url

        // Act
        let gsrsearch = queryItems(for: url)["gsrsearch"]

        // Assert
        XCTAssertEqual(gsrsearch, "swift programming")
    }

    func test_searchImages_url_gsrnamespaceIsFileNamespace() {
        // Arrange — namespace 6 = "File:", restricts results to media files
        let url = WikimediaRouter.searchImages("dogs").url

        // Act
        let namespace = queryItems(for: url)["gsrnamespace"]

        // Assert
        XCTAssertEqual(namespace, "6")
    }

    func test_searchImages_url_propIsImageinfo() {
        // Arrange
        let url = WikimediaRouter.searchImages("dogs").url

        // Act
        let prop = queryItems(for: url)["prop"]

        // Assert
        XCTAssertEqual(prop, "imageinfo")
    }

    func test_searchImages_url_iipropIsUrl() {
        // Arrange
        let url = WikimediaRouter.searchImages("dogs").url

        // Act
        let iiprop = queryItems(for: url)["iiprop"]

        // Assert
        XCTAssertEqual(iiprop, "url")
    }

    func test_searchImages_url_formatIsJson() {
        // Arrange
        let url = WikimediaRouter.searchImages("dogs").url

        // Act
        let format = queryItems(for: url)["format"]

        // Assert
        XCTAssertEqual(format, "json")
    }

    func test_searchImages_url_gsrlimitIs50() {
        // Arrange
        let url = WikimediaRouter.searchImages("dogs").url

        // Act
        let limit = queryItems(for: url)["gsrlimit"]

        // Assert
        XCTAssertEqual(limit, "50")
    }

    // MARK: - Percent encoding

    func test_searchImages_url_percentEncodesSpaces() {
        // Arrange
        let url = WikimediaRouter.searchImages("space cats").url

        // Act
        let absoluteString = url.absoluteString

        // Assert — URLComponents encodes spaces as %20 or +
        let isEncoded = absoluteString.contains("space%20cats") || absoluteString.contains("space+cats")
        XCTAssertTrue(isEncoded, "Spaces in the search query must be percent-encoded")
    }

    func test_searchImages_url_doesNotCrashOnSpecialCharacters() {
        // Arrange
        let route = WikimediaRouter.searchImages("café & art")

        // Act + Assert — must not crash
        XCTAssertNotNil(route.url)
    }
}
