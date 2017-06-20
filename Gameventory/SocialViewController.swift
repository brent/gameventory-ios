//
//  SocialViewController.swift
//  Gameventory
//
//  Created by Brent on 6/19/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class SocialViewController: UITableViewController {
  var gameStore: GameStore!
  var imageStore: ImageStore!
  var user: User!
  var feed: [String]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    gameStore.getFeed(withToken: user.token) { (result) in
      switch result {
      case let .success(feed):
        self.feed = feed
        self.tableView.reloadData()
      case let .failure(error):
        print(error)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
    
    if feed != nil {
      cell.feedMessage?.text = feed[indexPath.row]
    } else {
      cell.feedMessage?.text = ""
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if feed != nil {
      return feed.count
    } else {
      return 0
    }
  }
}
