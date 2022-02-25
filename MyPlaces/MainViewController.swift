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
  
  // MARK: - Table view delegate
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCell.EditingStyle.delete {
      StorageManager.deleteObject(places[indexPath.row])
      tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
  }
  
  //MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      guard let newPlaceVC = segue.destination as? NewPlaceViewController else { return }
      guard let indexPath = tableView.indexPathForSelectedRow else { return }
      newPlaceVC.currentPlace = places[indexPath.row]
    }
  }
  
  @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
    guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
    
    newPlaceVC.savePlace()
    tableView.reloadData()
  }
  
}
