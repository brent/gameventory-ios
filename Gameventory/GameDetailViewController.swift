//
//  GameDetailViewController.swift
//  Gameventory
//
//  Created by Brent on 4/21/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class GameDetailViewController: UIViewController {
  var game: Game! {
    didSet {
      navigationItem.title = game.name
    }
  }
  
  var imageStore: ImageStore!
  var gameStore: GameStore!
  var user: User!
  
  var buttonTitle: String!
  
  @IBOutlet var gameTitleLabel: UILabel!
  @IBOutlet var releaseDateLabel: UILabel!
  @IBOutlet var summaryLabel: UILabel!
  @IBOutlet var coverImg: UIImageView!
  @IBOutlet var addOrMoveGameBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    gameTitleLabel.text = game.name
    
    let date = Date(timeIntervalSince1970: Double(game.firstReleaseDate / 1000))
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    
    releaseDateLabel.text = dateFormatter.string(from: date)
    summaryLabel.text = game.summary
    coverImg.image = imageStore.image(forKey: String(game.igdbId))
    
    addOrMoveGameBtn.setTitle(buttonTitle, for: .normal)
    addOrMoveGameBtn.layer.cornerRadius = 3
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if gameStore.hasGame(game) {
      addOrMoveGameBtn.superview!.isHidden = true
    }
    self.tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = false
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showBacklogSectionSelector"?:
      let destinationVC = segue.destination as! BacklogSectionPickerViewController
      destinationVC.game = game
      destinationVC.gameStore = gameStore
      destinationVC.user = user
    default:
      preconditionFailure("Could not find segue with identifier")
    }
  }
}
