//
//  Game.swift
//  Gameventory
//
//  Created by Brent on 3/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class Game: NSObject {
  var name: String
  var coverImg: UIImage?
  var platforms: [String]
  var summary: String?
  
  init(name: String, coverImg: UIImage?, summary: String?, platforms: [String]) {
    self.name = name
    self.platforms = platforms
    self.coverImg = coverImg
    self.summary = summary
    
    super.init()
  }
  
  convenience init(random: Bool = false) {
    if random {
      let adjectives = ["Super", "Hyper", "Ultra", "Maximum"]
      let noun1 = ["Chef", "Attack", "Battle"]
      let noun2 = ["Bros", "Friends", "Squad", "Team"]
      let platforms = ["Xbox One", "Playstation 4", "Switch", "Playstation 3", "Xbox 360", "Wii U", "PC"]
      
      var rand = arc4random_uniform(UInt32(adjectives.count))
      let randomAdjective = adjectives[Int(rand)]
      
      rand = arc4random_uniform(UInt32(noun1.count))
      let randomNoun1 = noun1[Int(rand)]
      
      rand = arc4random_uniform(UInt32(noun2.count))
      let randomNoun2 = noun2[Int(rand)]
      
      let isSequel = arc4random_uniform(2) == 0
      let sequelNum: String
      if isSequel {
        sequelNum = "\(arc4random_uniform(2) + 1)"
      } else {
        sequelNum = ""
      }
      
      let randomName = "\(randomAdjective) \(randomNoun1) \(randomNoun2) \(sequelNum)"
      
      rand = arc4random_uniform(UInt32(platforms.count))
      let randomPlatform = platforms[Int(rand)]
      
      self.init(name: randomName, coverImg: nil, summary: nil, platforms: [randomPlatform])
    } else {
      self.init(name: "", coverImg: nil, summary: nil, platforms: [])
    }
  }
}
