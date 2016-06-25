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


func makeError(error: Error) -> NSError {
    let userInfo = [NSLocalizedFailureReasonErrorKey: error.errorMessage]
    let error = NSError(domain: "SwiftIntro", code: error.rawValue, userInfo: userInfo)
    return error
}

func localizedString(key: String, args: AnyObject...) -> String {
    let localized = NSLocalizedString(key, comment: "")
    guard let parameters = args.first as? [AnyObject], parameter = parameters.first else { return localized }
    var formatted: NSString = ""
    if localized.containsString("%d") {
        guard let number = parameter as? Int else { return localized }
        formatted = NSString(format: localized, number)
    } else if localized.containsString("%@") {
        guard let string = parameter as? String else { return localized }
        formatted = NSString(format: localized, string)
    }
    return formatted as String
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