//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 20.02.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
  
  @IBOutlet var imageOfPlace: UIImageView!
  @IBOutlet var placeName: UITextField!
  @IBOutlet var placeLocation: UITextField!
  @IBOutlet var placeType: UITextField!
  
  @IBOutlet var saveButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    saveButton.isEnabled = false
    placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      alert()
    } else {
      view.endEditing(true)
    }
  }
  
  func saveNewPlace() {
    let imageData = imageOfPlace.image?.pngData()
    let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)
    
    StorageManager.saveObject(newPlace)
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
