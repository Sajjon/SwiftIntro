//
//  SpinLock.swift
//  Swinject
//
//  Created by Yoichi Tagaya on 11/26/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Foundation

internal final class SpinLock {
    fileprivate let lock =  NSLock()
    
    func sync<T>(_ action: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return action()
    }
}
