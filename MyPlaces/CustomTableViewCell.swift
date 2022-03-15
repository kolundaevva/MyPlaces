//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 20.02.2022.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

  @IBOutlet var imageOfPlace: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var locationLabel: UILabel!
  @IBOutlet var typeLabel: UILabel!
  @IBOutlet var ratingControl: RatingControl! {
    didSet {
      
    }
  }
  
}
