//
//  DependencyInjectionConfigurator.swift
//  Intranet3
//
//  Created by Alexander Cyon on 29/05/16.
//  Copyright © 2016-2026 intranet3. All rights reserved.
//

import Foundation

import UIKit
import Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {
    class func setup() {

        defaultContainer.register(HTTPClientProtocol.self) { _ in
            HTTPClient()
        }.inObjectScope(.container)

        defaultContainer.register(APIClientProtocol.self) { r in
            APIClient(
                httpClient: r.resolve(HTTPClientProtocol.self)!
            )
        }.inObjectScope(.container)

        defaultContainer.register(ImageCacheProtocol.self) { _ in
            Cache()
        }.inObjectScope(.container)

        defaultContainer.storyboardInitCompleted(GameVC.self) { r, c in
            c.imageCache = r.resolve(ImageCacheProtocol.self)
        }

        defaultContainer.storyboardInitCompleted(LoadingDataVC.self) { r, c in
            c.apiClient = r.resolve(APIClientProtocol.self)
            c.imageCache = r.resolve(ImageCacheProtocol.self)
        }
    }
}

