//
//  GamesViewController.swift
//  Gameventory
//
//  Created by Brent on 3/30/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit
import Alamofire

class GamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  var gameStore: GameStore!
  var imageStore: ImageStore!
  var user: User!
  
  var otherUser: User?
  var otherUserGameStore: GameStore?
  
  var isFollowed: Bool = false {
    willSet(newVal) {
      switch newVal {
      case true:
        updateFollowBtn(withTitle: "unfollow")
      case false:
        updateFollowBtn(withTitle: "follow")
      }
    }
  }
  
  @IBOutlet var zeroStateStackView: UIStackView!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var usernameLabel: UILabel!
  @IBOutlet var numGamesLabel: UILabel!
  @IBOutlet var numFollowersLabel: UILabel!
  @IBOutlet var numFollowingLabel: UILabel!
  @IBOutlet var followButton: UIButton!

  @IBAction func followBtnPressed(_ sender: Any) {
    guard let followee = otherUser else {
      return
    }
    
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(user.token)",
    ]
    
    if isFollowed {
      let url = "\(GameventoryAPI.followURL())/\(followee.id)"
      Alamofire.request(url, method: .delete,
                        headers: headers).responseJSON { response in
        switch response.result {
        case let .success(data):
          guard
            let json = data as? [String: Any],
            let success = json["success"] as? Bool else {
              return
          }
          
          if success {
            self.isFollowed = false
          }
        case let .failure(error):
          print(error)
        }
      }
      
    } else {
      let params: Parameters = ["fid": followee.id, "fUsername": followee.username]
      Alamofire.request(GameventoryAPI.followURL(), method: .post, parameters: params,
                        encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
        switch response.result {
        case let .success(data):
          guard
            let json = data as? [String: Any],
            let success = json["success"] as? Bool else {
              return
          }
          
          if success {
            self.isFollowed = true
          }
        case let .failure(error):
          print(error)
        }
      }
    }
  }
  
  func updateFollowBtn(withTitle title: String) {
    if otherUser != nil && user != otherUser {
      followButton.setTitle(title, for: [])
    } else {
      followButton.isHidden = true
    }
  }
  
  override func viewDidLoad() {
    tableView.dataSource = self
    tableView.delegate = self
    
    let imageView = UIImageView(image: UIImage(named: "navBarLogo"))
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    navigationItem.titleView = imageView
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.tableView.isHidden = true
    self.zeroStateStackView.isHidden = false
    self.navigationItem.leftBarButtonItem = nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(user.token)",
    ]
    
    if otherUser == nil {
      
      Alamofire.request(GameventoryAPI.userURL(for: user.username), headers: headers).responseJSON { response in
        switch response.result {
        case let .success(data):
          guard
            let json = data as? [String: Any],
            let user = json["user"] as? [String: Any],
            let games = json["games"] as? [String: Any] else {
              return
          }
          
          let gameventoryResult = GameventoryAPI.gameventory(fromGames: games)
          switch gameventoryResult {
          case let .success(gameventory):
            self.gameStore.gameventory = gameventory
            
            if gameventory.isEmpty {
              self.tableView.isHidden = true
              self.zeroStateStackView.isHidden = false
              self.navigationItem.leftBarButtonItem = nil
            } else {
              self.zeroStateStackView.isHidden = true
              self.tableView.isHidden = false
              self.navigationItem.leftBarButtonItem = self.editButtonItem
              
              self.usernameLabel.text? = self.user.username
              self.numGamesLabel.text? = "\(self.gameStore.gameventory.totalGames) games"
              self.numFollowersLabel.text? = "\(user["numFollowers"] as! Int) followers"
              self.numFollowingLabel.text? = "\(user["numFollowing"] as! Int) following"
              
              self.tableView.reloadData()
            }
          case let .failure(error):
            print(error)
          }
          
        case let .failure(error):
          print(error)
        }
      }

      gameStore.getUserGameventory(for: user, withToken: user.token, completion: { (result) in
        switch result {
        case let .success(gameventory):
          self.gameStore.gameventory = gameventory
          
          if gameventory.isEmpty {
            self.tableView.isHidden = true
            self.zeroStateStackView.isHidden = false
            self.navigationItem.leftBarButtonItem = nil
          } else {
            self.zeroStateStackView.isHidden = true
            self.tableView.isHidden = false
            self.navigationItem.leftBarButtonItem = self.editButtonItem
            
            self.usernameLabel.text? = self.user.username
            self.numGamesLabel.text? = "\(self.gameStore.gameventory.totalGames) games"
            
            self.tableView.reloadData()
          }
        case let .failure(error):
          print(error)
        }
      })
    } else {
      guard let otherUser = otherUser else {
        print("no otherUser found")
        return
      }
      
      Alamofire.request(GameventoryAPI.userURL(for: otherUser.username), headers: headers).responseJSON { response in
        switch response.result {
        case let .success(data):
          guard
            let json = data as? [String: Any],
            let user = json["user"] as? [String: Any],
            let games = json["games"] as? [String: Any] else {
              return
          }
          
          self.isFollowed = user["isFollowed"] as! Bool
          
          let gameventoryResult = GameventoryAPI.gameventory(fromGames: games)
          switch gameventoryResult {
          case let .success(gameventory):
            self.otherUserGameStore = GameStore()
            self.otherUserGameStore!.gameventory = gameventory
            
            self.usernameLabel.text? = self.otherUser!.username
            self.numGamesLabel.text? = "\(self.otherUserGameStore!.gameventory.totalGames) games"
            self.numFollowersLabel.text? = "\(user["numFollowers"] as! Int) followers"
            self.numFollowingLabel.text? = "\(user["numFollowing"] as! Int) following"
            
            self.zeroStateStackView.isHidden = true
            
            self.tableView.reloadData()
            self.tableView.isHidden = false

          case let .failure(error):
            print(error)
          }
        case let .failure(error):
          print(error)
        }
      }
 
      self.tabBarController?.tabBar.isHidden = true
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.tabBarController?.tabBar.isHidden = false
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return gameStore.sectionsInBacklog.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if otherUserGameStore != nil {
      guard let backlog = otherUserGameStore?.gamesInBacklog else {
        return 0
      }
      
      return backlog[section].count
    } else {
      guard let backlog = gameStore.gamesInBacklog else {
        return 0
      }
      return backlog[section].count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
    
    let backlog: [[Game]]?
    if otherUserGameStore != nil {
      backlog = otherUserGameStore!.gamesInBacklog!
    } else {
      backlog = gameStore.gamesInBacklog!
    }
    
    //if let backlog = gameStore.gamesInBacklog {
    if let backlog = backlog {
      let game = backlog[indexPath.section][indexPath.row]
      cell.gameNameLabel?.text = game.name
      
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
      
    } else {
      cell.gameNameLabel?.text = ""
      cell.coverImage?.image = UIImage()
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return gameStore.sectionsInBacklog[section]
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
    view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
    
    let label = UILabel(frame: CGRect(x: 100, y: 0, width: tableView.frame.size.width - 200, height: 50))
    label.text = gameStore.sectionsInBacklog[section].uppercased()
    label.textAlignment = .center
    label.font = UIFont(name: "SourceSansPro-Semibold", size: 16)
    label.textColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1.0)
    
    view.addSubview(label)
    
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
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
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row % 2 == 1 {
      cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    }
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    self.tableView.setEditing(editing, animated: animated)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    navigationItem.leftBarButtonItem = editButtonItem
  }
  
  // Need to pass other user data to game detail
  // so the proper game displays and so the user
  // can appropriately add games
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

      let detailViewGameStore: GameStore!
      if otherUserGameStore != nil {
        detailViewGameStore = otherUserGameStore
        destinationVC.otherUserGameStore = otherUserGameStore
      } else {
        detailViewGameStore = gameStore
      }
      
      guard let section = tableView.indexPathForSelectedRow?.section,
        let row = tableView.indexPathForSelectedRow?.row,
        let backlog = detailViewGameStore.gamesInBacklog else {
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
