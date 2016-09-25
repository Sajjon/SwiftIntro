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

private func showNetworkLoadingInStatusBar(show: Bool) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = show
}

func showNetworkLoadingInStatusBar() {
    showNetworkLoadingInStatusBar(show: true)
}

func hideNetworkLoadingInStatusBar() {
    showNetworkLoadingInStatusBar(show: false)
}
