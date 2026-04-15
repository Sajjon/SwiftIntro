//
//  Clock.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 09/01/16.
//  Copyright © 2016-2026 intranet3. All rights reserved.
//

import Foundation

// MARK: - Clock

/// Abstracts over delayed dispatch so callers can be tested without real-time waits.
///
/// Production code injects `MainQueueClock` (via Factory DI), which schedules work with a
/// real `asyncAfter` delay. Tests register `ImmediateClock`, which ignores the delay and
/// fires on the next main-queue cycle — making timer-dependent tests run in milliseconds.
protocol Clock {
    /// Schedules `block` to run on the main thread after `delay` seconds.
    ///
    /// - Returns: A `DispatchWorkItem` that can be cancelled before it fires.
    @discardableResult
    func schedule(
        after delay: TimeInterval,
        execute block: @escaping () -> Void
    ) -> DispatchWorkItem
}

/// Production `Clock` implementation backed by `DispatchQueue.main.asyncAfter`.
final class MainQueueClock: Clock {
    @discardableResult
    func schedule(
        after delay: TimeInterval,
        execute block: @escaping () -> Void
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
        return item
    }
}
