//
//  SearchViewController.swift
//  Gameventory
//
//  Created by Brent on 4/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {
  var gameStore: GameStore!
  var imageStore: ImageStore!
  var user: User!
  let searchDataSource = SearchDataSource()
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var textInput: UITextField!
  
  @IBAction func done(_ sender: UIBarButtonItem) {
    textInput.resignFirstResponder()
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func performSearch(_ sender: UITextField) {
    if var searchString = sender.text {
      searchString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
      gameStore.searchForGame(withTitle: searchString, withToken: user.token, completion: { (gamesResult) in
        switch gamesResult {
        case let .success(games):
          self.gameStore.gamesFromSearch = games
          self.searchDataSource.games = games
          self.searchDataSource.gameStore = self.gameStore
          self.searchDataSource.imageStore = self.imageStore
          self.fetchCoverImgs(for: games)
        case let .failure(error):
          print("\(error)")
        }
      })
    }
    sender.resignFirstResponder()
  }
  
  func fetchCoverImgs(for games: [Game]) {
    for game in games {
      GameventoryAPI.coverImg(url: game.coverImgURL, completion: { (result) in
        switch result {
        case let .success(coverImg):
          self.imageStore.setImage(coverImg, forKey: String(game.igdbId))
          
          let index = games.index(of: game)
          let indexPath = IndexPath(row: index!, section: 0)
          if let cell = self.tableView.cellForRow(at: indexPath) as? GameSearchResultCell {
            cell.update(with: coverImg)
          }
        case let .failure(error):
          print(error)
        }
      })
    }
    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = searchDataSource
    tableView.delegate = self

    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row % 2 == 1 {
      cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    switch segue.identifier {
    case "showGameDetail"?:
      if let selectedIndexPath = tableView.indexPathForSelectedRow {
        let game = gameStore.gamesFromSearch[selectedIndexPath.row]
        let destinationVC = segue.destination as! GameDetailViewController
        
        destinationVC.game = game
        destinationVC.imageStore = imageStore
        destinationVC.gameStore = gameStore
        destinationVC.buttonTitle = "Add"
        destinationVC.user = user
      }
    case "showBacklogSectionSelector"?:
      if let button = sender as? UIButton {
        let selectedIndex = button.tag
        let game = gameStore.gamesFromSearch[selectedIndex]
        let destinationVC = segue.destination as! BacklogSectionPickerViewController
        destinationVC.game = game
        destinationVC.gameStore = gameStore
        destinationVC.user = user
      }
    default:
      preconditionFailure("Could not find segue with identifier")
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 96
  }
}
