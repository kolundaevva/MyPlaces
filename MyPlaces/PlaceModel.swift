//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 20.02.2022.
//

import Foundation

struct Place {
  
  let name: String
  let location: String
  let type: String
  let image: String
  
  static let restaurantNames = [
      "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
      "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
      "Speak Easy", "Morris Pub", "Вкусные истории",
      "Классик", "Love&Life", "Шок", "Бочка"
  ]
  
  static func getPlaces() -> [Place] {
    var places = [Place]()
    
    for place in restaurantNames {
      places.append(Place(name: place, location: "Ростов", type: "Ресторан", image: place))
    }
    
    return places
  }
}
