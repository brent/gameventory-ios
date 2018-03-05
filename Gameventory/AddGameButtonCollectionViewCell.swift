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
  
  override var isSelected: Bool {
    willSet(newVal) {
      switch newVal {
      case true:
        let borderColor = wrapperView.borderColor
        wrapperView.backgroundColor = borderColor
      case false:
        wrapperView.backgroundColor = UIColor.clear
      }
    }
  }
}
