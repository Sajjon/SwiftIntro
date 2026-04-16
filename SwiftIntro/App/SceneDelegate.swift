//
//  SceneDelegate.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        logApp.debug("Scene connecting — setting up window")
        guard let windowScene = scene as? UIWindowScene else {
            logApp.error("Scene is not a UIWindowScene — aborting window setup")
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootVC()
        window.makeKeyAndVisible()
        self.window = window
        logApp.info("Window is key and visible — root view controller installed")
    }
}
