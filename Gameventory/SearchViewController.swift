//
//  SearchViewController.swift
//  Gameventory
//
//  Created by Brent on 4/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
  var gameStore: GameStore!
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
          self.searchDataSource.games = games
          self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        case let .failure(error):
          print("\(error)")
        }
      })
    }
    sender.resignFirstResponder()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = searchDataSource
  }
}
