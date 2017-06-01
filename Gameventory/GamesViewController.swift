//
//  GamesViewController.swift
//  Gameventory
//
//  Created by Brent on 3/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class GamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  var gameStore: GameStore!
  var imageStore: ImageStore!
  var user: User!
  
  @IBOutlet var zeroStateStackView: UIStackView!
  @IBOutlet var tableView: UITableView!

  override func viewDidLoad() {
    tableView.dataSource = self
    tableView.delegate = self
    
    let imageView = UIImageView(image: UIImage(named: "navBarLogo"))
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    navigationItem.titleView = imageView
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    //print(user.token)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    gameStore.getGameventory(for: user) { (result) in
      switch result {
      case let .success(gameventory):
        if gameventory.isEmpty {
          self.tableView.isHidden = true
          self.zeroStateStackView.isHidden = false
          self.navigationItem.leftBarButtonItem = nil
        } else {
          self.zeroStateStackView.isHidden = true
          self.tableView.isHidden = false
          self.navigationItem.leftBarButtonItem = self.editButtonItem
          self.tableView.reloadData()
        }
      case let .failure(error):
        print(error)
      }
    }
    
    /*
    if gameStore.gamesInBacklog == nil {
      tableView.isHidden = true
      zeroStateStackView.isHidden = false
      navigationItem.leftBarButtonItem = nil
    } else {
      zeroStateStackView.isHidden = true
      tableView.isHidden = false
      navigationItem.leftBarButtonItem = editButtonItem
    }
    */
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return gameStore.sectionsInBacklog.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let backlog = gameStore.gamesInBacklog {
      return backlog[section].count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
    if let backlog = gameStore.gamesInBacklog {
      //print("indexPath section: \(indexPath.section)", "indexPath row: \(indexPath.row)", separator: "\n", terminator: "\n\n")
      let game = backlog[indexPath.section][indexPath.row]
      cell.gameNameLabel?.text = game.name
      cell.coverImage?.image = imageStore.image(forKey: String(game.igdbId))
    } else {
      cell.gameNameLabel?.text = ""
      cell.coverImage?.image = UIImage()
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return gameStore.sectionsInBacklog[section]
  }
  
  /*
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    
    let label = UILabel()
    label.text = gameStore.sectionsInBacklog[section].uppercased()
    label.textAlignment = .center
    label.font = UIFont(name: "SourceSansPro-Light", size: 16)
    label.textColor = UIColor.darkText
    
    view.addSubview(label)
    
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
  */
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //print("backlog: \(gameStore.gamesInBacklog!)")
    //print("sourceIndexPath section: \(sourceIndexPath.section)", "sourceIndexPath row: \(sourceIndexPath.row)", "destinationIndexPath section: \(destinationIndexPath.section)", "destinationIndexPath row: \(destinationIndexPath.row)", separator: "\n", terminator: "\n\n")
    gameStore.moveGame(fromSection: sourceIndexPath.section, fromIndex: sourceIndexPath.row,
                       toSection: destinationIndexPath.section, toIndex: destinationIndexPath.row, for: user)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard let backlog = gameStore.gamesInBacklog else {
        return
      }
      
      let game = backlog[indexPath.section][indexPath.row]
      gameStore.removeGame(game, from: indexPath, for: user)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 96
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    self.tableView.setEditing(editing, animated: animated)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    navigationItem.leftBarButtonItem = editButtonItem
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showSearch"?:
      let navController = segue.destination as! UINavigationController
      let viewController = navController.topViewController as! SearchViewController
      viewController.gameStore = gameStore
      viewController.imageStore = imageStore
      viewController.user = user
    case "showGameDetail"?:
      let destinationVC = segue.destination as! GameDetailViewController
      guard let section = tableView.indexPathForSelectedRow?.section,
        let row = tableView.indexPathForSelectedRow?.row,
        let backlog = gameStore.gamesInBacklog else {
          return
      }
      destinationVC.game = backlog[section][row]
      destinationVC.imageStore = imageStore
      destinationVC.gameStore = gameStore
      destinationVC.buttonTitle = "Move"
      destinationVC.user = user
    default:
      preconditionFailure("Unexpected segue identifier")
    }
  }
}
