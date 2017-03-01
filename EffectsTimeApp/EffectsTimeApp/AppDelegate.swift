//
//  AppDelegate.swift
//  EffectsTimeApp
//
//  Created by Ivan Slobodiuk
//  Copyright © 2017 sLab. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let mainVC = window!.rootViewController as? MainViewController
        if mainVC != nil {
            mainVC!.setRecording( false )
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let mainVC = window!.rootViewController as? MainViewController
        if mainVC != nil {
             mainVC!.stopNotifications()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let mainVC = window!.rootViewController as? MainViewController
        if mainVC != nil {
            mainVC!.clearScreens()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let mainVC = window!.rootViewController as? MainViewController
        if mainVC != nil {
            mainVC!.startNotifications()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let mainVC = window!.rootViewController as? MainViewController
        if mainVC != nil {
            mainVC!.setRecording( false )
            mainVC!.stopNotifications()
        }
    }


}

