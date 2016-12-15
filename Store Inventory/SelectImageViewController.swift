//
//  SelectImageViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/5/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

// Protocol to communicate with the modal calling classes
// AddProductViewController and EditProductPagesViewController
protocol selectImageCommunicator {
    func selectedImageCallback(image: UIImage?)
}

class SelectImageViewController: Helper, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    // Calling delegate
    var delegate: selectImageCommunicator? = nil

    // Button Actions
    @IBAction func takePhotoPushed(sender: AnyObject) {
        if (!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            showErrorAlert("Error Alert", message: "This device has no camera, please select image from photo library.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectPhotoPushed(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        delegate?.selectedImageCallback(nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveImageButtonPushed(sender: AnyObject) {
        delegate?.selectedImageCallback(imageView.image)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image: UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if (image != nil) {
            self.imageView.image = image
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
