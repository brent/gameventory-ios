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
  
  func searchForGame(withName query: String) -> [Game] {
    var searchString = query.lowercased()
    searchString = searchString.replacingOccurrences(of: " ", with: "+")
    
    let searchURL = "\(MobyGamesAPI.gameSearchURL)\(searchString)"
    
    var gameSearchResults = [Game]()
    
    // perform URL request and parse JSON from response
    Alamofire.request(searchURL).responseJSON { response in
      // print(response.result.value!)
      
      do {
        let json = try JSONSerialization.jsonObject(with: response.data!, options: [])
        let dictionary = json as! [AnyHashable:Any]
        let games = dictionary["games"] as! [[String: Any]]
        
        for game in games {
          let gameObj = Game(name: game["gameTitle"] as! String, coverImg: nil, summary: nil, platforms: game["gamePlatforms"] as! [String])
          gameSearchResults.append(gameObj)
          print(gameObj.name)
          print(gameObj.platforms)
          print("---")
        }
        
      } catch let error {
        print(error)
      }
    }

    return gameSearchResults
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
