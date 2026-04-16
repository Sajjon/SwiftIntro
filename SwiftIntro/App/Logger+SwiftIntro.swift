//
//  Logger+SwiftIntro.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import OSLog

/// App-wide `Logger` instance backed by the unified Apple logging system (OSLog).
///
/// Messages are visible in Console.app and in the Xcode debug console.
/// The subsystem is the bundle identifier so logs can be filtered by app in Console.
let log = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.swiftintro",
    category: "SwiftIntro"
)
