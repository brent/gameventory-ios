//
//  LogInSignUpViewController.swift
//  Gameventory
//
//  Created by Brent on 5/21/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit
import Alamofire

enum LogInSignUpResult {
  case success(User)
  case failure(Error)
}

class LogInSignUpViewController: UIViewController {
  @IBOutlet var usernameTextField: UITextField!
  @IBOutlet var passwordTextField: UITextField!
  @IBOutlet var logInSignUpSubmitBtn: UIButton!
  
  @IBOutlet var logInSignUpSwitchBtn: UIButton!
  @IBOutlet var logInSignUpSwitchLabel: UILabel!
  
  var signUpMode = true
  var user: User!
  var gameStore: GameStore!
  var imageStore: ImageStore!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func logInSignUpSubmitBtnPressed(_ sender: Any) {
    guard
      let username = usernameTextField.text,
      let password = passwordTextField.text else {
        return
    }
    
    let params: Parameters = ["username": username, "password": password]
    
    if signUpMode {
      let signUpUrl = GameventoryAPI.signUpURL()
      
      Alamofire.request(signUpUrl, method: .post, parameters: params, encoding: URLEncoding.httpBody).responseJSON { response in
        switch response.result {
        case let .success(data):
          guard
            let json = data as? [String: Any],
            let id = json["userId"] as? String,
            let username = json["username"] as? String,
            let token = json["token"] as? String else {
              return
          }
          
          self.user = User(id: id, username: username, token: token)
          self.performSegue(withIdentifier: "showGameventory", sender: self)
        case let .failure(error):
          print(error)
        }
      }
      
    } else {
      let loginUrl = GameventoryAPI.logInURL()
      
      Alamofire.request(loginUrl, method: .post, parameters: params, encoding: URLEncoding.httpBody).responseJSON { response in
        switch response.result {
        case let .success(data):
          guard
            let json = data as? [String: Any],
            let id = json["userId"] as? String,
            let username = json["username"] as? String,
            let token = json["token"] as? String else {
              return
          }
          
          self.user = User(id: id, username: username, token: token)
          self.performSegue(withIdentifier: "showGameventory", sender: self)
        case let .failure(error):
          print(error)
        }
      }
    }
  }
  
  @IBAction func toggleSignUpLogInMode(_ sender: UIButton) {
    signUpMode = !signUpMode
    
    if signUpMode {
      logInSignUpSubmitBtn.setTitle("Sign up", for: [])
      logInSignUpSwitchLabel.text = "Already have an account?"
      logInSignUpSwitchBtn.setTitle("Log in", for: [])
    } else {
      logInSignUpSubmitBtn.setTitle("Log in", for: [])
      logInSignUpSwitchLabel.text = "Don't have an account?"
      logInSignUpSwitchBtn.setTitle("Sign up", for: [])      
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showGameventory"?:
      //let navController = segue.destination as! UINavigationController
      //let gamesViewController = navController.topViewController as! GamesViewController
      //gamesViewController.user = user
      //gamesViewController.gameStore = gameStore
      //gamesViewController.imageStore = imageStore
      
      let tabController = segue.destination as! TabBarViewController
      tabController.user = user
      tabController.gameStore = gameStore
      tabController.imageStore = imageStore

    default:
      preconditionFailure("Segue identifier not found")
    }
  }
}
