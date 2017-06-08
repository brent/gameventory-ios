//
//  UnderlinedTextField.swift
//  Gameventory
//
//  Created by Brent on 6/5/17.
//  Copyright © 2017 Brent. All rights reserved.
//

import UIKit

class UnderlinedTextField: UITextField {
  override var tintColor: UIColor! {
    didSet {
      setNeedsDisplay()
    }
  }
  
  override func draw(_ rect: CGRect) {
    let startingPoint = CGPoint(x: rect.minX, y: rect.maxY)
    let endingPoint = CGPoint(x: rect.maxX, y: rect.maxY)
    
    let path = UIBezierPath()
    
    path.move(to: startingPoint)
    path.addLine(to: endingPoint)
    path.lineWidth = 3.0
    
    tintColor.setStroke()
    
    path.stroke()
  }
}
