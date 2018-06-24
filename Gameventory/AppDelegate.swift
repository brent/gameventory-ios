//
//  AppDelegate.swift
//  Gameventory
//
//  Created by Brent on 3/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit
import Locksmith

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let gameStore = GameStore()
    let imageStore = ImageStore()
    
    if let keychainData = Locksmith.loadDataForUserAccount(userAccount: "gameventory") {
      guard
        let id = keychainData["id"] as? String,
        let username = keychainData["username"] as? String,
        let token = keychainData["token"] as? String else {
          return false
      }
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let tabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
      let user = User(id: id, username: username, token: token)
      
      tabBarViewController.user = user
      tabBarViewController.gameStore = gameStore
      tabBarViewController.imageStore = imageStore
      
      window?.rootViewController = tabBarViewController
      window?.makeKeyAndVisible()
    } else {
      let logInSignUpController = window!.rootViewController as! LogInSignUpViewController
      logInSignUpController.gameStore = gameStore
      logInSignUpController.imageStore = imageStore
    }

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

