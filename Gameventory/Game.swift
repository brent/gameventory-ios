//
//  Game.swift
//  Gameventory
//
//  Created by Brent on 3/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class Game: NSObject {
  let name: String
  let coverImgURL: String
  let firstReleaseDate: Int
  let summary: String
  let igdbId: Int
  var availablePlatforms: [Platform]?
  
  init(name: String, coverImgURL: String, firstReleaseDate: Int, summary: String, igdbId: Int, availablePlatforms: [Platform]? = nil) {
    self.name = name
    self.coverImgURL = coverImgURL
    self.firstReleaseDate = firstReleaseDate
    self.summary = summary
    self.igdbId = igdbId
    self.availablePlatforms = availablePlatforms
    
    super.init()
  }
}
