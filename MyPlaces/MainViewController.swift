//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 19.02.2022.
//

import UIKit
import RealmSwift
import SwiftUI

class MainViewController: UIViewController, UITableViewDataSource, UITabBarDelegate {
  
  private var places: Results<Place>!
  private var filtredPlaces: Results<Place>!
  private var ascendingSorting = true
  private var searchController = UISearchController(searchResultsController: nil)
  
  private var searchBarIsEmpty: Bool {
    guard let text = searchController.searchBar.text else { return false }
    return text.isEmpty
  }
  private var isFiltering: Bool {
    return searchController.isActive && !searchBarIsEmpty
  }
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var segmentedControl: UISegmentedControl!
  @IBOutlet var reversedSortingButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    places = realm.objects(Place.self)
    
    //Setup search contoller
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search"
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  // MARK: - Table view data source
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      return filtredPlaces.count
    } else {
      return places.isEmpty ? 0 : places.count
    }
  }
  
  func tableView(_ tabelView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
    
    let place: Place
    
    if isFiltering {
      place = filtredPlaces[indexPath.row]
    } else {
      place = places[indexPath.row]
    }
    
    cell.nameLabel.text = place.name
    cell.locationLabel.text = place.location
    cell.typeLabel.text = place.type
    cell.imageOfPlace.image = UIImage(data: place.imageData!)
    cell.ratingControl.rating = Int(place.rating)
    
    cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
    
    return cell
  }
  
  // MARK: - Table view delegate
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCell.EditingStyle.delete {
      StorageManager.deleteObject(places[indexPath.row])
      tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
  }
  
  //MARK: - Navigationr
  
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
  
  @IBAction func sortSelection(_ sender: UISegmentedControl) {
    sorting()
  }
  
  @IBAction func revesedSorting(_ sender: Any) {
    ascendingSorting.toggle()
    
    if ascendingSorting {
      reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
    } else {
      reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
    }
    
    sorting()
  }
  
  private func sorting() {
    if segmentedControl.selectedSegmentIndex == 0 {
      places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
    } else {
      places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
    }
    
    tableView.reloadData()
  }
}

extension MainViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    filterConterForSearchText(searchController.searchBar.text!)
  }
  
  private func filterConterForSearchText(_ searchText: String) {
    filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR type CONTAINS %@", searchText, searchText, searchText)
    
    tableView.reloadData()
  }
}
