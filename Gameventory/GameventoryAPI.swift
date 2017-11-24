//
//  GameventoryAPI.swift
//  Gameventory
//
//  Created by Brent on 4/18/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit
import Alamofire

enum Method: String {
  case gameSearch   = "/search"
  case gameventory  = "/gameventory"
  case logIn        = "/login"
  case signUp       = "/signUp"
  case feed         = "/feed"
  case users        = "/users"
  case follow       = "/follow"
  case followers    = "/followers"
  case following    = "/following"
}

enum GameventoryAPIError: Error {
  case invalidJSONData
}

class GameventoryAPI {
  private static let baseURLString = "http://localhost:3000"
  //private static let baseURLString = "https://inventory.games"
  private static let apiVersion = "/api/v1"
  
  private class func gameventoryApiUrl(method: Method) -> String {
    return "\(baseURLString)\(apiVersion)\(method.rawValue)"
  }
  
  private class var gameSearchURL: String {
    return gameventoryApiUrl(method: .gameSearch)
  }
  
  class func searchURL(for gameTitle: String) -> String {
    // format query for inclusion in URL
    var searchString = gameTitle.lowercased()
    searchString = "/\(searchString.replacingOccurrences(of: " ", with: "+"))"
    
    return "\(gameSearchURL)\(searchString)"
  }
  
  class func gameventoryURL() -> String {
    return "\(gameventoryApiUrl(method: .gameventory))"
  }
  
  class func logInURL() -> String {
    return "\(gameventoryApiUrl(method: .logIn))"
  }
  
  class func signUpURL() -> String {
    return "\(gameventoryApiUrl(method: .signUp))"
  }
  
  class func feedURL() -> String {
    return "\(gameventoryApiUrl(method: .feed))"
  }
  
  class func followURL() -> String {
    return "\(gameventoryApiUrl(method: .follow))"
  }
  
  class func followersURL(for username: String) -> String {
    return "\(gameventoryApiUrl(method: .followers))/\(username)"
  }
  
  class func followingURL(for username: String) -> String {
    return "\(gameventoryApiUrl(method: .following))/\(username)"
  }
  
  private class var userURL: String {
    return gameventoryApiUrl(method: .users)
  }
  
  class func userSearchURL(for username: String) -> String {
    let username = username.lowercased()
    return "\(userURL)?q=\(username)"
  }
  
  class func userURL(for username: String) -> String {
    let username = username.lowercased()
    return "\(userURL)/\(username)"
  }
  
  class func games(fromJSON data: Data) -> GamesResult {
    var allGames = [Game]()
    
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
      
      guard let jsonDictionary = jsonObj["games"] as? [[String: Any]] else {
          return .failure(GameventoryAPIError.invalidJSONData)
      }
      
      for gameJSON in jsonDictionary {
        if let game = game(fromJSON: gameJSON) {
          allGames.append(game)
        }
      }
      
    } catch let error {
      return .failure(error)
    }
    
    return .success(allGames)
  }
  
  class func users(fromJSON data: Data) -> UsersResult {
    var users = [User]()
    
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
      
      guard let jsonDictionary = jsonObj["users"] as? [[String: Any]] else {
        return .failure(GameventoryAPIError.invalidJSONData)
      }
      
      for userJSON in jsonDictionary {
        if let user = user(fromJSON: userJSON) {
          users.append(user)
        }
      }
    } catch let error {
      return .failure(error)
    }
    
    return .success(users)
  }
  
  class func user(fromJSON json: [String: Any]) -> User? {
    guard
      let userId = json["_id"] as? String,
      let username = json["username"] as? String else {
        return nil
    }
    
    let user = User(id: userId, username: username)
    return user
  }
  
  class func gameventory(fromJSON data: Data) -> GameventoryResult {
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
      guard
        let jsonDictionary = jsonObj["games"] as? [String: Any] else {
          return .failure(GameventoryAPIError.invalidJSONData)
      }
      
      var gvGames: [String: [Game]] = [:]
      
      for (key, _) in jsonDictionary {
        guard let gamesArray = jsonDictionary[key] as? [[String: Any]] else {
          continue
        }
        
        var gamesInSection: [Game] = []
        
        for gameData in gamesArray {
          guard
            let name = gameData["igdb_name"] as? String,
            let coverImgUrl = gameData["coverImgURL"] as? String,
            let firstReleaseDate = gameData["igdb_first_release_date"] as? Int,
            let summary = gameData["igdb_summary"] as? String,
            let id = gameData["igdb_id"] as? Int else {
              continue
          }
          
          let game = Game(name: name, coverImgURL: coverImgUrl, firstReleaseDate: firstReleaseDate, summary: summary, igdbId: id)
          
          gamesInSection.append(game)
        }
        
        gvGames[key] = gamesInSection
      }
      
      let gameventory = Gameventory()
      
      for (key, value) in gvGames {
        if value != [] {
          gameventory.setValue(value, forKey: key)
        }
      }
            
      return .success(gameventory)
      
    } catch let error {
      return .failure(error)
    }
  }
  
  class func gameventory(fromGames data: [String: Any]) -> GameventoryResult {
    do {
      var gvGames: [String: [Game]] = [:]
      
      for (key, _) in data {
        guard let gamesArray = data[key] as? [[String: Any]] else {
          continue
        }
        
        var gamesInSection: [Game] = []
        
        for gameData in gamesArray {
          guard
            let name = gameData["igdb_name"] as? String,
            let coverImgUrl = gameData["coverImgURL"] as? String,
            let firstReleaseDate = gameData["igdb_first_release_date"] as? Int,
            let summary = gameData["igdb_summary"] as? String,
            let id = gameData["igdb_id"] as? Int else {
              continue
          }
          
          let game = Game(name: name, coverImgURL: coverImgUrl, firstReleaseDate: firstReleaseDate, summary: summary, igdbId: id)
          
          gamesInSection.append(game)
        }
        
        gvGames[key] = gamesInSection
      }
      
      let gameventory = Gameventory()
      
      for (key, value) in gvGames {
        if value != [] {
          gameventory.setValue(value, forKey: key)
        }
      }
      
      return .success(gameventory)
    } catch let error {
      return .failure(error)
    }
  }
  
  private class func game(fromJSON json: [String: Any]) -> Game? {
    guard
      let id = json["igdb_id"] as? Int,
      let name = json["igdb_name"] as? String,
      let cover = json["igdb_cover"] as? [String: Any],
      let firstReleaseDate = json["igdb_first_release_date"] as? Int,
      let summary = json["igdb_summary"] as? String,
      let coverImgId = cover["cloudinary_id"] as? String else {
        return nil
    }
    
    let coverImgURL = self.coverImgURL(for: coverImgId)
        
    let game = Game(name: name, coverImgURL: coverImgURL, firstReleaseDate: firstReleaseDate, summary: summary, igdbId: id)
    return game
  }
  
  private class func coverImgURL(for coverImgId: String) -> String {
    var coverImgURL = ""
    
    let igdbImageBaseURL = "https://images.igdb.com/igdb/image/upload/t_"
    let coverSize = "cover_big/"
    let imgFormat = ".png"
    
    coverImgURL = "\(igdbImageBaseURL)\(coverSize)\(coverImgId)\(imgFormat)"
    
    return coverImgURL
  }
  
  
  class func coverImg(url: String, completion: @escaping (CoverImgResult) -> Void) {
    Alamofire.request(url).response { response in
      guard let imageData = response.data else {
        print("Could not get image from URL")
        return
      }
      if let image = UIImage(data: imageData) {
        completion(.success(image))
      }
    }
  }
  
  class func feed(fromJSON data: Data) -> FeedResult {
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
      
      guard let events = jsonObj["events"] as? [[String:Any]] else {
        return .failure(GameventoryAPIError.invalidJSONData)
      }
      
      return .success(events)
    } catch let error {
      return .failure(error)
    }
  }
}
