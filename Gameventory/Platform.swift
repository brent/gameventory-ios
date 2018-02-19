//
//  Platform.swift
//  Gameventory
//
//  Created by Brent Meyer on 2/18/18.
//  Copyright © 2018 Brent. All rights reserved.
//

import Foundation

class Platform: NSObject {
  let name: String
  let igdbId: Int
  
  init(name: String, igdbId: Int) {
    self.name = name
    self.igdbId = igdbId
  }
}
