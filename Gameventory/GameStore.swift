//
//  GameStore.swift
//  Gameventory
//
//  Created by Brent on 3/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit
import Alamofire

enum GamesResult {
  case success([Game])
  case failure(Error)
}

class GameStore {
  var gamesInBacklog = [[Game]]()
  var sectionsInBacklog = ["Now Playing", "Up Next", "On Ice", "Finished", "Abandoned"]
  
  var gamesFromSearch = [Game]()
		
  init() {
    for _ in 0..<10 {
      createGame()
    }
  }
  
  func moveGame(fromSection: Int, fromIndex: Int, toSection: Int, toIndex: Int) {
    if (fromSection == toSection) && (fromIndex == toIndex) {
      return
    }
    
    let movedGame = gamesInBacklog[fromSection][fromIndex]
    gamesInBacklog[fromSection].remove(at: fromIndex)
    gamesInBacklog[toSection].insert(movedGame, at: toIndex)
  }
  
  func searchForGame(withTitle query: String, completion: @escaping (GamesResult) -> Void) {
    // format query for inclusion in URL
    var searchString = query.lowercased()
    searchString = searchString.replacingOccurrences(of: " ", with: "+")
    
    let searchURL = MobyGamesAPI.searchURL(for: searchString)
    
    Alamofire.request(searchURL).responseJSON { response in
      let result = MobyGamesAPI.games(fromJSON: response.data!)
      completion(result)
    }
  }
  
  
  @discardableResult func createGame() -> Game {
    let newGame = Game.init(random: true)

    let rand = arc4random_uniform(UInt32(sectionsInBacklog.count))
    if gamesInBacklog.count < 5 {
      gamesInBacklog.append([newGame])
    } else {
      gamesInBacklog[Int(rand)].append(newGame)
    }
    
    return newGame
  }
}
