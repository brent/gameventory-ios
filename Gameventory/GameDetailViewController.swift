//
//  GameDetailViewController.swift
//  Gameventory
//
//  Created by Brent on 4/21/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class GameDetailViewController: UIViewController, GameBacklogDelegate {
  var game: Game! {
    didSet {
      navigationItem.title = game.name
    }
  }
  
  var imageStore: ImageStore!
  var gameStore: GameStore!
  var otherUserGameStore: GameStore!
  var user: User!
  
  var gameAdded: Bool = false {
    willSet(newVal) {
      switch newVal {
      case true:
        addOrMoveGameBtn.setTitle("Move", for: [])
      case false:
        addOrMoveGameBtn.setTitle("Add", for: [])
      }
    }
  }
  
  var buttonTitle: String!
  
  @IBOutlet var gameTitleLabel: UILabel!
  @IBOutlet var releaseDateLabel: UILabel!
  @IBOutlet var summaryLabel: UILabel!
  @IBOutlet var coverImg: UIImageView!
  @IBOutlet var addOrMoveGameBtn: UIButton!
  
  func updateGameStore(gameStore: GameStore) {
    self.gameStore = gameStore
    self.gameAdded = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    gameTitleLabel.text = game.name
    
    let date = Date(timeIntervalSince1970: Double(game.firstReleaseDate / 1000))
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    
    releaseDateLabel.text = dateFormatter.string(from: date)
    summaryLabel.text = game.summary
    coverImg.image = imageStore.image(forKey: String(game.igdbId))
    
    if gameStore.hasGame(game) {
      addOrMoveGameBtn.setTitle("Move", for: [])
    } else {
      addOrMoveGameBtn.setTitle("Add", for: [])
    }    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
      destinationVC.gameBacklogDelegate = self
    default:
      preconditionFailure("Could not find segue with identifier")
    }
  }
}
