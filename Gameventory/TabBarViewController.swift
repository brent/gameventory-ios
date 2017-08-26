//
//  TabBarViewController.swift
//  Gameventory
//
//  Created by Brent on 6/10/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
  var gameStore: GameStore!
  var imageStore: ImageStore!
  var user: User!
  
  override func viewDidLoad() {
    for viewController in self.childViewControllers {
      guard let vc = viewController as? UINavigationController else {
        fatalError("wrong controller type")
      }

      switch vc.topViewController {
      case is GamesViewController:
        let gamesVc = vc.topViewController as! GamesViewController
        gamesVc.gameStore = gameStore
        gamesVc.imageStore = imageStore
        gamesVc.user = user
      case is SearchViewController:
        let searchVc = vc.topViewController as! SearchViewController
        searchVc.gameStore = gameStore
        searchVc.imageStore = imageStore
        searchVc.user = user
      case is SocialViewController:
        let socialVc = vc.topViewController as! SocialViewController
        socialVc.gameStore = gameStore
        socialVc.imageStore = imageStore
        socialVc.user = user
      default:
        fatalError("unrecognized controller type")
      }
    }
    
    super.viewDidLoad()
    self.delegate = self
  }
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    guard let vc = viewController as? UINavigationController else {
      fatalError("wrong controller type")
    }
    
    switch vc.topViewController {
    case is GamesViewController:
      let gamesVc = vc.topViewController as! GamesViewController
      gamesVc.gameStore = gameStore
      gamesVc.imageStore = imageStore
      gamesVc.user = user
    case is SearchViewController:
      let searchVc = vc.topViewController as! SearchViewController
      searchVc.gameStore = gameStore
      searchVc.imageStore = imageStore
      searchVc.user = user
    case is SocialViewController:
      let socialVc = vc.topViewController as! SocialViewController
      socialVc.gameStore = gameStore
      socialVc.imageStore = imageStore
      socialVc.user = user
    case is GameDetailViewController:
      let gameDetailVc = vc.topViewController as! GameDetailViewController
      gameDetailVc.gameStore = gameStore
      gameDetailVc.imageStore = imageStore
      gameDetailVc.user = user
    default:
      fatalError("unrecognized controller type")
    }

    return true
  }
}
