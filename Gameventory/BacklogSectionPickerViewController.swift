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
  var imageStore: ImageStore!
  var user: User!
  
  var gameBacklogDelegate: GameBacklogDelegate?
  
  var buttonTag: Int = -1
  var pickedSection: Int = 0
  
  @IBOutlet var modalView: UIView!
  @IBOutlet var backgroundMask: UIView!
  @IBOutlet var picker: UIPickerView!
  let pickerSections = [
    ["Now playing", BacklogSectionButtonTags.NowPlaying.rawValue],
    ["Up next", BacklogSectionButtonTags.UpNext.rawValue],
    ["On ice", BacklogSectionButtonTags.OnIce.rawValue],
    ["Finished", BacklogSectionButtonTags.Finished.rawValue],
    ["Abandoned", BacklogSectionButtonTags.Abandoned.rawValue]
  ]
  @IBOutlet var pickerContainer: UIView!
  
  @IBOutlet var gameTitleLabel: UILabel!
  @IBOutlet var coverImg: DesignableImageView!
  
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
    
    var platformName = availablePlatforms[0].name
    var sectionName = pickerSections[0][0] as? String
    
    if gameStore.hasGame(game) && game.selectedPlatform != nil {
      platformName = game.selectedPlatform!.name
      sectionName = pickerSections[gameStore.locationInBacklog(of: game).section][0] as? String
      pickedSection = gameStore.locationInBacklog(of: game).section
    } else {
      let platform = Platform(name: availablePlatforms[0].name, igdbId: availablePlatforms[0].igdbId)
      game.selectedPlatform = platform
      platformName = platform.name
    }
    
    consoleBtn.setTitle(platformName, for: .normal)
    sectionBtn.setTitle(sectionName, for: .normal)
    
    gameTitleLabel.text = game.name
    coverImg.image = imageStore.image(forKey: String(game.igdbId))
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
      
      game.selectedPlatform = Platform(name: availablePlatforms[row].name, igdbId: availablePlatforms[row].igdbId)
      consoleBtn.setTitle(availablePlatforms[row].name, for: .normal)
    case 1:
      pickedSection = pickerSections[row][1] as! Int
      sectionBtn.setTitle(pickerSections[row][0] as? String, for: .normal)
    default:
      return
    }
  }
}
