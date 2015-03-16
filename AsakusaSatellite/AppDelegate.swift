//
//  AppDelegate.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Appearance.install()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = UINavigationController(rootViewController: WelcomeViewController())
        window?.makeKeyAndVisible()
        return true
    }

}

