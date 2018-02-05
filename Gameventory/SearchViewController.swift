//
//  SearchViewController.swift
//  Gameventory
//
//  Created by Brent on 4/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var gameStore: GameStore!
  var imageStore: ImageStore!
  var user: User!
  let searchDataSource = SearchDataSource()
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var textInput: UITextField!
  
  @IBOutlet var collectionView: UICollectionView!
  
  @IBAction func performSearch(_ sender: UITextField) {
    if var searchString = sender.text {
      searchString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
      gameStore.searchForGame(withTitle: searchString, withToken: user.token, completion: { (gamesResult) in
        switch gamesResult {
        case let .success(games):
          self.gameStore.gamesArray = games
          self.searchDataSource.games = games
          self.searchDataSource.gameStore = self.gameStore
          self.searchDataSource.imageStore = self.imageStore
          self.fetchCoverImgs(for: games)
          
          self.tableView.isHidden = false
          self.collectionView.isHidden = true
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
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
    tap.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tap)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    tableView.isHidden = true
    collectionView.isHidden = false
    
    gameStore.getPopularGames(withToken: user.token) { (result) in
      switch result {
      case let .success(games):
        self.gameStore.gamesArray = games
        
        self.collectionView.reloadData()
      case let .failure(error):
        print("\(error)")
      }
    }
    
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    guard let gameCell = cell as? GameSearchResultCell else {
      return
    }
    
    if indexPath.row % 2 == 1 {
      gameCell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    }
    
    let game = gameStore.gamesArray[indexPath.row]
    if gameStore.hasGame(game) {
      gameCell.addGameBtn.superview!.isHidden = true
    } else {
      gameCell.addGameBtn.superview!.isHidden = false
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
    
    let game = gameStore.gamesArray[indexPath.item]
    
    if let coverImg = imageStore.image(forKey: String(game.igdbId)) {
      cell.update(with: coverImg)
    } else {
      GameventoryAPI.coverImg(url: game.coverImgURL, completion: { (result) in
        switch result {
        case let .success(coverImg):
          cell.update(with: coverImg)
        case let .failure(error):
          print(error)
        }
      })
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    guard let games = gameStore?.gamesArray else {
      return 21
    }
    
    return games.count
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    switch segue.identifier {
    case "showGameDetailFromSearch"?:
      if let selectedIndexPath = tableView.indexPathForSelectedRow {
        let game = gameStore.gamesArray[selectedIndexPath.row]
        let destinationVC = segue.destination as! GameDetailViewController
        
        destinationVC.game = game
        destinationVC.imageStore = imageStore
        destinationVC.gameStore = gameStore
        destinationVC.user = user
      }
    case "showGameDetailFromCollection"?:
      if let selectedIndexPath = collectionView.indexPath(for: sender as! CollectionViewCell) {
        let game = gameStore.gamesArray[selectedIndexPath.item]
        let destinationVC = segue.destination as! GameDetailViewController
        
        destinationVC.game = game
        destinationVC.imageStore = imageStore
        destinationVC.gameStore = gameStore
        destinationVC.user = user
      }
    case "showBacklogSectionSelector"?:
      if let button = sender as? UIButton {
        let selectedIndex = button.tag
        let game = gameStore.gamesArray[selectedIndex]
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
