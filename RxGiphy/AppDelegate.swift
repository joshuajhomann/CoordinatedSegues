//
//  AppDelegate.swift
//  RxGiphy
//
//  Created by Joshua Homann on 10/9/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit

struct Dependencies {
    let giphyService = GiphyService()
    let gifCacheService = GifCacheService()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window = UIWindow(frame: UIScreen.main.bounds)
    let coordinator = Coordinator(initialAction: .showSearch, dependencies: Dependencies())

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIStoryboardSegue.swizzle()
        window.rootViewController = coordinator.navigationController
        window.makeKeyAndVisible()
        return true
    }

}

