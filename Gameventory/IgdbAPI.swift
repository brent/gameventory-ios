//
//  IgdbAPI.swift
//  Gameventory
//
//  Created by Brent on 4/18/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

enum Method: String {
  case gameSearch = "/search"
}

enum IgdbAPIError: Error {
  case invalidJSONData
}

class IgdbAPI {
  private static let baseURLString = "http://localhost:3000"
  private static let apiVersion = "/api/v1"
  
  private class func igdbApiUrl(method: Method) -> String {
    return "\(baseURLString)\(apiVersion)\(method.rawValue)"
  }
  
  private class var gameSearchURL: String {
    return igdbApiUrl(method: .gameSearch)
  }
  
  class func searchURL(for gameTitle: String) -> String {
    // format query for inclusion in URL
    var searchString = gameTitle.lowercased()
    searchString = "/\(searchString.replacingOccurrences(of: " ", with: "+"))"
    
    print("\(gameSearchURL)\(searchString)")
    return "\(gameSearchURL)\(searchString)"
  }
  
  class func games(fromJSON data: Data) -> GamesResult {
    var allGames = [Game]()
    
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
      
      guard
        let jsonDictionary = jsonObj["games"] as? [[String: Any]] else {
          return .failure(IgdbAPIError.invalidJSONData)
      }
      
      // print(jsonDictionary[0]["name"])
      
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
  
  private class func game(fromJSON json: [String: Any]) -> Game? {
    guard
      let name = json["name"] as? String,
      let cover = json["cover"] as? [String: Any],
      var coverImgURL = cover["url"] as? String else {
        return nil
    }
    
    coverImgURL = "https:\(coverImgURL)"
    let game = Game(name: name, coverImgURL: coverImgURL)
    return game
  }

}
