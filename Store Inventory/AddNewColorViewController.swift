//
//  AddNewColorViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/4/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker

class AddNewColorViewController: ShowProductViewController, barcodeScannerCommunicator {
    // Properties
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var BarcodeFields: [UITextField]!
    @IBOutlet var inventoryCountFields: [UITextField]!
    @IBOutlet weak var colorNameField: UITextField!
    @IBOutlet weak var chooseColorTypeButton: UIButton!
    
    // Holds the newest barcode received from the scanner
    var barcode: String? = nil
    
    // Holds the selected color when the user selects one from the
    // color picker
    var chosenColor: UIColor?

    // Holds the selected type when the user selects a color type
    var chosenType: String?

    // Callback to return the color to the addProduct view
    var addProductCallback:
        ((color: UIColor, colorName: String, colorType: String, sizes: NSDictionary) -> ())? = nil

    // Button Actions
    @IBAction func addColorButton(sender: AnyObject) {
        showLoadingSymbol(addButton)
        var colorName: String = ""
        
        // Ensure that the color RGB values have been chosen
        if (chosenColor == nil) {
            showErrorAlert("Error: Select a Color", message: "Please select RGB values for the new color by clicking on the colored square.")
            return
        }
        
        // Checks if the user has chosen a color type yet
        if (chosenType == nil) {
            showErrorAlert("Error: Select a Type", message: "Please select a color type.")
            return
        }
        
        // Checks if the user has entered a color name
        if (colorNameField.text != nil) {
            colorName = colorNameField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if (colorName == "") {
                showErrorAlert("Error: Enter a Color Name", message: "Please enter a name for your new color.")
                return
            }
        }
        // Color Name field does not exist
        else {
            return
        }
        
        addProductCallback!(color: chosenColor!, colorName: colorName, colorType: chosenType!, sizes: createSizeDictionary)
        navigationController?.popViewControllerAnimated(true)
        indicator?.removeFromSuperview()
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Uses SwiftHSVColorPicker maintained by johankasperi
    @IBAction func selectColorButtonPushed(sender: AnyObject) {
        let colorPicker = ColorPickerViewController()
        colorPicker.delegate = self
        self.presentViewController(colorPicker, animated: true, completion: nil)
    }
    
    @IBAction func chooseColorTypeButtonPushed(sender: AnyObject) {
        let sheet: UIActionSheet = UIActionSheet(title: "Choose Type",
                                                 delegate: self,
                                                 cancelButtonTitle: nil,
                                                 destructiveButtonTitle: nil)
        sheet.tag = Constants.Types.MenuTag
        
        for newType in Constants.Colors.Names {
            sheet.addButtonWithTitle(newType)
        }
        
        // Cancel button
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = Constants.Colors.Names.count
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            sheet.showFromRect(sender.frame, inView: self.view, animated: true)
        } else {
            sheet.showInView(self.view)
        }
    }
    
    @IBAction func xLargeScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func largeScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func mediumScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func smallScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func xSmallScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    // Function called by the barcode scanner when scan is completed
    func backFromBarcodeScanner(barcode: String?) {
        self.barcode = barcode
        
        if (barcode == nil) {
            self.barcode = "Could not find barcode (I think)"
        }
        
        BarcodeFields[0].text = self.barcode
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet.tag == Constants.Types.MenuTag) {
            if (buttonIndex != Constants.Colors.Names.count) {
                typeName = actionSheet.buttonTitleAtIndex(buttonIndex)!
                chooseColorTypeButton.setTitle("Type: \(typeName)", forState: .Normal)
            }
        }
    }
    
    // Creates and returns the new size dictionary
    private var createSizeDictionary: NSDictionary {
        let dict: NSMutableDictionary = [:]
        
        dict["XSmall"] = inventoryCountFields[0].text
        dict["Small"] = inventoryCountFields[1].text
        dict["Medium"] = inventoryCountFields[2].text
        dict["Large"] = inventoryCountFields[3].text
        dict["XLarge"] = inventoryCountFields[4].text
        
        return dict
    }
    
    // Method that ensures false inventory counts are not input
    func textFieldDidEndEditing(textField: UITextField) {
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
                let newBarcode = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                // Check if the value provided is not allowed
                if (newBarcode == nil || newBarcode == "") {
                    showErrorAlert("Invalid Barcode Entered", message:
                        "Please enter a valid barcode string.")
                    textField.text = ""
                    textField.becomeFirstResponder()
                }
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
                    "Please enter a valid integer, with no whitespace.")
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
    
    // For Keyboard dismissal
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        // Add dismissing keyboard by tapping
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(AddNewColorViewController.dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }
}
