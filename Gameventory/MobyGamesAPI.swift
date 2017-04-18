//
//  MobyGamesAPI.swift
//  Gameventory
//
//  Created by Brent on 4/3/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import Foundation

enum Method: String {
  case gameSearch = "search/"
}

enum MobyGamesError: Error {
  case invalidJSONData
}

class MobyGamesAPI {
  private static let baseURLString = "http://localhost:3000/"
  private static let apiVersion = "api/v1/"
  
  private class func mobyGamesURL(method: Method) -> String {
    return "\(baseURLString)\(apiVersion)\(method.rawValue)"
  }
  
  private class var gameSearchURL: String {
    return mobyGamesURL(method: .gameSearch)
  }
  
  class func searchURL(for name: String) -> String {
    // format query for inclusion in URL
    var searchString = name.lowercased()
    searchString = searchString.replacingOccurrences(of: " ", with: "+")
    
    return "\(gameSearchURL)\(name)"
  }
  
  class func games(fromJSON data: Data) -> GamesResult {
    var allGames = [Game]()
    
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: [])
      
      guard
        let jsonDictionary = jsonObj as? [AnyHashable: Any],
        let gamesArray = jsonDictionary["games"] as? [[String: Any]] else {
          return .failure(MobyGamesError.invalidJSONData)
      }
      
      for gameJSON in gamesArray {
        if let game = game(fromJSON: gameJSON) {
          allGames.append(game)
        }
      }
    } catch let error {
      return .failure(error)
    }
    
    return .success(allGames)
  }
  
  private class func game(fromJSON json: [String: Any]) -> Game? {
    guard
      let name = json["gameTitle"] as? String,
      let platforms = json["gamePlatforms"] as? [String] else {
        return nil
    }
    
    // filters out collections or fan releases
    if platforms.count == 0 {
      return nil
    }
    
    var platformsWithoutDates = [String]()
    for platform in platforms {
      let start = platform.startIndex
      let end = platform.index(platform.endIndex, offsetBy: -7)
      let range = start..<end
      platformsWithoutDates.append(platform[range])
    }
    
    let game = Game(name: name, platforms: platformsWithoutDates)
    return game
  }
}
