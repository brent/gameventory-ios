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
    
    let game = games[indexPath.row]
    cell.gameNameLabel?.text = game.name
    
    let coverImg = imageStore.image(forKey: String(game.igdbId))
    cell.update(with: coverImg)
    cell.selectionStyle = .none
    cell.addGameBtn.tag = indexPath.row
    
    guard let platforms = games[indexPath.row].availablePlatforms else {
      return UITableViewCell()
    }
    
    var platformsList = ""
    for platform in platforms {
      if platformsList.count > 0 {
        platformsList += ", \(platform.name)"
      } else {
        platformsList += platform.name
      }
    }
    
    cell.platformsLabel.text = platformsList
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return games.count
  }
}
