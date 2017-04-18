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
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
    
    let game = games[indexPath.row]
    cell.textLabel?.text = game.name
    cell.detailTextLabel?.text = game.platforms.joined(separator: ", ")
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return games.count
  }
}
