//
//  BacklogSectionPickerViewController.swift
//  Gameventory
//
//  Created by Brent on 4/24/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class BacklogSectionPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  var game: Game!
  var gameStore: GameStore!
  var imageStore: ImageStore!
  var user: User!
  
  var selectedPlatform: Platform?
  var locationInBacklog: (section: Int, index: Int)?
  var newSelectedPlatform: Platform?
  var newLocationInBacklog: (section: Int, index: Int)?
  
  let gameventorySections = [
    "Now playing",
    "Up next",
    "On ice",
    "Finished",
    "Abandoned"
  ]
  
  var gameBacklogDelegate: GameBacklogDelegate?
  
  @IBOutlet var backgroundMask: UIView!
  @IBOutlet var cardView: DesignableView!
  @IBOutlet var platformCollectionView: UICollectionView!
  @IBOutlet var sectionCollectionView: UICollectionView!
  
  @IBOutlet var gameTitleLabel: UILabel!
  
  @IBAction func dissmissView(_ sender: Any) {
    
    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut],
     animations: {
        self.cardView.center.y += self.view.bounds.width
        self.backgroundMask.alpha = 0
      },
     completion: { finished in
      self.presentingViewController?.dismiss(animated: false, completion: nil)
     }
    )
  }
  
  @IBAction func addGamePressed(_ sender: Any) {
    guard
      let newSelectedPlatform = self.newSelectedPlatform,
      let newLocationInBacklog = self.newLocationInBacklog else {
        return
    }
    
    game.selectedPlatform = newSelectedPlatform
    
    if gameStore.hasGame(game) {
      guard let locationInBacklog = self.locationInBacklog else {
        return
      }

      gameStore.moveGame(fromSection: locationInBacklog.section, fromIndex: locationInBacklog.index, toSection: newLocationInBacklog.section, toIndex: newLocationInBacklog.index, for: user)
    } else {
      gameStore.addGame(game: game, to: newLocationInBacklog.section, for: user)
    }
    
    self.dissmissView(sender)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = true
    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut],
      animations: {
        self.cardView.center.y -= self.view.bounds.width
        self.backgroundMask.alpha = 1.0
      },
      completion: nil
    )
  }
  
  override func viewDidLoad() {
    cardView.center.y += self.view.bounds.width
    backgroundMask.alpha = 0
    
    self.view.backgroundColor = UIColor.clear
    self.view.isOpaque = false
    
    platformCollectionView.delegate = self
    platformCollectionView.dataSource = self

    sectionCollectionView.delegate = self
    sectionCollectionView.dataSource = self
    
    gameTitleLabel.text = game.name
    
    if let selectedPlatform = game.selectedPlatform {
      self.selectedPlatform = selectedPlatform
    }

    let locationInBacklog = gameStore.locationInBacklog(of: game)
    if locationInBacklog.section == -1 || locationInBacklog.index == -1 {
      return
    } else {
      self.locationInBacklog = (locationInBacklog.section, locationInBacklog.index)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = false
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == self.platformCollectionView {
      guard let platforms = game.availablePlatforms else {
        return 0
      }
      return platforms.count
    } else if collectionView == self.sectionCollectionView {
      return 5
    }
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == self.platformCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "platformCell", for: indexPath) as! AddGameButtonCollectionViewCell
      
      guard let platforms = game.availablePlatforms else {
        return UICollectionViewCell()
      }
      
      cell.platformOrSectionLabel.text = platforms[indexPath.row].name
      return cell
      
    } else if collectionView == self.sectionCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sectionCell", for: indexPath) as! AddGameButtonCollectionViewCell
      
      cell.platformOrSectionLabel.text = gameventorySections[indexPath.row]
      return cell
    }
    
    return UICollectionViewCell()
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == self.platformCollectionView {
      guard let platforms = game.availablePlatforms else {
        print("No platforms")
        return
      }
      
      if let selectedPlatform = self.selectedPlatform {
        print("initial platform: ", selectedPlatform.name)
      } else {
        print("inital platform: NONE")
      }
      print("selected platform: ", platforms[indexPath.row].name)
      newSelectedPlatform = platforms[indexPath.row]
      
    } else if collectionView == self.sectionCollectionView {
      
      if let inBacklog = self.locationInBacklog {
        print("current backlog location: \(inBacklog)")
        if inBacklog.section == indexPath.row {
          newLocationInBacklog = inBacklog
          print("NO MOVE, game in section already")
        } else {
          if let games = gameStore.gamesInBacklog {
            let count = games[indexPath.row].count
            if count == 0 {
              newLocationInBacklog = (indexPath.row, 0)
              print("move to: \(newLocationInBacklog!)")
            } else {
              newLocationInBacklog = (indexPath.row, count)
              print("move to: \(newLocationInBacklog!)")
            }
          }
        }
      } else {
        if let games = gameStore.gamesInBacklog {
          print("not in backlog")
          let count = games[indexPath.row].count
          if count == 0 {
            newLocationInBacklog = (indexPath.row, 0)
            print("add to: \(newLocationInBacklog!)")
          } else {
            newLocationInBacklog = (indexPath.row, count)
            print("add to: \(newLocationInBacklog!)")
          }
        }
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 150.0, height: 44.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    return true
  }
}
