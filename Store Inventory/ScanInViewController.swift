//
//  ScanInViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/28/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class ScanInViewController: ShowProductViewController, barcodeScannerCommunicator {
    @IBOutlet var barcodeLabel: UILabel!
    @IBOutlet var scanInButton: UIButton!
    @IBOutlet var sizeReportView: UIView!
    
    // Product Viewing Elements
    @IBOutlet var titleLabel: UITextView!
    @IBOutlet var priceLabel: UITextField!
    @IBOutlet var descriptionLabel: UITextView!
    @IBOutlet var imageLabel: UIImageView!
    
    @IBOutlet var overallScrollView: UIScrollView!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var descriptionScrollView: UIScrollView!
    @IBOutlet var saveButton: UIButton!
    
    var barcode: String?
    
    // Temporary colors array
    var newColors = [NSString]()
    
    // If the image was updated
    var imageChanged = false
    
    @IBAction func scanButtonClicked(sender: UIButton) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }

    func backFromBarcodeScanner(barcode: String?) {
        self.barcode = barcode
        
        if (barcode == nil) {
            self.barcode = "Could not find barcode (I think)"
        }
        
        barcodeLabel.text = self.barcode
    }
    
    @IBAction func searchFieldClicked(sender: AnyObject) {
        if (self.isBeingDismissed()) {
            showSearchAlert("You are being dismissed!")
        }
        else if (sender.text == nil || sender.text == "") {
            showSearchAlert("Please enter a product ID to display.")
        }
        else if (sender.text!.characters.count != Constants.ProductID.Length) {
            showSearchAlert("Not a valid Product ID - Product IDs must be exactly \(Constants.ProductID.Length) characters long.")
        }
        else {
            showLoadingSymbol(searchField)
            
            // Capitalize all letters in the product ID
            let capitalID = sender.text!.uppercaseString
            
            let dataRef = FIRDatabase.database().reference().child("inventory")
            let productRef = dataRef.child(capitalID)
            
            productRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if !snapshot.exists() {
                    self.showSearchAlert("Product ID# " + capitalID + " does not currently exist in the database.")
                    self.removeLoadingSymbol(self.searchField)
                }
                else {
                    self.currentProduct = Product(data: snapshot, ref: dataRef)
                    self.currentProduct.loadInformation(true, callback: self.updateWithLoadedData)
                }
            })
        }
    }
    
    // Called when a textView is selected for editing
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.tag == Constants.Description.FieldTag) {
            animateDescriptionScrollView(descriptionScrollView, distanceLength: -200, up: true)
        }
    }
    
    // Called when a textView is being edited and the Return key is pushed
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.tag == Constants.Description.FieldTag) {
            animateDescriptionScrollView(descriptionScrollView, distanceLength: -200, up: false)
        }
    }
    
    // Called when the product's details are finished loading from the database
    func updateWithLoadedData() {
        // Sets the view to display the current product's details
        titleLabel.text = currentProduct.title as String
        priceLabel.text = String(currentProduct.price)
        imageLabel.image = currentProduct.image
        self.descriptionLabel.text = self.currentProduct.productDescription as String
        typeName = currentProduct.type as String
        chooseTypeLabel.text = "Type: \(typeName)"
        
        overallScrollView.hidden = false
        view.backgroundColor = UIColor.whiteColor()
        removeLoadingSymbol(searchField)
        searchField.text = nil
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        showLoadingSymbol(overallScrollView)
        
        currentProduct.selfRef.child("Title").setValue(titleLabel.text)
        currentProduct.selfRef.child("Description").setValue(descriptionLabel.text)
        
        let price = Float(priceLabel.text!)
        if (price != nil) {
            currentProduct.selfRef.child("Price").setValue(price)
        }
        
        if (chooseTypeButton.currentTitle != "Choose Type") {
            currentProduct.selfRef.child("Type").setValue(typeName)
        }
        
        // Save Colors
        var index = 0
        while (index < newColors.count) {
            let color = newColors[index]
            let realColor = newColors[index + 1]
            
            index += 2
            currentProduct.selfRef.child("Colors/\(color)").setValue(realColor)
        }
        
        // Save Image
        if (imageChanged) {
            currentProduct.saveImage(imageLabel.image!, callback: doneSavingProduct)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Saving Button Callback after Image is uploaded to storage
    func doneSavingProduct() {
        removeLoadingSymbol(overallScrollView)
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Type Dropdown Elements
    @IBOutlet var chooseTypeButton: UIButton!
    @IBOutlet var chooseTypeLabel: UILabel!
    
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
        let sheet = createEmployeeColorMenu()
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            sheet.showFromRect(sender.frame, inView: self.view, animated: true)
        } else {
            sheet.showInView(self.view)
        }
    }
    
    override func colorCancelButton(sheet: UIActionSheet) {
        var index = 1
        while (index < newColors.count) {
            sheet.addButtonWithTitle(newColors[index] as String)
            index += 2
            cancelColorIndex += 1
        }
        
        // Cancel Button
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = cancelColorIndex
    }
    
    private func checkIndex(index: Int, alertView: UIAlertView) -> Bool {
        let isValidColor = (alertView.textFieldAtIndex(index) != nil &&
            alertView.textFieldAtIndex(index)!.text != nil &&
            alertView.textFieldAtIndex(index)!.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "")
        return isValidColor
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (alertView.tag == Constants.Colors.MenuTag) {
            if (checkIndex(0, alertView: alertView) && checkIndex(1, alertView: alertView)) {
                let color: String = alertView.textFieldAtIndex(1)!.text!
                let realColor: String = alertView.textFieldAtIndex(0)!.text!
                
                if (color.characters.count > 0 && realColor.characters.count > 0) {
                    newColors.append(color.capitalizedString)
                    newColors.append(realColor.capitalizedString)
                }
            }
        }
    }
    
    func createNewColorView() {
        let errorAlert = UIAlertView()
        errorAlert.title = "Enter New Color"
        errorAlert.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput
        errorAlert.tag = Constants.Colors.MenuTag
        errorAlert.delegate = self
        
        errorAlert.addButtonWithTitle("OK")
        errorAlert.addButtonWithTitle("Cancel")
        errorAlert.dismissWithClickedButtonIndex(0, animated: true)
        errorAlert.dismissWithClickedButtonIndex(1, animated: true)
        
        errorAlert.textFieldAtIndex(0)?.placeholder = "New Color"
        errorAlert.textFieldAtIndex(1)?.placeholder = "Overview Color i.e. Wine == Red"
        errorAlert.textFieldAtIndex(1)?.secureTextEntry = false
        
        errorAlert.show()
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet.tag == Constants.Colors.MenuTag) {
            // Add buttonup
            if (buttonIndex == 1) {
                createNewColorView()
            }
            else {
                actionSheetButtonClicked(actionSheet, buttonIndex: buttonIndex, view: chooseColorLabel)
            }
        }
        else if (actionSheet.tag == Constants.Types.MenuTag) {
            actionSheetButtonClicked(actionSheet, buttonIndex: buttonIndex, view: chooseTypeLabel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set description textView tag
        descriptionLabel.tag = Constants.Description.FieldTag
        
        // Add rounded border to title textview
        titleLabel.layer.borderColor = UIColor.lightGrayColor().CGColor
        titleLabel.layer.cornerRadius = 5
        titleLabel.layer.borderWidth = 1
        
        // Add dismissing keyboard by tapping
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(EditPagesViewController.dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }
    
    // Helper to move description text field up when clicked and
    // covered by the keyboard
    func animateDescriptionScrollView(view: UIScrollView, distanceLength: Int, up: Bool) {
        let duration = 0.3
        let distance = CGFloat(distanceLength) * (up ? 1 : -1)
        
        UIView.beginAnimations("animateDescriptionScrollView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(duration)
        self.view.frame = CGRectOffset(self.view.frame, 0, distance)
        UIView.commitAnimations()
    }
    
    // For Keyboard dismissal
    func dismissKeyboard() {
        view.endEditing(true)
        searchField.endEditing(true)
    }
}
