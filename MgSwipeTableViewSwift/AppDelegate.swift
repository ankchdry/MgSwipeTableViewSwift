//
//  AppDelegate.swift
//  MgSwipeTableViewSwift
//
//  Created by Ankit Chaudhary on 31/07/20.
//  Copyright © 2020 Ankit Chaudhary. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds);
        let controller = MailViewController();
        let navigation = UINavigationController(rootViewController: controller);
        window?.rootViewController = navigation;
        window?.backgroundColor = UIColor.white;
        window?.makeKeyAndVisible();
        return true
    }
}

