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
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.coverImage.layer.cornerRadius = 5.0
    self.coverImage.layer.masksToBounds = true
    self.coverImage.layer.borderWidth = 1.0
    self.coverImage.layer.borderColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0).cgColor
    
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
