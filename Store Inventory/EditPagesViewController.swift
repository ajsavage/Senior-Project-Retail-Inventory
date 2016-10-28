//
//  EditPagesViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/24/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class EditPagesViewController: ShowProductViewController, UIAlertViewDelegate, UITextFieldDelegate {
    // Product Detail View Elements
    @IBOutlet var titleLabel: UITextView!
    @IBOutlet var priceLabel: UITextField!
    @IBOutlet var descriptionLabel: UITextView!
    @IBOutlet var inStockLabel: UILabel!
    @IBOutlet var imageLabel: UIImageView!
    @IBOutlet var searchField: UITextField!
    
    // Temporary size and color arrays
    var newColors = [NSString]()
    var newSizes = [NSNumber]()

    private func showErrorAlert(message: String) {
        let errorAlert = UIAlertView(title: "Invalid Search", message: message, delegate: self, cancelButtonTitle: "OK")
        errorAlert.tag = -1
        errorAlert.show()
    }
    
    @IBAction func searchFieldClicked(sender: AnyObject) {
        if (sender.text == nil || sender.text == "") {
            showErrorAlert("Please enter a product ID to display.")
        }
        
        if (sender.text!.characters.count != Constants.ProductID.Length) {
            showErrorAlert("Not a valid Product ID - Product IDs must be exactly " + String(Constants.ProductID.Length) + " characters long.")
        }
        else {
            showLoadingSymbol(searchField)
            
            // Capitalize all letters in the product ID
            let capitalID = sender.text!.uppercaseString
            
            let dataRef = FIRDatabase.database().reference().child("inventory")
            let productRef = dataRef.child(capitalID)
            
            productRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if !snapshot.exists() {
                    self.showErrorAlert("Product ID# " + capitalID + " does not currently exist in the database.")
                    self.removeLoadingSymbol(self.searchField)
                }
                else {
                    self.currentProduct = Product(data: snapshot, ref: dataRef)
                    self.currentProduct.loadInformation(true, callback: self.updateWithLoadedData)
                }
            })
        }
    }
 
    // Called when a text field is highlighted and the Return key is pushed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
      
    //    NOT WORKING
 /*     this Method
        keyboard blocks description when editing
        X - choose type not showing on button
        views should be hidden before a search... with a larger middle preselected search field??
        add image saving
        X - add new color menu has wrong titles?
        how to save a new size.. show size numbers in size menu
        remove 0 or less sizes from menu in other view
        test all adding/saving features
   */
        return true
    }
    
    // Called when the product's details are finished loading from the database
    func updateWithLoadedData() {
        // Sets the view to display the current product's details
        titleLabel.text = currentProduct.title as String
        priceLabel.text = String(currentProduct.price)
        imageLabel.image = currentProduct.image
        self.descriptionLabel.text = self.currentProduct.productDescription as String
        
        removeLoadingSymbol(searchField)
        searchField.text = nil
        
        inStockLabel.text = calculateStock
    }
 
    @IBAction func saveButtonClicked(sender: AnyObject) {
        currentProduct.selfRef.child("Title").setValue(titleLabel.text)
        currentProduct.selfRef.child("Price").setValue(priceLabel.text)
        currentProduct.selfRef.child("Description").setValue(descriptionLabel.text)
        currentProduct.selfRef.child("Type").setValue(chooseTypeButton?.titleLabel?.text)
        // IMAGE
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Type Dropdown Elements
    @IBOutlet var chooseTypeButton: UIButton!
    
    @IBAction func typeButtonClicked(sender: AnyObject) {
        let sheet = createTypeMenu
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            sheet.showFromRect(sender.frame, inView: self.view, animated: true)
        } else {
            sheet.showInView(self.view)
        }
    }
    
    // Color Dropdown Elements
    @IBOutlet var chooseColorLabel: UILabel!
    @IBOutlet var chooseColorButton: UIButton!
    
    // Action when a user touches inside the 'Choose Color' text
    @IBAction func colorButtonClicked(sender: AnyObject) {
        let sheet = createColorMenu
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            sheet.showFromRect(sender.frame, inView: self.view, animated: true)
        } else {
            sheet.showInView(self.view)
        }
    }
    
    override func colorCancelButton(sheet: UIActionSheet) {
        // Add New Color button
        sheet.addButtonWithTitle("✚ Add new Color")
        cancelColorIndex += 1
        
        // Cance Button
        sheet.addButtonWithTitle("Cancel")
        sheet.dismissWithClickedButtonIndex(cancelColorIndex, animated: true)
    }
    
    // Size Dropdown Elements
    @IBOutlet var chooseSizeLabel: UILabel!
    @IBOutlet var chooseSizeButton: UIButton!
  
    // Action when a user touches inside the 'Choose Size' text
    @IBAction func sizeButtonClicked(sender: AnyObject) {
        let sheet = createSizeMenu
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            sheet.showFromRect(sender.frame, inView: self.view, animated: true)
        } else {
            sheet.showInView(self.view)
        }
    }
    
    // Adds a new size button to the action sheet
    override func addSizeButton(title: String, index: Int, actionSheet: UIActionSheet) {
        actionSheet.addButtonWithTitle(title + " - " + String(currentProduct.sizes[index]))
        cancelSizeIndex += 1
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (alertView.tag == Constants.Colors.menuTag) {
            if (alertView.textFieldAtIndex(1) != nil && alertView.textFieldAtIndex(1)!.text != nil
                && alertView.textFieldAtIndex(0) != nil && alertView.textFieldAtIndex(0)!.text != nil) {
                let color: String = alertView.textFieldAtIndex(1)!.text!
                let realColor: String = alertView.textFieldAtIndex(0)!.text!
                
                
                if (color.characters.count > 0 && realColor.characters.count > 0) {
                    currentProduct.selfRef.child("Colors").setValue([color: realColor])
                }
            }
        }
    }
    
    func createNewColorView() {
        let errorAlert = UIAlertView()
        errorAlert.title = "Enter New Color"
        errorAlert.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput
        errorAlert.tag = Constants.Colors.menuTag
        
        errorAlert.addButtonWithTitle("OK")
        errorAlert.addButtonWithTitle("Cancel")
        errorAlert.dismissWithClickedButtonIndex(0, animated: true)
        errorAlert.dismissWithClickedButtonIndex(1, animated: true)
        
        errorAlert.textFieldAtIndex(0)?.placeholder = "New Color"
        errorAlert.textFieldAtIndex(1)?.placeholder = "Overview Color i.e. wine == red"
        
        errorAlert.show()
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        // If is the size action sheet
        if (actionSheet.tag == Constants.Sizes.menuTag) {
            actionSheetButtonClicked(actionSheet, buttonIndex: buttonIndex, view: chooseSizeLabel)
            inStockLabel.text = calculateStock
        }
        else if (actionSheet.tag == Constants.Colors.menuTag) {
            // Add button
            if (buttonIndex == cancelColorIndex - 1) {
                createNewColorView()
            }
            else {
                actionSheetButtonClicked(actionSheet, buttonIndex: buttonIndex, view: chooseColorLabel)
            }
        }
        else if (actionSheet.tag == Constants.Types.menuTag) {
            actionSheetButtonClicked(actionSheet, buttonIndex: buttonIndex, view: chooseTypeButton)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add rounded border to title textview
        titleLabel.layer.borderColor = UIColor.lightGrayColor().CGColor
        titleLabel.layer.cornerRadius = 5
        titleLabel.layer.borderWidth = 1
        
        // Add dismissing keyboard by tapping
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(EditPagesViewController.dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }
    
    // For Keyboard dismissal
    func dismissKeyboard() {
        view.endEditing(true)
        searchField.endEditing(true)
    }
}
