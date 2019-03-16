//
//  AppDelegate.swift
//  FGDoodlingBoardExample
//
//  Created by xgf on 2019/3/15.
//  Copyright © 2019年 mrpyq. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let vc = ViewController()
        let navi = UINavigationController.init(rootViewController: vc)
        navi.navigationBar.barStyle = .black
        window?.rootViewController = navi
        return true
    }
}

