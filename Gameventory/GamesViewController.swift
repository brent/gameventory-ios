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
  
  var followerPressed: Bool!
  
  var isFollowed: Bool = false {
    willSet(newVal) {
      switch newVal {
      case true:
        updateFollowBtn(with: UIImage(named: "user-unfollow-icon"))
      case false:
        updateFollowBtn(with: UIImage(named:"user-follow-icon"))
      }
    }
  }
  
  @IBOutlet var zeroStateStackView: UIStackView!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var usernameLabel: UILabel!
  @IBOutlet var numGamesLabel: UILabel!
  @IBOutlet var numFollowersBtn: UIButton!
  @IBOutlet var numFollowingBtn: UIButton!
  @IBOutlet var followButton: UIButton!
  @IBOutlet var settingsBtn: UIButton!
  
  @IBAction func followingFollowerBtnPressed(_ sender: Any) {
    guard let button = sender as? UIButton else {
      return
    }
    
    switch button.tag {
    case 1:
      followerPressed = true
    case 2:
      followerPressed = false
    default:
      return
    }
    
    performSegue(withIdentifier: "showFollowingFollowers", sender: button)
  }

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
  
  func updateFollowBtn<T>(with content: T) {
    if otherUser != nil && user.username != otherUser?.username {
      if let title = content as? String {
        followButton.setTitle(title, for: [])
      }
      
      if let image = content as? UIImage {
        followButton.setImage(image, for: .normal)
      }
    } else {
      followButton.isHidden = true
    }
  }
  
  override func viewDidLoad() {
    tableView.dataSource = self
    tableView.delegate = self
    
    navigationItem.title = ""
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.tableView.isHidden = true
    self.zeroStateStackView.isHidden = false
    self.navigationItem.leftBarButtonItem = nil
    
    if otherUser != nil {
      settingsBtn.isHidden = true
      followButton.isHidden = false
    } else {
      settingsBtn.isHidden = false
      followButton.isHidden = true
    }
    
    tableView.estimatedRowHeight = 96.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(user.token)",
    ]
    
    if otherUser == nil {
      
      // TODO: turn this into an external method
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
              self.numGamesLabel.text? = "\(self.gameStore.gameventory.totalGames)\ngames"
              self.numFollowersBtn.setTitle("\(user["numFollowers"] as! Int)\nfollowers", for: .normal)
              self.numFollowingBtn.setTitle("\(user["numFollowing"] as! Int)\nfollowing", for: .normal)
              
              self.tableView.reloadData()
            }
            
          case let .failure(error):
            print(error)
          }
          
        case let .failure(error):
          print(error)
        }
      }
    } else {
      guard let otherUser = otherUser else {
        print("no otherUser found")
        return
      }
      
      // TODO: turn this into an external method
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
            self.numGamesLabel.text? = "\(self.otherUserGameStore!.gameventory.totalGames)\ngames"
            self.numFollowersBtn.setTitle("\(user["numFollowers"] as! Int)\nfollowers", for: .normal)
            self.numFollowingBtn.setTitle("\(user["numFollowing"] as! Int)\nfollowing", for: .normal)
            
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
      if let selectedPlatform = game.selectedPlatform {
        cell.selectedPlatformLabel?.text = Platform.displayName(for: selectedPlatform.name)
      }
      
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
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
    label.backgroundColor = UIColor(red: 170, green: 170, blue: 170, alpha: 0.9)
    label.font = UIFont(name: "ProximaNova-Bold", size: 13)
    label.textColor = UIColor.lightGray
    label.textAlignment = .center
    label.text = gameStore.sectionsInBacklog[section].uppercased()
    return label
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
      
      guard
        let section = tableView.indexPathForSelectedRow?.section,
        let row = tableView.indexPathForSelectedRow?.row,
        let backlog = detailViewGameStore.gamesInBacklog else {
          return
      }
      destinationVC.game = backlog[section][row]
      destinationVC.imageStore = imageStore
      destinationVC.gameStore = gameStore
      destinationVC.user = user
    case "showFollowingFollowers"?:
      let destinationVC = segue.destination as! FollowingFollowersViewController
      var title = ""
      
      switch followerPressed {
      case true:
        title = "Followers"
      case false:
        title = "Following"
      default:
        preconditionFailure("followerPressed not assigned")
      }
      
      if otherUser != nil {
        destinationVC.targetUser = otherUser
      }
      
      destinationVC.followingOrFollowers = title.lowercased()
      destinationVC.user = user
      destinationVC.navigationItem.title = title
      destinationVC.gameStore = gameStore
      destinationVC.imageStore = imageStore
    case "showSettings"?:
      let destinationVC = segue.destination as! SettingsViewController
      
      destinationVC.user = user
      destinationVC.gameStore = gameStore
      destinationVC.imageStore = imageStore
    default:
      preconditionFailure("Unexpected segue identifier")
    }
  }
}
