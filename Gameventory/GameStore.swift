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

enum CoverImgResult {
  case success(UIImage)
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
    
    let searchURL = IgdbAPI.searchURL(for: query)
    
    processRequest(URLstring: searchURL) { (response) in
      let result = IgdbAPI.games(fromJSON: response.data!)
      
      switch result {
      case let .success(games):
        self.gamesFromSearch = games
        completion(.success(games))
      case let .failure(error):
        print("Error fetching games: \(error)")
      }
    }
  }
  
  func processRequest(URLstring: String, completion: @escaping (DataResponse<Any>) -> Void) {
    Alamofire.request(URLstring).responseJSON { response in
      completion(response)
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
