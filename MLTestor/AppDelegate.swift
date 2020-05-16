//
//  AppDelegate.swift
//  MLTestor
//
//  Created by toureek on 5/14/20.
//  Copyright © 2020 com.toureek.ml.test. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        let rootViewController = UINavigationController.init(rootViewController: viewController)
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()

        return true
    }


}

