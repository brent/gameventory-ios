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
  let actor: [String: String]
  let type: EventType
  let target: [String: String]
  
  init(_ type: EventType, actor: [String: String], target: [String: String]) {
    self.actor = actor
    self.type = type
    self.target = target
  }
  
  func printMessage(for user: User) -> String {
    guard
      var actorName = self.actor["username"],
      var targetName = self.target["name"],
      let targetType = self.target["obj"] else {
        return "printMessage() error"
    }
    
    if actorName == user.username {
      actorName = "You"
    }
    
    if targetType == "user" && targetName == user.username {
      targetName = "you"
    }
    
    var message: String!
    
    if targetType == "game" {
      
      var parts = type.rawValue.components(separatedBy: "_")
      let _ = parts.removeFirst() // scope
      let action = parts.removeFirst()
      let section = parts.joined(separator: " ").lowercased().capitalized
      
      switch action {
      case "ADD":
        message = "\(actorName) added \(targetName) to \(section)"
      case "MOVE":
        message = "\(actorName) moved \(targetName) to \(section)"
      default:
        fatalError("problem creating message")
      }
    } else if targetType == "user" {
      var parts = type.rawValue.components(separatedBy: "_")
      let _ = parts.removeFirst() // scope
      let _ = parts.removeFirst() // action
      
      message = "\(actorName) followed \(targetName)"
    }
    
    return message
  }
}
