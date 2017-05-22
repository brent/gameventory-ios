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
  
  @IBAction func dissmissView(_ sender: Any) {
    presentingViewController?.dismiss(animated: false, completion: nil)
  }
  
  @IBAction func addToBacklogSection(_ sender: UIButton) {
    switch sender.tag {
    case BacklogSectionButtonTags.NowPlaying.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.NowPlaying.rawValue)
    case BacklogSectionButtonTags.UpNext.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.UpNext.rawValue)
    case BacklogSectionButtonTags.OnIce.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.OnIce.rawValue)
    case BacklogSectionButtonTags.Finished.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.Finished.rawValue)
    case BacklogSectionButtonTags.Abandoned.rawValue:
      gameStore.addGame(game: game, to: BacklogSectionButtonTags.Abandoned.rawValue)
    default:
      return
    }
    
    presentingViewController?.dismiss(animated: false, completion: nil)
  }
  
  override func viewDidLoad() {
    view.backgroundColor = UIColor.clear
    view.isOpaque = false
    modalView.layer.cornerRadius = 3
  }
}
