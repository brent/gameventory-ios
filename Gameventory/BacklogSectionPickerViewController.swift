//
//  BacklogSectionPickerViewController.swift
//  Gameventory
//
//  Created by Brent on 4/24/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

enum BacklogSectionButtonTags: Int {
  case NowPlaying
  case UpNext
  case OnIce
  case Finished
  case Abandoned
}

class BacklogSectionPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  var game: Game!
  var gameStore: GameStore!
  var user: User!
  
  var gameBacklogDelegate: GameBacklogDelegate?
  
  var buttonTag: Int = -1
  var pickedSection: Int = -1
  
  @IBOutlet var modalView: UIView!
  @IBOutlet var backgroundMask: UIView!
  @IBOutlet var picker: UIPickerView!
  let pickerSections = [
    ["Now playing", BacklogSectionButtonTags.NowPlaying.rawValue],
    ["Up next", BacklogSectionButtonTags.UpNext.rawValue],
    ["On ice", BacklogSectionButtonTags.OnIce.rawValue],
    ["Abandoned", BacklogSectionButtonTags.Abandoned.rawValue],
    ["Finished", BacklogSectionButtonTags.Finished.rawValue]
  ]
  @IBOutlet var pickerContainer: UIView!

  @IBOutlet var consoleBtn: DesignableButton!
  @IBOutlet var sectionBtn: DesignableButton!

  @IBAction func dissmissView(_ sender: Any) {
    presentingViewController?.dismiss(animated: false, completion: nil)
  }
  
  @IBAction func openPicker(_ sender: DesignableButton) {
    buttonTag = sender.tag
    picker.reloadAllComponents()
    pickerContainer.isHidden = false
  }
  
  @IBAction func addToBacklogSection(_ sender: UIButton) {
    if gameStore.hasGame(game) {
      gameStore.moveGameToSection(game: game, to: pickedSection, for: user)
    } else {
      gameStore.addGame(game: game, to: pickedSection, for: user)
    }
    
    gameBacklogDelegate?.updateGameStore(gameStore: gameStore)
    presentingViewController?.dismiss(animated: false, completion: nil)
  }
  
  @IBAction func closePicker(_ sender: Any) {
    pickerContainer.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = true
    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut],
      animations: {
        self.modalView.center.y += self.view.bounds.width
        self.backgroundMask.alpha = 1.0
      },
      completion: nil
    )
  }
  
  override func viewDidLoad() {
    modalView.center.y -= view.bounds.width
    backgroundMask.alpha = 0
    
    view.backgroundColor = UIColor.clear
    view.isOpaque = false
    
    picker.delegate = self
    picker.dataSource = self
    pickerContainer.isHidden = true
    
    guard let availablePlatforms = game.availablePlatforms else {
      print("error in didSelectRow")
      return
    }
    
    var platform = availablePlatforms[0].name
    var section = pickerSections[0][0] as? String
    
    if game.selectedPlatform != nil {
      platform = game.selectedPlatform!.name
      section = pickerSections[gameStore.locationInBacklog(of: game).section][0] as? String
      pickedSection = gameStore.locationInBacklog(of: game).section
    }
    
    consoleBtn.setTitle(platform, for: .normal)
    sectionBtn.setTitle(section, for: .normal)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = false
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch buttonTag {
    case 0:
      guard let availablePlatforms = game.availablePlatforms else {
        return 0
      }
      return availablePlatforms.count
    case 1:
      return pickerSections.count
    default:
      return 0
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch buttonTag {
    case 0:
      guard let availablePlatforms = game.availablePlatforms else {
        return "No available consoles"
      }
      return availablePlatforms[row].name
    case 1:
      return pickerSections[row][0] as? String
    default:
      return "Error"
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch buttonTag {
    case 0:
      guard let availablePlatforms = game.availablePlatforms else {
        print("error in didSelectRow")
        return
      }
      
      game.selectedPlatform = availablePlatforms[row]
      consoleBtn.setTitle(availablePlatforms[row].name, for: .normal)
    case 1:
      pickedSection = pickerSections[row][1] as! Int
      sectionBtn.setTitle(pickerSections[row][0] as? String, for: .normal)
    default:
      return
    }
  }
}
