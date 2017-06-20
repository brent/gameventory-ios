//
//  BacklogSectionPickerViewController.swift
//  Gameventory
//
//  Created by Brent on 4/24/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

enum BacklogSectionButtonTags: Int {
  case NowPlaying
  case UpNext
  case OnIce
  case Finished
  case Abandoned
}

class BacklogSectionPickerViewController: UIViewController {
  var game: Game!
  var gameStore: GameStore!
  var user: User!
  
  @IBOutlet var modalView: UIView!
  @IBOutlet var backgroundMask: UIView!
  
  @IBAction func dissmissView(_ sender: Any) {
    presentingViewController?.dismiss(animated: false, completion: nil)
  }
  
  @IBAction func addToBacklogSection(_ sender: UIButton) {
    switch sender.tag {
    case BacklogSectionButtonTags.NowPlaying.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.NowPlaying.rawValue, for: user)
    case BacklogSectionButtonTags.UpNext.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.UpNext.rawValue, for: user)
    case BacklogSectionButtonTags.OnIce.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.OnIce.rawValue, for: user)
    case BacklogSectionButtonTags.Finished.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.Finished.rawValue, for: user)
    case BacklogSectionButtonTags.Abandoned.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.Abandoned.rawValue, for: user)
    default:
      return
    }
    
    presentingViewController?.dismiss(animated: false, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = true
    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut],
      animations: {
        self.modalView.center.y += self.view.bounds.width
        self.backgroundMask.alpha = 1.0
      },
      completion: nil
    )
  }
  
  override func viewDidLoad() {
    modalView.center.y -= view.bounds.width
    backgroundMask.alpha = 0
    
    view.backgroundColor = UIColor.clear
    view.isOpaque = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = false
  }
}
