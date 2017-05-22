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
      let signUpUrl = "http://localhost:3000/api/v1/signup"
      // let signUpUrl = "https://inventory.games/api/v1/signup"
      
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
          print("\(self.user.username) signed up successfully")
          self.performSegue(withIdentifier: "showGameventory", sender: self)
        case let .failure(error):
          print(error)
        }
      }
      
    } else {
      let loginUrl = "http://localhost:3000/api/v1/login"
      // let loginUrl = "https://inventory.games/api/v1/login"
      
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
          print("\(self.user.username) logged in successfully")
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
      print("signUpMode", signUpMode)
      logInSignUpSubmitBtn.setTitle("Sign up", for: [])
      logInSignUpSwitchLabel.text = "Already have an account?"
      logInSignUpSwitchBtn.setTitle("Log in", for: [])
    } else {
      print("signUpMode", signUpMode)
      logInSignUpSubmitBtn.setTitle("Log in", for: [])
      logInSignUpSwitchLabel.text = "Don't have an account?"
      logInSignUpSwitchBtn.setTitle("Sign up", for: [])      
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showGameventory"?:
      let navController = segue.destination as! UINavigationController
      let gamesViewController = navController.topViewController as! GamesViewController
      gamesViewController.user = user
      gamesViewController.gameStore = gameStore
      gamesViewController.imageStore = imageStore
    default:
      preconditionFailure("Segue identifier not found")
    }
  }
}
