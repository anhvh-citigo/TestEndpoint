//
//  AppDelegate.swift
//  TestEndpoint
//
//  Created by AnhVH on 05/03/2021.
//  Copyright © 2021 anhvh. All rights reserved.
//

import UIKit
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SVProgressHUD.appearance().backgroundColor = .green
        return true
    }


}

