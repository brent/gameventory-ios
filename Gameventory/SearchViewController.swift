//
//  SearchViewController.swift
//  Gameventory
//
//  Created by Brent on 4/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
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
    
    tableView.estimatedRowHeight = 96.0
    tableView.rowHeight = UITableViewAutomaticDimension
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
    
    let game = gameStore.gamesArray[indexPath.row]
    if gameStore.hasGame(game) {
      gameCell.addGameBtn.superview!.isHidden = true
    } else {
      gameCell.addGameBtn.superview!.isHidden = false
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! GameCollectionViewCell
    
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
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let imageAspectRatioWidth = CGFloat(320)
    let imageAspectRatioHeight = CGFloat(227)
    
    let cellPadding = CGFloat(24)
    let collectionViewNumColumns = CGFloat(3)
    
    let cellWidth = (collectionView.frame.size.width - ((collectionViewNumColumns - CGFloat(1)) * cellPadding)) / collectionViewNumColumns
    let cellHeight = (cellWidth * imageAspectRatioWidth) / imageAspectRatioHeight
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: CGFloat(10), right: CGFloat(10))
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return CGFloat(12)
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
      if let selectedIndexPath = collectionView.indexPath(for: sender as! GameCollectionViewCell) {
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
        destinationVC.imageStore = imageStore
        destinationVC.user = user
      }
    default:
      preconditionFailure("Could not find segue with identifier")
    }
  }
}
