//
//  AppDelegate.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
    let container: Container = SwinjectStoryboard.defaultContainer
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
