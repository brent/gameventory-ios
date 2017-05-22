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
  case gameSearch = "/search"
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
    
    print("\(gameSearchURL)\(searchString)")
    return "\(gameSearchURL)\(searchString)"
  }
  
  class func games(fromJSON data: Data) -> GamesResult {
    var allGames = [Game]()
    
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
      
      guard
        let jsonDictionary = jsonObj["games"] as? [[String: Any]] else {
          return .failure(GameventoryAPIError.invalidJSONData)
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
  
  class func user(fromJSON json: [String: Any]) -> User? {
    guard
      let token = json["token"] as? String,
      let userId = json["userId"] as? String,
      let username = json["username"] as? String else {
        return nil
    }
    
    let user = User(id: userId, username: username, token: token)
    return user
  }
  
  private class func game(fromJSON json: [String: Any]) -> Game? {
    guard
      let id = json["igdb_id"] as? Int,
      let name = json["igdb_name"] as? String,
      let cover = json["igdb_cover"] as? [String: Any],
      let firstReleaseDate = json["igdb_first_release_date"] as? TimeInterval,
      let summary = json["igdb_summary"] as? String,
      let coverImgId = cover["cloudinary_id"] as? String else {
        return nil
    }
    
    let coverImgURL = self.coverImgURL(for: coverImgId)
    
    let releaseDate = Date(timeIntervalSince1970: (firstReleaseDate/1000))
    
    let game = Game(name: name, coverImgURL: coverImgURL, firstReleaseDate: releaseDate, summary: summary, igdbId: id)
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
      let image = UIImage(data: imageData)!
      completion(.success(image))
    }
  }
}
