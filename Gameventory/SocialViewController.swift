//
//  SocialViewController.swift
//  Gameventory
//
//  Created by Brent on 6/19/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
  var gameStore: GameStore!
  var imageStore: ImageStore!
  var user: User!
  var feed: [[String:Any]]!
  
  var users = [User]()
  
  @IBOutlet var feedTableView: UITableView!
  @IBOutlet var usersTableView: UITableView!
  @IBOutlet var textField: UITextField!
  @IBOutlet var segmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    feedTableView.delegate = self
    feedTableView.dataSource = self
    feedTableView.rowHeight = UITableViewAutomaticDimension
    feedTableView.estimatedRowHeight = 81
    usersTableView.delegate = self
    usersTableView.dataSource = self
    textField.delegate = self
    
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
    tap.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tap)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // This needs to be in viewDidLoad()
    // but search bar bug needs to be fixed first
    // so a user can clear the search results
    // and see the feed UI again
    gameStore.getFeed(withToken: user.token, scope: .following) { (result) in
      switch result {
      case let .success(feed):
        self.feed = feed
        self.feedTableView.isHidden = false
        self.usersTableView.isHidden = true
        self.feedTableView.reloadData()
      case let .failure(error):
        print(error)
      }
    }
  }
  
  @IBAction func segmentedControlPressed(_ sender: Any) {
    var scope: FeedScope!
    
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      scope = .following
    case 1:
      scope = .global
    default:
      print("ERROR WITH SEGMENTED CONTROL")
    }
    
    gameStore.getFeed(withToken: user.token, scope: scope) { (result) in
      switch result {
      case let .success(feed):
        self.feed = feed
        self.feedTableView.isHidden = false
        self.usersTableView.isHidden = true
        self.feedTableView.reloadData()
      case let .failure(error):
        print(error)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if tableView == feedTableView {
      let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
      
      if feed != nil {
        cell.feedMessage?.text = feed[indexPath.row]["message"] as? String
      } else {
        cell.feedMessage?.text = ""
      }
      
      return cell
    } else if tableView == usersTableView {
      let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
      
      if !users.isEmpty {
        cell.usernameLabel?.text = users[indexPath.row].username
      } else {
        cell.usernameLabel?.text = ""
      }
      
      return cell
    } else {
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == feedTableView {
      if feed != nil {
        return feed.count
      }
    } else if tableView == usersTableView {
      if !users.isEmpty {
        return users.count
      }
    }
    
    return 0
  }
  
  @IBAction func performSearch(_ sender: UITextField) {
    if var searchString = sender.text {
      searchString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
      
      gameStore.searchForUser(withUsername: searchString, withToken: user.token, completion: { (usersResult) in
        
        switch usersResult {
        case let .success(users):
          self.users = users
          self.feedTableView.isHidden = true
          self.usersTableView.isHidden = false
          self.segmentedControl.isHidden = true
          self.usersTableView.reloadData()
        case let .failure(error):
          print(error)
        }
      })
    }
    sender.resignFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showUser"?:
      let destinationVc = segue.destination as! GamesViewController
      destinationVc.gameStore = gameStore
      destinationVc.imageStore = imageStore
      destinationVc.user = user
      
      guard let index = usersTableView.indexPathForSelectedRow?.row else {
        return
      }
      destinationVc.otherUser = users[index]
    case "showFeedActor"?:
      let destinationVc = segue.destination as! GamesViewController
      destinationVc.gameStore = gameStore
      destinationVc.imageStore = imageStore
      destinationVc.user = user
      
      guard let index = feedTableView.indexPathForSelectedRow?.row,
        let id = feed[index]["actor"] as? String,
        let username = feed[index]["actorUsername"] as? String else {
          return
      }
      
      let otherUser = User(id: id, username: username)
      destinationVc.otherUser = otherUser
      
    default:
      fatalError("Unexpected segue identifier")
    }
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    feedTableView.isHidden = false
    usersTableView.isHidden = true
    segmentedControl.isHidden = false
    return true
  }
}