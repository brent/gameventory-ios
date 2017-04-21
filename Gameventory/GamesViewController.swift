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
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return gameStore.sectionsInBacklog.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gameStore.gamesInBacklog[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
//    cell.textLabel?.text = gameStore.gamesInBacklog[indexPath.section][indexPath.row].name
//    cell.detailTextLabel?.text = gameStore.gamesInBacklog[indexPath.section][indexPath.row].platforms.first!
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
    cell.gameNameLabel?.text = gameStore.gamesInBacklog[indexPath.section][indexPath.row].name
    cell.coverImage?.image = UIImage(named: "227x320")
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return gameStore.sectionsInBacklog[section]
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    gameStore.moveGame(fromSection: sourceIndexPath.section, fromIndex: sourceIndexPath.row,
                       toSection: destinationIndexPath.section, toIndex: destinationIndexPath.row)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 96
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    navigationItem.leftBarButtonItem = editButtonItem
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showSearch"?:
      let viewController = segue.destination as! SearchViewController
      viewController.gameStore = gameStore
    default:
      preconditionFailure("Unexpected segue identifier")
    }
  }
}
