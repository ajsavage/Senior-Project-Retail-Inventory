//
//  AddProductViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/27/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class AddProductViewController: Helper {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleField: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var productIDField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var typeField: UISegmentedControl!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var saveButton: UIButton!

    // Created Product
    var product: Product? = nil
    
    // Button actions
    @IBAction func editImageButtonPushed(sender: AnyObject) {
        
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButtonPushed(sender: AnyObject) {
        showLoadingSymbol(saveButton)
        var temp: String
        let dictionary = Dictionary<String, AnyObject>()
        
        // Product ID
        if (productIDField.text == nil) {
            showSaveErrorAlert("product ID")
            return
        }
        temp = productIDField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product ID")
            return
        }
        if (temp.characters.count != Constants.ProductID.Length) {
            showProductIDErrorAlert()
            return
        }
        
        FIRDatabase.database().reference().child("inventory/\(temp)").observeEventType(.Value,
                     withBlock: { snapshot in
                if snapshot.exists() {
                    self.showErrorAlert("New Product Error", message: "This product ID, \(temp), already exists.")
                    return
                }
                else {
                    self.continueSavingProduct(dictionary)
                }
        })
    }
    
    @IBAction func AddColorButtonPushed(sender: AnyObject) {
        // Open color adding view
        
        // Add new colored square to view
    }
    
    private func continueSavingProduct(dict: Dictionary<String, AnyObject>) {
        var temp: String
        var dictionary = dict
        
        // Title
        if (titleField.text == nil) {
            showSaveErrorAlert("product title")
            return
        }
        
        temp = titleField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product title")
            return
        }
        dictionary["Title"] = temp
        
        // Type
        if (typeField.selectedSegmentIndex < 0 ||
            typeField.selectedSegmentIndex >= Constants.Types.Names.count) {
            showSaveErrorAlert("product type")
            return
        }
        temp = Constants.Types.Names[typeField.selectedSegmentIndex]
        dictionary["Type"] = temp
        
        // Price
        if (priceField.text == nil) {
            showSaveErrorAlert("product price")
            return
        }
        temp = priceField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product price")
            return
        }
        
        let tempPrice: Float? = Float(temp)
        if (tempPrice == nil) {
            showSaveErrorAlert("product price")
            return
        }
        
        dictionary["Price"] = tempPrice
        
        // Description
        if (descriptionField.text == nil) {
            showSaveErrorAlert("product description")
            return
        }
        temp = descriptionField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product description")
            return
        }
        dictionary["Description"] = temp
        
        // Image
        if (imageView.image != nil) {
            dictionary["Image"] = dictionary["ID"]
            //UPLOAD
        }
        else {
            dictionary["Image"] = nil
        }
        
        //        if (colorView.subviews.count == 0) {
        //          showErrorAlert("New Product Error", message: "Please add at least one color.")
        //        return
        //  }
        
        product = Product(dict: dictionary)
        
        removeLoadingSymbol(saveButton)
        navigationController?.popViewControllerAnimated(true)
        self.presentViewController(EditPagesViewController(), animated: true, completion: nil)
    }
    
    func showSaveErrorAlert(message: String) {
        let errorAlert = UIAlertView(title: "New Product Error", message: "Please fill out the \(message) field.", delegate: self, cancelButtonTitle: "OK")
        indicator?.removeFromSuperview()
        errorAlert.tag = -1
        errorAlert.show()
    }
    
    func showProductIDErrorAlert() {
        let errorAlert = UIAlertView(title: "New Product Error", message: "Product IDs must be exactly \(Constants.ProductID.Length) characters long.", delegate: self, cancelButtonTitle: "OK")
        indicator?.removeFromSuperview()
        errorAlert.tag = -1
        errorAlert.show()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as? EditPagesViewController
        
        if destination != nil {
            destination!.currentProduct = self.product
        }
    }
}
