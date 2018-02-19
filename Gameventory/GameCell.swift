//
//  GameCell.swift
//  Gameventory
//
//  Created by Brent on 4/19/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {
  @IBOutlet var gameNameLabel: UILabel!
  @IBOutlet var coverImage: UIImageView!
  @IBOutlet var spinner: UIActivityIndicatorView!
  @IBOutlet var platformsLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    update(with: nil)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    update(with: nil)
  }
  
  func update(with image: UIImage?) {
    spinner.hidesWhenStopped = true
    if let imageToDisplay = image {
      spinner.stopAnimating()
      coverImage.image = imageToDisplay
    } else {
      spinner.startAnimating()
      coverImage.image = nil
    }
  }
}
