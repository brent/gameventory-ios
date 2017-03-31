//
//  GameStore.swift
//  Gameventory
//
//  Created by Brent on 3/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class GameStore {
  var allGames = [[Game]]()
  var sections = ["Now Playing", "Up Next", "On Ice", "Finished", "Abandoned"]
		
  init() {
    for _ in 0..<10 {
      createGame()
    }
  }
  
  func moveGame(fromSection: Int, fromIndex: Int, toSection: Int, toIndex: Int) {
    if (fromSection == toSection) && (fromIndex == toIndex) {
      return
    }
    
    let movedGame = allGames[fromSection][fromIndex]
    allGames[fromSection].remove(at: fromIndex)
    allGames[toSection].insert(movedGame, at: toIndex)
  }
  
  @discardableResult func createGame() -> Game {
    let newGame = Game.init(random: true)

    let rand = arc4random_uniform(UInt32(sections.count))
    if allGames.count < 5 {
      allGames.append([newGame])
    } else {
      allGames[Int(rand)].append(newGame)
    }
    
    return newGame
  }
}
