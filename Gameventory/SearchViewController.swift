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
      gameStore.searchForGame(withTitle: searchString, completion: { (gamesResult) in
        switch gamesResult {
        case let .success(games):
          self.gameStore.gamesFromSearch = games
          self.searchDataSource.games = games
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
      IgdbAPI.coverImg(url: game.coverImgURL, completion: { (result) in
        switch result {
        case let .success(coverImg):
          self.imageStore.setImage(coverImg, forKey: String(game.igdbId))
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
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showGameDetail"?:
      if let selectedIndexPath = tableView.indexPathForSelectedRow {
        let destinationVC = segue.destination as! GameDetailViewController
        let game = gameStore.gamesFromSearch[selectedIndexPath.row]
        
        destinationVC.game = game
        destinationVC.imageStore = imageStore
      }
    default:
      preconditionFailure("Could not find segue with identifier")
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 96
  }
}
