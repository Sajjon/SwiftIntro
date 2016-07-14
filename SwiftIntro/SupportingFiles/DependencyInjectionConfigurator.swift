//
//  DependencyInjectionConfigurator.swift
//  Intranet3
//
//  Created by Alexander Georgii-Hemming Cyon on 29/05/16.
//  Copyright © 2016 intranet3. All rights reserved.
//

import Foundation

import UIKit
import Swinject

extension SwinjectStoryboard {
    class func setup() {

        defaultContainer.register(HTTPClientProtocol.self) { _ in
            HTTPClient()
        }.inObjectScope(.Container)

        defaultContainer.register(APIClientProtocol.self) { r in
            APIClient(
                httpClient: r.resolve(HTTPClientProtocol.self)!
            )
        }.inObjectScope(.Container)

        defaultContainer.register(ImagePrefetcherProtocol.self) { _ in
            ImagePrefetcher()
        }.inObjectScope(.Container)

        defaultContainer.registerForStoryboard(GameVC.self) { r, c in
            c.imagePrefetcher = r.resolve(ImagePrefetcherProtocol.self)
        }

        defaultContainer.registerForStoryboard(LoadingDataVC.self) { r, c in
            c.apiClient = r.resolve(APIClientProtocol.self)
            c.imagePrefetcher = r.resolve(ImagePrefetcherProtocol.self)
        }
    }
}
