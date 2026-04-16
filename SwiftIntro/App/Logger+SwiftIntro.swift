//
//  Logger+SwiftIntro.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import OSLog

private let subsystem = Bundle.main.bundleIdentifier ?? "com.swiftintro"

/// Logs app lifecycle events (launch, scene setup). Use for `.notice` app-start milestones.
let logApp = Logger(subsystem: subsystem, category: "App")

/// Logs screen transitions. Use for `.info` pushes/replacements across the navigation stack.
let logNav = Logger(subsystem: subsystem, category: "Navigation")

/// Logs game-logic events (card taps, matches, game over). Use `.notice` for milestones,
/// `.info` for significant state changes, `.debug` for per-event detail.
let logGame = Logger(subsystem: subsystem, category: "Game")

/// Logs networking activity (Wikimedia fetch, image prefetch). Use `.info` for completions,
/// `.debug` for per-request detail, `.error` for failures.
let logNet = Logger(subsystem: subsystem, category: "Network")
