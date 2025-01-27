//
//  LogInSignUpViewController.swift
//  Gameventory
//
//  Created by Brent on 5/21/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

enum LogInSignUpResult {
  case success(User)
  case failure(Error)
}

class LogInSignUpViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet var emailTextField: UITextField!
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
    
    gameStore = GameStore()
    imageStore = ImageStore()
    
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
    tap.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tap)
    
    self.usernameTextField.delegate = self
    self.passwordTextField.delegate = self
    self.emailTextField.delegate = self
  }
  
  @IBAction func logInSignUpSubmitBtnPressed(_ sender: Any) {
    guard
      let username = usernameTextField.text,
      let password = passwordTextField.text else {
        return
    }

    var params: Parameters = [
      "username": username,
      "password": password
    ]

    var logInSignUpUrl = ""
    if signUpMode {
      logInSignUpUrl = GameventoryAPI.signUpURL()
      guard let email = emailTextField.text else { return }
      params.updateValue(email, forKey: "email")
    } else {
      logInSignUpUrl = GameventoryAPI.logInURL()
    }

    Alamofire.request(logInSignUpUrl, method: .post, parameters: params, encoding: URLEncoding.httpBody).responseJSON { response in
      switch response.result {
      case let .success(data):
        guard
          let json = data as? [String: Any],
          let success = json["success"] as? Bool,
          let message = json["message"] as? String else {
            print("ERROR: COULD NOT PARSE JSON")
            return
        }

        if success {
          guard
            let token = json["token"] as? String,
            let user = json["user"] as? [String: Any],
            let id = user["id"] as? String,
            let username = user["username"] as? String,
            let games = json["games"] as? [String: Any] else {
              return
          }

          self.user = User(id: id, username: username, token: token)

          let gameventoryResult = GameventoryAPI.gameventory(fromGames: games)
          switch gameventoryResult {
          case let .success(gameventory):
            self.gameStore.gameventory = gameventory
          case let .failure(error):
            print(error)
          }
          
          do {
            let keychainData = [
              "id": id,
              "username": username,
              "token": token
            ]
            try Locksmith.updateData(data: keychainData, forUserAccount: "gameventory")
          } catch {
            print(error)
          }
          
          self.performSegue(withIdentifier: "showGameventory", sender: self)
        } else {

          var alert = UIAlertController()

          switch message {
          case "user found; passwords do not match":
            alert = UIAlertController(title: "There was a problem logging in", message: "Check your username and password then try again.", preferredStyle: .alert)
          case "user already exists":
            alert = UIAlertController(title: "Sorry, that username is taken", message: "Try a different one and sign up again!", preferredStyle: .alert)
          default:
            alert = UIAlertController(title: "There was an error", message: "Please try again. If you encounter this problem multiple times, let me know.", preferredStyle: .alert)
          }

          alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

          self.present(alert, animated: true)
        }
      case let .failure(error):
        print(error)
      }
    }
  }
  
  @IBAction func toggleSignUpLogInMode(_ sender: UIButton) {
    signUpMode = !signUpMode
    
    if signUpMode {
      emailTextField.superview?.isHidden = false

      logInSignUpSubmitBtn.setTitle("Sign up", for: [])
      logInSignUpSwitchLabel.text = "Already have an account?"
      logInSignUpSwitchBtn.setTitle("Log in", for: [])
    } else {
      emailTextField.superview?.isHidden = true

      logInSignUpSubmitBtn.setTitle("Log in", for: [])
      logInSignUpSwitchLabel.text = "Don't have an account?"
      logInSignUpSwitchBtn.setTitle("Sign up", for: [])      
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField.tag {
    case 0:
      self.passwordTextField.becomeFirstResponder()
    case 1:
      self.view.endEditing(true)
      logInSignUpSubmitBtnPressed(textField)
    default:
      print("ERROR")
    }
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showGameventory"?:
      let tabController = segue.destination as! TabBarViewController
      tabController.user = user
      tabController.gameStore = gameStore
      tabController.imageStore = imageStore

    default:
      preconditionFailure("Segue identifier not found")
    }
  }
}
