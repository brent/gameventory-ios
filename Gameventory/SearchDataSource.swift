//
//  SearchDataSource.swift
//  Gameventory
//
//  Created by Brent on 4/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class SearchDataSource: NSObject, UITableViewDataSource {
  var games: [Game] = []
  var gameStore: GameStore!
  var imageStore: ImageStore!
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameSearchResultCell", for: indexPath) as! GameSearchResultCell
    
    // indexPath changes as cells are dequeued and reused
    // this needs to match the game in the table cell
    let game = games[indexPath.row]
    cell.gameNameLabel?.text = game.name
    
    let coverImg = imageStore.image(forKey: String(game.igdbId))
    cell.coverImage.image = coverImg
    
    cell.selectionStyle = .none
    
    /*
    if gameStore.hasGame(game) {
      cell.addGameBtn.superview!.isHidden = true
    }
    */
    
    cell.addGameBtn.tag = indexPath.row
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return games.count
  }
}
