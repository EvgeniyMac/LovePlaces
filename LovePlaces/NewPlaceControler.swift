//
//  NewPlace.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 18/06/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import UIKit
import Cosmos

class NewPlaceControler: UITableViewController {
    
    var currentPlace: Place!
    var isImageChanged = false
    var currentRating = 0.0
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var ratingControl: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditingInfo()
        
        ratingControl.didTouchCosmos = { rating in
            self.currentRating = rating
            
        }
        
        // Mark Check version ios for LargeTitle
        
        if #available(iOS 11.0, *) {
            guard let navigationController = navigationController else { return }
            guard navigationController.navigationBar.prefersLargeTitles else { return }
            guard navigationController.navigationItem.largeTitleDisplayMode != .never else { return }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photo")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo Library", style: .default) { (_) in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            view.endEditing(true)
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: Hide KeyBoard

extension NewPlaceControler: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Hide or show save button
    
    @objc private func textFieldChanged() {
        
        if !placeName.text!.isEmpty {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    // MARK: Navigation MapController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "showMap" { return }
        
        let mapVC = segue.destination as! MapViewController
        mapVC.place.name = placeName.text!
        mapVC.place.location = placeLocation.text!
        mapVC.place.type = placeType.text!
        mapVC.place.imageData = placeImage.image?.pngData()
    }

    //MARK:  Save Data after press button
    
    func savePlace() {
        
        let image = isImageChanged ? placeImage.image : UIImage(named: "imagePlaceholder")
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text!, type: placeType.text!, imageData: imageData, rating: currentRating)
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
        
    }
    
    //  MARK: Send data edition controller
    
    private func setupEditingInfo() {
        if currentPlace != nil {
            setupNavigationBar()
            isImageChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.rating = currentPlace.rating
        }
    }
    
    // Change Navigation when Edition
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
        
    }
}

// Check image from camera or PhotoLibrary

extension NewPlaceControler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = source
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image =  info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        isImageChanged = true
        dismiss(animated: true)
        
    }
}
