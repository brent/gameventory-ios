//
//  SettingsViewController.swift
//  Gameventory
//
//  Created by Brent Meyer on 1/25/18.
//  Copyright © 2018 Brent. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  var user: User!
  
  @IBOutlet var usernameLabel: UILabel!
  
  override func viewDidLoad() {
    usernameLabel.text? = user.username
  }
}
