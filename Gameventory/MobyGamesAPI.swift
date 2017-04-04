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
  
  static var gameSearchURL: String {
    return mobyGamesURL(method: .gameSearch)
  }
}
