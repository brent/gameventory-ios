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

enum GameventoryResult {
  case success(Gameventory)
  case failure(Error)
}

enum CoverImgResult {
  case success(UIImage)
  case failure(Error)
}

enum GameventorySections: Int {
  case nowPlaying
  case upNext
  case onIce
  case finished
  case abandoned
  
  var string: String {
    return String(describing: self)
  }
}

class GameStore {
  var gameventory: Gameventory = Gameventory()
  
  var gamesInBacklog: [[Game]]? {
    return [gameventory.nowPlaying, gameventory.upNext, gameventory.onIce, gameventory.finished, gameventory.abandoned]
  }
  
  var sectionsInBacklog = ["Now Playing", "Up Next", "On Ice", "Finished", "Abandoned"]
  
  var gamesFromSearch = [Game]()
  
  func getGameventory(for user: User, completion: @escaping (GameventoryResult) -> Void) {
    let gameventoryUrl = GameventoryAPI.gameventoryURL()

    processRequest(URLstring: gameventoryUrl, withToken: user.token) { response in
      let result = GameventoryAPI.gameventory(fromJSON: response.data!)
      switch result {
      case let .success(gameventory):
        self.gameventory = gameventory
        completion(.success(gameventory))
      case let .failure(error):
        print(error)
      }
    }
  }
  
  func moveGame(fromSection: Int, fromIndex: Int, toSection: Int, toIndex: Int, for user: User) {
    if (fromSection == toSection) && (fromIndex == toIndex) {
      return
    }
    
    let fromSectionName = GameventorySections(rawValue: fromSection)!.string
    var fromGameventorySection = gameventory.value(forKey: fromSectionName) as! [Game]
    let movedGame = fromGameventorySection[fromIndex]
    fromGameventorySection.remove(at: fromIndex)
    let toSectionName = GameventorySections(rawValue: toSection)!.string
    var toGameventorySection = gameventory.value(forKey: toSectionName) as! [Game]
    toGameventorySection.insert(movedGame, at: toIndex)
    
    gameventory.setValue(fromGameventorySection, forKey: fromSectionName)
    gameventory.setValue(toGameventorySection, forKey: toSectionName)
    
    updateGameventory(for: user)
  }
  
  func addGame(game: Game, to section: Int, for user: User) {
    
    let sectionName = GameventorySections(rawValue: section)!.string
    var section = gameventory.value(forKey: sectionName) as! [Game]
    section.append(game)
    gameventory.setValue(section, forKey: sectionName)
    
    updateGameventory(for: user)
  }
  
  func updateGameventory(for user: User) {
    var gameParams: [Array<Any>] = []
    
    for backlogSection in gamesInBacklog! {
      var newBacklogSection: Array<Any> = []
      
      for game in backlogSection {
        let gameData: [String: Any] = [
          "igdb_name": game.name,
          "coverImgURL": game.coverImgURL,
          "igdb_first_release_date": game.firstReleaseDate,
          "igdb_summary": game.summary,
          "igdb_id": game.igdbId
        ]
        
        newBacklogSection.append(gameData)
      }
      
      gameParams.append(newBacklogSection)
    }

    let gameventoryUrl = GameventoryAPI.gameventoryURL()
    let params: Parameters = [
      "user": [
        "id": user.id,
        "username": user.username
      ], "games": [
        "nowPlaying": gameParams[0],
        "upNext": gameParams[1],
        "onIce": gameParams[2],
        "finished": gameParams[3],
        "abandoned": gameParams[4]
      ]
    ]
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(user.token)",
      "Content-Type": "application/json"
    ]
    
    Alamofire.request(gameventoryUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
      let result = GameventoryAPI.gameventory(fromJSON: response.data!)
      switch result {
      case let .success(gameventory):
        self.gameventory = gameventory
      case let .failure(error):
        print(error)
      }
    }
  }
  
  func removeGame(_ game: Game, from indexPath: IndexPath, for user: User) {
    let sectionName = GameventorySections(rawValue: indexPath.section)!.string
    var section = gameventory.value(forKey: sectionName) as! [Game]
    section.remove(at: indexPath.row)
    
    gameventory.setValue(section, forKey: sectionName)
    
    updateGameventory(for: user)
  }
  
  func searchForGame(withTitle query: String, withToken token: String, completion: @escaping (GamesResult) -> Void) {
    
    let searchURL = GameventoryAPI.searchURL(for: query)
    
    processRequest(URLstring: searchURL, withToken: token) { (response) in
      let result = GameventoryAPI.games(fromJSON: response.data!)
      
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
        if backlogGame.igdbId == game.igdbId {
          return true
        }
      }
    }
    
    return false
  }
  
  func processRequest(URLstring: String, withToken token: String, completion: @escaping (DataResponse<Any>) -> Void) {
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(token)",
    ]
    
    Alamofire.request(URLstring, headers: headers).responseJSON { response in
      completion(response)
    }
  }
}
