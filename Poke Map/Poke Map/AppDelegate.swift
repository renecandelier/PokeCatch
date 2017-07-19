//
//  AppDelegate.swift
//  Poke Map
//
//  Created by Rene Candelier on 7/16/16.
//  Copyright © 2016 Novus Mobile. All rights reserved.
//

import UIKit
import Parse
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().backgroundColor = UIColor(red:0.10, green:0.74, blue:0.83, alpha:1.00)
        UITabBar.appearance().tintColor = UIColor.white
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        Parse.setApplicationId("PcY6lvHil8dLYmwj3kpV8PCNbm6qCEMi8JBUceu3", clientKey: "fFW08zs2ZyW7vxdTufSaOpD98rTu2z56zBUoFVjZ")
        return true
    }

}

