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
  
  var selectedPlatformIndexPath: IndexPath?
  var locationInBacklogIndexPath: IndexPath?
  
  var platformScrolledTo = false
  var sectionScrolledTo = false
  
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
    if (newSelectedPlatform == nil || newLocationInBacklog == nil) &&
        (selectedPlatform == nil || locationInBacklog == nil) {
      if locationInBacklog == nil && selectedPlatform == nil {
        var alert = UIAlertController()
        alert = UIAlertController(title: "Looks like you missed something", message: "Make sure you select a platform and section", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
        return
      }
    } else if (selectedPlatform != nil && locationInBacklog != nil) {
      if newSelectedPlatform == nil {
        newSelectedPlatform = self.selectedPlatform!
      }
      if newLocationInBacklog == nil {
        newLocationInBacklog = self.locationInBacklog!
      }
    }
    
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
    
    guard
      let selectedPlatform = self.selectedPlatform,
      let availablePlatforms = game.availablePlatforms,
      let locationInBacklog = self.locationInBacklog else {
        return
      }
    
    for platform in availablePlatforms {
      if platform.igdbId == selectedPlatform.igdbId {
        if let selectedPlatformIndex = availablePlatforms.index(of: platform) {
          let selectedPlatformIndexPath = IndexPath(row: selectedPlatformIndex, section: 0)
          self.selectedPlatformIndexPath = selectedPlatformIndexPath
          platformCollectionView.selectItem(at: selectedPlatformIndexPath, animated: false, scrollPosition: .left)
        }
      }
    }
    
    let locationInBacklogIndexPath = IndexPath(row: locationInBacklog.section, section: 0)
    self.locationInBacklogIndexPath = locationInBacklogIndexPath
    sectionCollectionView.selectItem(at: locationInBacklogIndexPath, animated: false, scrollPosition: .left)
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
    
    /*
    if let platformFlowLayout = platformCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      platformFlowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }
    
    if let sectionFlowLayout = sectionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      sectionFlowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }
    */

    let locationInBacklog = gameStore.locationInBacklog(of: game)
    if locationInBacklog.section == -1 || locationInBacklog.index == -1 {
      return
    } else {
      if let backlog = gameStore.gamesInBacklog {
        let backlogGame = backlog[locationInBacklog.section][locationInBacklog.index]
        if let selectedPlatform = backlogGame.selectedPlatform {
          self.selectedPlatform = selectedPlatform
        }
      }

      self.locationInBacklog = (locationInBacklog.section, locationInBacklog.index)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = false
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if collectionView == self.platformCollectionView {
      if self.platformScrolledTo == false {
        if let selectedPlatformIndexPath = self.selectedPlatformIndexPath {
          collectionView.scrollToItem(at: selectedPlatformIndexPath, at: .centeredHorizontally, animated: false)
          self.platformScrolledTo = true
        }
      }
    } else if collectionView == self.sectionCollectionView {
      if self.sectionScrolledTo == false {
        if let locationInBacklogIndexPath = self.locationInBacklogIndexPath {
          collectionView.scrollToItem(at: locationInBacklogIndexPath, at: .centeredHorizontally, animated: false)
          self.sectionScrolledTo = true
        }
      }
    }
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
      
      let platformText = platforms[indexPath.row].name
      cell.platformOrSectionLabel.text = Platform.displayName(for: platformText)
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

      newSelectedPlatform = platforms[indexPath.row]
      
    } else if collectionView == self.sectionCollectionView {
      
      if let inBacklog = self.locationInBacklog {
        if inBacklog.section == indexPath.row {
          newLocationInBacklog = inBacklog
        } else {
          if let games = gameStore.gamesInBacklog {
            let count = games[indexPath.row].count
            if count == 0 {
              newLocationInBacklog = (indexPath.row, 0)
            } else {
              newLocationInBacklog = (indexPath.row, count)
            }
          }
        }
      } else {
        if let games = gameStore.gamesInBacklog {
          let count = games[indexPath.row].count
          if count == 0 {
            newLocationInBacklog = (indexPath.row, 0)
          } else {
            newLocationInBacklog = (indexPath.row, count)
          }
        }
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    var collectionViewCellSize = CGSize()
    
    if collectionView == self.platformCollectionView {
      collectionViewCellSize.width = 80.0
    } else if collectionView == self.sectionCollectionView {
      collectionViewCellSize.width = 136.0
    }
    collectionViewCellSize.height = 36.0

    return collectionViewCellSize
  }
}
