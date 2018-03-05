//
//  CollectionViewCell.swift
//  Gameventory
//
//  Created by Brent Meyer on 12/4/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class GameCollectionViewCell: UICollectionViewCell {
  @IBOutlet var gameCover: DesignableImageView!
  @IBOutlet var spinner: UIActivityIndicatorView!
  
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
      gameCover.image = imageToDisplay
    } else {
      spinner.startAnimating()
      gameCover.image = nil
    }
  }
}
