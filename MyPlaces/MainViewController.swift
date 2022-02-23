//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 19.02.2022.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
  
  var places: Results<Place>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    places = realm.objects(Place.self)
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    places.isEmpty ? 0 : places.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

    let place = places[indexPath.row]
    
    cell.nameLabel.text = place.name
    cell.locationLabel.text = place.location
    cell.typeLabel.text = place.type
    cell.imageOfPlace.image = UIImage(data: place.imageData!)
    
    cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
    
    return cell
  }
  
  @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
    guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
    
    newPlaceVC.saveNewPlace()
    tableView.reloadData()
  }
  
}
