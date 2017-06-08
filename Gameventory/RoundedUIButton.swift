//
//  RoundedUIButton.swift
//  Gameventory
//
//  Created by Brent on 6/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class RoundedUIButton: UIButton {
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 5.0
  }
}
