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
  var gamesInBacklog: [[Game]]?
  var sectionsInBacklog = ["Now Playing", "Up Next", "On Ice", "Finished", "Abandoned"]
  
  var gamesFromSearch = [Game]()
  
  func moveGame(fromSection: Int, fromIndex: Int, toSection: Int, toIndex: Int) {
    if (fromSection == toSection) && (fromIndex == toIndex) {
      return
    }
    
    guard var newBacklog = gamesInBacklog else {
      return
    }
    
    let movedGame = newBacklog[fromSection][fromIndex]
    newBacklog[fromSection].remove(at: fromIndex)
    newBacklog[toSection].insert(movedGame, at: toIndex)
    
    gamesInBacklog = newBacklog
  }
  
  func addGame(game: Game, to section: Int) {
    if gamesInBacklog == nil {
      gamesInBacklog = [[], [], [], [], []]
    }
    
    gamesInBacklog![section].append(game)  
  }
  
  func removeGame(game: Game) {
    guard let backlog = gamesInBacklog else {
      return
    }
    
    var newBacklog = [[Game]]()
    for var section in backlog {
      for backlogGame in section {
        if backlogGame == game {
          section.remove(at: section.index(of: backlogGame)!)
        }
      }
      newBacklog.append(section)
    }
    gamesInBacklog = newBacklog
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
  
  func hasGame(_ game: Game) -> Bool {
    guard let backlog = gamesInBacklog else {
      return false
    }
    
    for section in backlog {
      for backlogGame in section {
        if backlogGame == game {
          return true
        }
      }
    }
    
    return false
  }
  
  func processRequest(URLstring: String, completion: @escaping (DataResponse<Any>) -> Void) {
    Alamofire.request(URLstring).responseJSON { response in
      completion(response)
    }
  }
}
