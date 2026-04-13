//
//  Macros.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 09/01/16.
//  Copyright © 2016-2026 intranet3. All rights reserved.
//

import Foundation
import UIKit

typealias Closure = () -> Void

func onMain(_ closure: @escaping Closure) {
    DispatchQueue.main.async {
        () -> Void in
        closure()
    }
}

func delay(_ delay: Double, closure: @escaping Closure) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}

@available(iOS, deprecated: 13.0, message: "Status bar network activity indicator is deprecated. Consider showing a custom in-app loading UI.")
private func showNetworkLoadingInStatusBar(show: Bool) {
    // Deprecated no-op: The system status bar network activity indicator was removed in iOS 13.
    // Keep this function as a stub to avoid breaking existing call sites.
    // If needed, implement your own in-app network activity UI and call it from here.
}

@available(iOS, deprecated: 13.0, message: "Use a custom in-app loading indicator instead of the status bar network activity indicator.")
func showNetworkLoadingInStatusBar() {
    showNetworkLoadingInStatusBar(show: true)
}

@available(iOS, deprecated: 13.0, message: "Use a custom in-app loading indicator instead of the status bar network activity indicator.")
func hideNetworkLoadingInStatusBar() {
    showNetworkLoadingInStatusBar(show: false)
}
