//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 20.02.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
  
  var currentPlace: Place!
  
  @IBOutlet var imageOfPlace: UIImageView!
  @IBOutlet var placeName: UITextField!
  @IBOutlet var placeLocation: UITextField!
  @IBOutlet var placeType: UITextField!
  @IBOutlet var ratingContol: RatingControl!
  
  @IBOutlet var saveButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    saveButton.isEnabled = false
    placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    setupEditScreen()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      alert()
    } else {
      view.endEditing(true)
    }
  }
  
  //MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let identifire = segue.identifier,
      let mapVC = segue.destination as? MapViewController
      else { return }
    
    mapVC.incomeSegueIdentifire = identifire
    mapVC.mapViewControllerDelegate = self
    
    if identifire == "showMap" {
      mapVC.place.name = placeName.text!
      mapVC.place.location = placeLocation.text
      mapVC.place.type = placeType.text
      mapVC.place.imageData = imageOfPlace.image?.pngData()
    }
  }
  
  func savePlace() {
    let imageData = imageOfPlace.image?.pngData()
    let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData, rating: Double(ratingContol.rating))
    
    if currentPlace != nil {
      try! realm.write {
        currentPlace?.imageData = imageData
        currentPlace?.name = newPlace.name
        currentPlace?.location = newPlace.location
        currentPlace?.type = newPlace.type
        currentPlace.rating = newPlace.rating
      }
    } else {
      StorageManager.saveObject(newPlace)
    }
  }
  
  private func setupEditScreen() {
    if currentPlace != nil {
      setupNavigationBar()
      guard let data = currentPlace?.imageData else { return }
      
      imageOfPlace.image = UIImage(data: data)
      imageOfPlace.contentMode = .scaleAspectFill
      placeName.text = currentPlace?.name
      placeLocation.text = currentPlace?.location
      placeType.text = currentPlace?.type
      ratingContol.rating = Int(currentPlace.rating)
    }
  }
  
  private func setupNavigationBar() {
    if let topItem = navigationController?.navigationBar.topItem {
      topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    navigationItem.leftBarButtonItem = nil
    title = currentPlace?.name
    saveButton.isEnabled = true
  }
  @IBAction func cancelAction(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }
}

//MARK: Text Field Delegate

extension NewPlaceViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  @objc private func textFieldChanged() {
    if placeName.text?.isEmpty == false {
      saveButton.isEnabled = true
    } else {
      saveButton.isEnabled = false
    }
  }
}

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func chooseImagePicker(sourse: UIImagePickerController.SourceType) {
    if UIImagePickerController.isSourceTypeAvailable(sourse) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      imagePicker.sourceType = sourse
      present(imagePicker, animated: true)
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    imageOfPlace.image = info[.editedImage] as? UIImage
    imageOfPlace.contentMode = .scaleToFill
    imageOfPlace.clipsToBounds = true
    dismiss(animated: true)
  }
}

//MARK: - AlertContoller
extension NewPlaceViewController {
  func alert() {
    let actionSheet = UIAlertController(title: nil,
                                        message: nil,
                                        preferredStyle: .actionSheet)
    let camera = UIAlertAction(title: "Camera", style: .default) { _ in
      self.chooseImagePicker(sourse: .camera)
    }
    let photo = UIAlertAction(title: "Photo", style: .default) { _ in
      self.chooseImagePicker(sourse: .photoLibrary)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
    
    actionSheet.addAction(camera)
    actionSheet.addAction(photo)
    actionSheet.addAction(cancel)
    
    present(actionSheet, animated: true)
  }
}

extension NewPlaceViewController: MapViewControllerDelegate {
  func getAddress(_ address: String?) {
    placeLocation.text = address
  }
}
