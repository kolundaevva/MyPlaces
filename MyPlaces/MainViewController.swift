//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 19.02.2022.
//

import UIKit

class MainViewController: UITableViewController {
  
  let restaurantNames = [
      "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
      "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
      "Speak Easy", "Morris Pub", "Вкусные истории",
      "Классик", "Love&Life", "Шок", "Бочка"
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    restaurantNames.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

    cell.nameLabel.text = restaurantNames[indexPath.row]
    cell.imageOfPlace.image = UIImage(named: restaurantNames[indexPath.row])
    cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 85
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
