//
//  File.swift
//  Gameventory
//
//  Created by Brent Meyer on 10/11/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit
import Alamofire

class FollowingFollowersViewController: UITableViewController {
  var user: User!
  var targetUser: User?
  
  var followingOrFollowers: String!
  var users = [User]()
  
  var gameStore: GameStore!
  var imageStore: ImageStore!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.tabBarController?.tabBar.isHidden = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if targetUser == nil {
      targetUser = user
    }
    
    var requestUrl = ""
    
    switch followingOrFollowers {
    case "following":
      requestUrl = GameventoryAPI.followingURL(for: targetUser!.username)
    case "followers":
      requestUrl = GameventoryAPI.followersURL(for: targetUser!.username)
    default:
      preconditionFailure("requestUrl unable to be set")
    }
    
    print(requestUrl)
    
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(user.token)",
    ]

    // TODO: turn this into an external method
    Alamofire.request(requestUrl, headers: headers).responseJSON { response in
      switch response.result {
      case let .success(data):
        guard
          let json = data as? [String: Any],
          let users = json[self.followingOrFollowers] as? [[String: Any]] else {
            print("problem parsing JSON")
            return
        }
        
        var usernameKey: String!
        if self.followingOrFollowers == "following" {
          usernameKey = "fUsername"
        } else {
          usernameKey = "uUsername"
        }
        
        for user in users {
          guard
            let id = user["uid"] as? String,
            let username = user[usernameKey] as? String else {
              print("problem parsing user data")
              return
          }
          
          let newUser = User(id: id, username: username)
          self.users.append(newUser)
          
          self.tableView.reloadData()
        }
      case let .failure(error):
        print(error)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
    
    cell.usernameLabel?.text = users[indexPath.row].username
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.tabBarController?.tabBar.isHidden = false
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showFollowingFollowerUser"?:
      let destinationVc = segue.destination as! GamesViewController
      destinationVc.gameStore = gameStore
      destinationVc.imageStore = imageStore
      destinationVc.user = user
      
      guard let index = tableView.indexPathForSelectedRow?.row else {
        return
      }
      destinationVc.otherUser = users[index]
    default:
      fatalError("Unexpected segue identifier")
    }
  }
}
