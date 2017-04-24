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
  
  @IBOutlet var gameTitleLabel: UILabel!
  @IBOutlet var releaseDateLabel: UILabel!
  @IBOutlet var summaryLabel: UILabel!
  @IBOutlet var coverImg: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    gameTitleLabel.text = game.name
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    
    releaseDateLabel.text = dateFormatter.string(from: game.firstReleaseDate)
    summaryLabel.text = game.summary
    coverImg.image = imageStore.image(forKey: String(game.igdbId))
    
    print("game: ", game)
  }
}
