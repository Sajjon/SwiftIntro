//
//  Macros.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 09/01/16.
//  Copyright © 2016 intranet3. All rights reserved.
//

import Foundation
import UIKit

typealias Closure = () -> Void

func onMain(closure: Closure) {
    dispatch_async(dispatch_get_main_queue()) {
        () -> Void in
        closure()
    }
}

func delay(delay: Double, closure: Closure) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(),
        closure
    )
}

private func showNetworkLoadingInStatusBar(show show: Bool) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = show
}

func showNetworkLoadingInStatusBar() {
    showNetworkLoadingInStatusBar(show: true)
}

func hideNetworkLoadingInStatusBar() {
    showNetworkLoadingInStatusBar(show: false)
}