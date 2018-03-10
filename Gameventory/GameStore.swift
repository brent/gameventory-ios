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

enum FeedResult {
  case success([Event])
  case failure(Error)
}

enum UsersResult {
  case success([User])
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

enum FeedScope {
  case following
  case global
}

enum PopularGamesResult {
  case success([Game])
  case failure(Error)
}

class GameStore {
  var gameventory: Gameventory = Gameventory()
  
  var gamesInBacklog: [[Game]]? {
    return [gameventory.nowPlaying, gameventory.upNext, gameventory.onIce, gameventory.finished, gameventory.abandoned]
  }
  
  var sectionsInBacklog = ["Now Playing", "Up Next", "On Ice", "Finished", "Abandoned"]
  
  var gamesArray = [Game]()
  
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
  
  func getUserGameventory(for user: User, withToken token: String, completion: @escaping (GameventoryResult) -> Void) {
    let gameventoryUrl = GameventoryAPI.userURL(for: user.username)
    
    processRequest(URLstring: gameventoryUrl, withToken: token) { response in
      let result = GameventoryAPI.gameventory(fromJSON: response.data!)
      // Need to be able to get the user out of the result so it can be updated
      // this will allow the above getGameventory function to be removed
      switch result {
      case let .success(gameventory):
        completion(.success(gameventory))
      case let .failure(error):
        print(error)
      }
    }
  }
  
  func moveGameToSection(game: Game, to section: Int, for user: User) {
    if !hasGame(game) {
      return
    }

    let (fromSection, fromIndex) = self.locationInBacklog(of: game)
    
    let toSection = section
    let toIndex = 0
    
    moveGame(fromSection: fromSection, fromIndex: fromIndex, toSection: toSection, toIndex: toIndex, for: user)
  }
  
  // this should probably be moveGame(to: IndexPath, from:IndexPath)
  func moveGame(fromSection: Int, fromIndex: Int, toSection: Int, toIndex: Int, for user: User) {
    if (fromSection == toSection) && (fromIndex == toIndex) {
      updateGameventory(for: user)
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
    
    let eventType: EventType
    
    switch toSectionName {
    case "nowPlaying":
      eventType = .GAME_MOVE_NOW_PLAYING
    case "upNext":
      eventType = .GAME_MOVE_UP_NEXT
    case "onIce":
      eventType = .GAME_MOVE_ON_ICE
    case "finished":
      eventType = .GAME_MOVE_FINISHED
    case "abandoned":
      eventType = .GAME_MOVE_ABANDONED
    default:
      fatalError("couldn't create event type")
    }
    
    let userData = [
      "id": "\(user.id)",
      "username": "\(user.username)"
    ]
    
    let targetData = [
      "type": "game",
      "id": "\(movedGame.igdbId)",
      "name": "\(movedGame.name)"
    ]
    
    let event = Event(eventType, actor: userData, target: targetData)
    updateGameventory(for: user, with: event)
  }
  
  func addGame(game: Game, to section: Int, for user: User) {
    if self.hasGame(game) {
      return
    }
    
    let sectionName = GameventorySections(rawValue: section)!.string
    var section = gameventory.value(forKey: sectionName) as! [Game]
    section.append(game)
    gameventory.setValue(section, forKey: sectionName)
    
    let eventType: EventType
    
    switch sectionName {
    case "nowPlaying":
      eventType = .GAME_ADD_NOW_PLAYING
    case "upNext":
      eventType = .GAME_ADD_UP_NEXT
    case "onIce":
      eventType = .GAME_ADD_ON_ICE
    case "finished":
      eventType = .GAME_ADD_FINISHED
    case "abandoned":
      eventType = .GAME_ADD_ABANDONED
    default:
      fatalError("couldn't create event type")
    }

    let userData = [
      "id": "\(user.id)",
      "username": "\(user.username)"
    ]
    
    let targetData = [
      "type": "game",
      "id": "\(game.igdbId)",
      "name": "\(game.name)"
    ]
    
    let event = Event(eventType, actor: userData, target: targetData)
    updateGameventory(for: user, with: event)
  }
  
  func updateGameventory(for user: User, with event: Event? = nil) {
    // needs a way to include the event to send to the server
    // otherwise the event logging has to happen in a separate call
    var gameParams: [Array<Any>] = []
    
    for backlogSection in gamesInBacklog! {
      var newBacklogSection: Array<Any> = []
      
      for game in backlogSection {
        
        var platformsData: [[String: Any]] = []
        
        guard
          let availablePlatforms = game.availablePlatforms,
          let selectedPlatform = game.selectedPlatform else {
            return
        }
        
        for platform in availablePlatforms {
          
          let p: [String: Any] = ["igdb_name": platform.name, "igdb_id": platform.igdbId]
          
          platformsData.append(p)
        }
        
        let selectedPlatformData: [String: Any] = [
          "igdb_name": selectedPlatform.name,
          "igdb_id": selectedPlatform.igdbId
        ]
        
        let gameData: [String: Any] = [
          "igdb_name": game.name,
          "coverImgURL": game.coverImgURL,
          "igdb_first_release_date": game.firstReleaseDate,
          "igdb_summary": game.summary,
          "igdb_id": game.igdbId,
          "platforms": platformsData,
          "selected_platform": selectedPlatformData
        ]
                
        newBacklogSection.append(gameData)
      }
      
      gameParams.append(newBacklogSection)
    }

    let gameventoryUrl = GameventoryAPI.gameventoryURL()
    var params: Parameters = [
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
    
    if let event = event {
      let eventParams: Parameters = [
        "event": [
          "actor": [
            "id": event.actor["id"],
            "username": event.actor["username"]
          ],
          "target": [
            "type": event.target["type"],
            "id": event.target["id"],
            "name": event.target["name"]
          ],
          "type": event.type.rawValue
        ]
      ]
      
      params.updateValue(eventParams["event"], forKey: "event")
    }
    
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
        self.gamesArray = games
        completion(.success(games))
      case let .failure(error):
        print("Error fetching games: \(error)")
      }
    }
  }
  
  func searchForUser(withUsername username: String, withToken token: String, completion: @escaping (UsersResult) -> Void) {
    
    let userSearchURL = GameventoryAPI.userSearchURL(for: username)

    processRequest(URLstring: userSearchURL, withToken: token) { (response) in
      let result = GameventoryAPI.users(fromJSON: response.data!)
      
      switch result {
      case let .success(users):
        completion(.success(users))
      case let .failure(error):
        print("Error fetching users: \(error)")
      }
    }
  }
  
  func locationInBacklog(of game: Game) -> (section: Int, index: Int) {
    if let backlog = gamesInBacklog {
      var sectionNum = 0
      for section in backlog {
        for backlogGame in section {
          if backlogGame.igdbId == game.igdbId {
            return (sectionNum, section.index(of: backlogGame)!)
          }
        }
        sectionNum += 1
      }
    }
    
    return (-1, -1)
  }
  
  func hasGame(_ game: Game) -> Bool {
    if locationInBacklog(of: game).section >= 0 && locationInBacklog(of: game).index >= 0 {
      return true
    }
    return false
  }
  
  // TODO: this function should not be in here
  func getFeed(withToken token: String, scope: FeedScope, completion: @escaping (FeedResult) -> Void) {
    
    var params: Parameters = [:]
    if scope == .following {
      params["scope"] = "following"
    }
    let url = GameventoryAPI.feedURL()
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(token)",
    ]
    Alamofire.request(url, method: .get, parameters: params, headers: headers).responseJSON { response in
      let result = GameventoryAPI.feed(fromJSON: response.data!)
      
      switch result {
      case let .success(feed):
        completion(.success(feed))
      case let .failure(error):
        completion(.failure(error))
        print("Error fetching feed: \(error)")
      }
    }
  }
  
  func getPopularGames(withToken token: String, completion: @escaping (PopularGamesResult) -> Void) {
    
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(token)",
    ]
    let url = GameventoryAPI.popularURL()
    
    Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
      let result = GameventoryAPI.popularGames(fromJSON: response.data!)
      
      switch result {
      case let .success(games):
        completion(.success(games))
      case let .failure(error):
        completion(.failure(error))
        print("Error getting popular games: \(error)")
      }
    }
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
