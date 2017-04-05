//
//  GamesViewController.swift
//  Gameventory
//
//  Created by Brent on 3/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class GamesViewController: UITableViewController {
  var gameStore: GameStore!
  
  override func viewDidLoad() {
    gameStore.searchForGame(withTitle: "Legend of Zelda") { (result) in
      switch result {
      case let .success(games):
        for game in games {
          print(game.name)
          print(game.platforms)
          print("---")
        }
      case let .failure(error):
        print(error)
      }
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return gameStore.sectionsInBacklog.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gameStore.gamesInBacklog[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
    cell.textLabel?.text = gameStore.gamesInBacklog[indexPath.section][indexPath.row].name
    cell.detailTextLabel?.text = gameStore.gamesInBacklog[indexPath.section][indexPath.row].platforms.first!
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return gameStore.sectionsInBacklog[section]
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    gameStore.moveGame(fromSection: sourceIndexPath.section, fromIndex: sourceIndexPath.row,
                       toSection: destinationIndexPath.section, toIndex: destinationIndexPath.row)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    navigationItem.leftBarButtonItem = editButtonItem
  }
}
