//
//  SettingsViewController.swift
//  Gameventory
//
//  Created by Brent Meyer on 1/25/18.
//  Copyright © 2018 Brent. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

class SettingsViewController: UIViewController {
  var user: User!
  var gameStore: GameStore!
  var imageStore: ImageStore!
  
  @IBOutlet var usernameLabel: UILabel!
  
  override func viewDidLoad() {
    usernameLabel.text? = user.username
  }
  
  @IBAction func logOutBtnPressed(_ sender: Any) {
    let logOutUrl = GameventoryAPI.logOutUrl()
    
    let headers: HTTPHeaders = [
      "Authorization": "JWT \(user.token)"
    ]
    
    Alamofire.request(logOutUrl, method: .get, headers: headers).responseJSON { response in
      switch response.result {
      case let .success(data):
        guard
        let json = data as? [String: Any],
        let user = json["user"] as? NSNull else {
            return
        }
        
        self.user = nil
        self.gameStore = nil
        self.imageStore = nil
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LogInSignUpViewController")
        
        do {
          try Locksmith.deleteDataForUserAccount(userAccount: "gameventory")
        } catch {
          print("Error deleting in keychain")
        }
        
        self.present(controller, animated: true, completion: nil)
      case let .failure(error):
        print(error)
      }
    }
  }
}
