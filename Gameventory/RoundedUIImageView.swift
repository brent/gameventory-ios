//
//  RoundedUIImageView.swift
//  Gameventory
//
//  Created by Brent on 6/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class RoundedUIImageView: UIImageView {
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 5.0
    self.layer.masksToBounds = true
    self.layer.borderWidth = 1.0
    self.layer.borderColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0).cgColor
  }
}
