//
//  Dispatch+Extensions.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 09/01/16.
//  Copyright © 2016-2026 intranet3. All rights reserved.
//

import Foundation
import UIKit

/// A zero-argument, no-return closure — used throughout the app for completion callbacks
/// and button-action handlers where no parameters need to be passed.
typealias Closure = () -> Void

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

/// Dispatches `closure` asynchronously on the main queue.
///
/// Use this whenever you need to update UI from a background callback.
func onMain(_ closure: @escaping Closure) {
    DispatchQueue.main.async(execute: closure)
}

/// Dispatches a pre-built `DispatchWorkItem` on the main queue after `delay` seconds.
///
/// The work item can be cancelled before the delay expires by calling `workItem.cancel()`.
func onMain(
    delay: Double,
    workItem: DispatchWorkItem
) {
    onMain(delay: delay) {
        workItem.perform()
    }
}

/// Dispatches `closure` on the main queue after `delay` seconds.
///
/// - Parameters:
///   - delay: Seconds to wait before executing the closure.
///   - closure: The work to perform on the main thread.
func onMain(
    delay: Double,
    closure: @escaping Closure
) {
    // Convert the delay to nanoseconds and back to avoid floating-point precision
    // issues when computing the `DispatchTime` deadline.
    let delay = Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    let deadline = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(
        deadline: deadline,
        execute: closure
    )
}
