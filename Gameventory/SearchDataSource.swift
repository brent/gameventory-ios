//
//  SearchDataSource.swift
//  Gameventory
//
//  Created by Brent on 4/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit
import Alamofire

enum CoverImgFetchResult {
  case success(UIImage)
  case failure(Error)
}

class SearchDataSource: NSObject, UITableViewDataSource {
  var games: [Game] = []
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
    
    let game = games[indexPath.row]
    cell.gameNameLabel?.text = game.name
    
    fetchCoverImg(url: games[indexPath.row].coverImgURL) { (result) in
      switch result {
      case let .success(img):
        cell.coverImage?.image = img
      case let .failure(error):
        print("\(error)")
      }
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return games.count
  }
  
  
  private func fetchCoverImg(url: String, completion: @escaping (CoverImgFetchResult) -> Void) {
    Alamofire.request(url).response { response in
      guard let imageData = response.data else {
        print("Could not get image from URL")
        return
      }
      let image = UIImage(data: imageData)!
      completion(.success(image))
    }
  }
}
