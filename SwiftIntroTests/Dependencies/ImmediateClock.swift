//
//  ImmediateClock.swift
//  SwiftIntroTests
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation
@testable import SwiftIntro

/// Test clock: ignores the requested delay and fires on the next main-queue cycle.
///
/// Register it in `setUp` via `Container.shared.clock.register { ImmediateClock() }`
/// so timer-dependent code under test runs in milliseconds rather than seconds.
final class ImmediateClock: Clock {
    @discardableResult
    func schedule(
        after _: TimeInterval,
        execute block: @escaping () -> Void
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        DispatchQueue.main.async(execute: item)
        return item
    }
}
