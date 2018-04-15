//
//  AddGameButtonCollectionView.swift
//  Gameventory
//
//  Created by Brent Meyer on 3/3/18.
//  Copyright © 2018 Brent. All rights reserved.
//

import UIKit

class AddGameButtonCollectionViewCell: UICollectionViewCell {
  @IBOutlet var wrapperView: DesignableView!
  @IBOutlet var platformOrSectionLabel: DesignableLabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    platformOrSectionLabel.sizeToFit()
    
    wrapperView.cornerRadius = 16
    
    // PC color
    // let defaultPlatformColor = UIColor(red: 101.0/255.0, green: 113.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    let defaultPlatformColor = UIColor(red: 119.0/255.0, green: 119.0/255.0, blue: 119.0/255.0, alpha: 1.0)
    wrapperView.borderColor = defaultPlatformColor
    wrapperView.backgroundColor = UIColor.clear
    platformOrSectionLabel.textColor = defaultPlatformColor
  }
  
  override var isSelected: Bool {
    willSet(newVal) {
      let borderColor = wrapperView.borderColor
      switch newVal {
      case true:
        wrapperView.backgroundColor = borderColor
        platformOrSectionLabel.textColor = UIColor.white
      case false:
        wrapperView.backgroundColor = UIColor.clear
        platformOrSectionLabel.textColor = borderColor
      }
    }
  }
}
