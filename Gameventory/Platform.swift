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
  
  static func displayName(for platform: String) -> String {
    var platformText = platform
    
    switch platformText {
    case "Nintendo Switch":
      platformText = "NS"
    case "Wii U":
      platformText = "WII U"
    case "Xbox One":
      platformText = "XB1"
    case "Xbox 360":
      platformText = "X360"
    case "PlayStation 4":
      platformText = "PS4"
    case "PlayStation 3":
      platformText = "PS3"
    case "PC (Microsoft Windows)":
      platformText = "PC"
    default:
      platformText = platform
    }
    
    return platformText
  }
}
