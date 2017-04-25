//
//  AppDelegate.swift
//  Dyno
//
//  Created by Plutonist on 2017/4/20.
//  Copyright (c) 2017 Plutonist. All rights reserved.
//

import UIKit
import DynoCore
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        ImageCache.default.clearDiskCache()
        
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = .white
        self.window!.makeKeyAndVisible()

        self.window!.rootViewController = RootNav.sharedInstance

        return true
    }
}
