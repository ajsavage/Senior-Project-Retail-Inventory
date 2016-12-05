//
//  AddNewColorViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/4/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class AddNewColorViewController: ShowProductViewController {
    // Properties
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var BarcodeFields: [UITextField]!
    @IBOutlet var inventoryCountFields: [UITextField]!
    @IBOutlet weak var colorNameField: UITextField!
    
    // Boolean to ensure that the color values are modified
    var colorPickerHasBeenUsed = false
    
    // Callback to return the color to the addProduct view
    var addProductCallback:
        ((color: UIColor, colorName: String, colorType: String, sizes: NSDictionary) -> ())? = nil

    // Button Actions
    @IBAction func addColorButton(sender: AnyObject) {
        showLoadingSymbol(addButton)
        
        // Ensure that the color RGB values have been chosen
        if (!colorPickerHasBeenUsed) {
            showErrorAlert("Error: Select a Color", message: "Please select RGB values for the new color by clicking on the colored square.")
            return
        }
        
        THINGS
        
        addProductCallback!(color: <#T##color: UIColor##UIColor#>, colorName: <#T##String#>, colorType: <#T##String#>, sizes: <#T##NSDictionary#>)
        navigationController?.popViewControllerAnimated(true)
        indicator?.removeFromSuperview()
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func selectColorButtonPushed(sender: AnyObject) {
        colorPickerHasBeenUsed = true
        
        A
    }
    
    @IBAction func chooseColorTypeButtonPushed(sender: AnyObject) {
    }
    
    @IBAction func xLargeScanButtonPushed(sender: AnyObject) {
    }
    
    @IBAction func largeScanButtonPushed(sender: AnyObject) {
    }
    
    @IBAction func mediumScanButtonPushed(sender: AnyObject) {
    }
    
    @IBAction func smallScanButtonPushed(sender: AnyObject) {
    }
    
    @IBAction func xSmallScanButtonPushed(sender: AnyObject) {
    }
    
    // Method that ensures false inventory counts are not input
    override func textFieldDidEndEditing(textField: UITextField) {
        var isInventoryField = false
        
        for field in inventoryCountFields {
            if textField == field {
                isInventoryField = true
            }
        }
        
        if isInventoryField {
            checkValues(textField, type: "Inventory Count")
        }
        else {
            var isBarcodeField = false
            
            for field in BarcodeFields {
                if textField == field {
                    isBarcodeField = true
                }
            }
            
            if isBarcodeField {
                checkValues(textField, type: "Barcode")
            }
        }
    }
    
    // Helper method for ensuring that the inventory count and the barcode 
    // fields are correctly filled out when the user is done editing them
    private func checkValues(textField: UITextField, type: String) {
        if textField.text != nil {
            let newInventory: Int? = Int(textField.text!)
            
            // Check if the value provided is not allowed
            if (newInventory == nil) {
                showErrorAlert("Invalid \(type) Entered", message:
                    "Please enter a valid integer.")
                textField.text = ""
                textField.becomeFirstResponder()
            }
            else if (newInventory < 0) {
                showErrorAlert("Invalid \(type) Entered", message:
                    "Please enter a value that is greater than zero.")
                textField.text = ""
                textField.becomeFirstResponder()
            }
        }
    }
}
