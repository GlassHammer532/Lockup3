//
//  AppDelegate.swift
//  Lockup3
//
//  Created by Felix Clissold on 14/08/2025.
//


import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: MapViewController())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()

        return true
    }
}
