//
//  Event.swift
//  Gameventory
//
//  Created by Brent on 6/16/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import Foundation

enum EventType: String {
  case GAME_ADD_NOW_PLAYING
  case GAME_ADD_UP_NEXT
  case GAME_ADD_ON_ICE
  case GAME_ADD_FINISHED
  case GAME_ADD_ABANDONED
  case GAME_MOVE_NOW_PLAYING
  case GAME_MOVE_UP_NEXT
  case GAME_MOVE_ON_ICE
  case GAME_MOVE_FINISHED
  case GAME_MOVE_ABANDONED
  case USER_FOLLOW
  //case ADD_COMMENT_TO_GAME
  //case ADD_IMAGE_TO_GAME
}

class Event: NSObject {
  let actor: User
  let type: EventType
  let target: String
  let message: String
  
  init(_ type: EventType, for actor: User, with target: AnyObject) {
    self.actor = actor
    self.type = type
    
    if target is Game {
      let game = target as! Game
      self.target = String(game.igdbId)
    } else if target is User {
      let user = target as! User
      self.target = user.username
    } else {
      self.target = "no target"
    }
    
    self.message = Event.createMessage(type, for: actor, with: target)
  }
  
  static func createMessage(_ type: EventType, for actor: User, with target: AnyObject) -> String {
    var message: String!
    
    if type.rawValue.contains("GAME") {
      var parts = type.rawValue.components(separatedBy: "_")
      let _ = parts.removeFirst() // scope
      let action = parts.removeFirst()
      let section = parts.joined(separator: " ").lowercased().capitalized
      
      let game = target as! Game
      
      switch action {
      case "ADD":
        message = "\(actor.username) added \(game.name) to \(section)"
      case "MOVE":
        message = "\(actor.username) moved \(game.name) to \(section)"
      default:
        fatalError("problem creating message")
      }
    } else if type.rawValue.contains("USER") {
      var parts = type.rawValue.components(separatedBy: "_")
      let _ = parts.removeFirst() // scope
      let _ = parts.removeFirst() // action
      
      let user = target as! User
      
      message = "\(actor.username) followed \(user.username)"
    }
    
    return message
  }
}
