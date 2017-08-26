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
  var feed: [String]!
  
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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    gameStore.getFeed(withToken: user.token) { (result) in
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
        cell.feedMessage?.text = feed[indexPath.row]
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
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showUser"?:
      let destinationVc = segue.destination as! GamesViewController
      destinationVc.gameStore = gameStore
      destinationVc.imageStore = imageStore
      destinationVc.user = user
      
      /*
      let cell = sender as! UserCell
      guard let indexPath = usersTableView.indexPath(for: cell) else {
        print("could not find cell in user table")
        return
      }
      let otherUser = users[indexPath.row]
      */
      
      guard let index = usersTableView.indexPathForSelectedRow?.row else {
        return
      }
      destinationVc.otherUser = users[index]
    default:
      fatalError("Unexpected segue identifier")
    }
  }
}
