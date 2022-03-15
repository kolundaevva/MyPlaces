//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 02.03.2022.
//

import UIKit
import SwiftUI

@IBDesignable class RatingControl: UIStackView {

  var rating = 0 {
    didSet {
      updateButtonSelectionState()
    }
  }
  
  private var ratingButton = [UIButton]()
  
  @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
    didSet {
      setupButtons()
    }
  }
  @IBInspectable var starCount: Int = 5 {
    didSet {
      setupButtons()
    }
  }
  
  //MARK: - Inicilization
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupButtons()
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
    setupButtons()
  }
  
  //MARK: - Button action
   @objc func ratingButtonTapped(button: UIButton) {
     guard let index = ratingButton.firstIndex(of: button) else { return }
     
     let selectedRating = index + 1
     
     if selectedRating == rating {
       rating = 0
     } else {
       rating = selectedRating
     }
    }
   
  //MARK: - Private Methods
  
  private func setupButtons() {
    
    for button in ratingButton {
      removeArrangedSubview(button)
      button.removeFromSuperview()
    }
    
    ratingButton.removeAll()
    
    let bundle = Bundle(for: type(of: self))
    
    let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
    let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
    let highlitedStar = UIImage(named: "highlitedStar", in: bundle, compatibleWith: self.traitCollection)
    
    for _ in 1...starCount {
      let button = UIButton()
      
      button.setImage(emptyStar, for: .normal)
      button.setImage(filledStar, for: .selected)
      button.setImage(highlitedStar, for: .highlighted)
      button.setImage(highlitedStar, for: [.selected, .highlighted])
      
      //Setup constrants
      button.translatesAutoresizingMaskIntoConstraints = false
      button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
      button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
      
      button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
      addArrangedSubview(button)
      
      ratingButton.append(button)
    }
  }
  
  private func updateButtonSelectionState() {
    for (index, button) in ratingButton.enumerated() {
      button.isSelected = index < rating
    }
  }
}
