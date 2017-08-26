//
//  Gameventory.swift
//  Gameventory
//
//  Created by Brent on 5/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import Foundation

class Gameventory: NSObject {
  var nowPlaying: [Game]
  var upNext: [Game]
  var onIce: [Game]
  var finished: [Game]
  var abandoned: [Game]
  
  var isEmpty: Bool {
    if self.nowPlaying.count > 0 || self.upNext.count > 0 || self.onIce.count > 0 || self.finished.count > 0 || self.abandoned.count > 0 {
      return false
    } else {
      return true
    }
  }
  
  var totalGames: Int {
    return self.nowPlaying.count + self.upNext.count + self.onIce.count + self.finished.count + self.abandoned.count
  }
  
  init(nowPlaying: [Game] = [], upNext: [Game] = [], onIce: [Game] = [], finished: [Game] = [], abandoned: [Game] = []) {
    self.nowPlaying = nowPlaying
    self.upNext = upNext
    self.onIce = onIce
    self.finished = finished
    self.abandoned = abandoned
  }
}
