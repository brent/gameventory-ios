//
//  User.swift
//  Gameventory
//
//  Created by Brent on 5/22/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import Foundation

class User: NSObject {
  let username: String
  let id: String
  let token: String
  let email: String
  

  let numGames: String
  let numFollowers: String
  let numFollowing: String
  
  init(id: String, username: String, token: String = "") {
    self.username = username
    self.id = id
    self.token = token
    self.email = ""
    
    self.numGames = ""
    self.numFollowers = ""
    self.numFollowing = ""
    
    super.init()
  }
}
