//
//  AddNewColorViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/4/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker
import Firebase

class AddNewColorViewController: Helper, barcodeScannerCommunicator {
    // Properties
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var BarcodeFields: [UITextField]!
    @IBOutlet var selectedColor: UIButton!
    @IBOutlet var inventoryCountFields: [UITextField]!
    @IBOutlet weak var colorNameField: UITextField!
    @IBOutlet weak var chooseColorTypeButton: UIButton!
    
    // Holds the tag if this is a to-be-edited color
    var tag: Int = -1
    
    // Boolean to tell if the user is using a preexisting color
    // or should show the override alert
    var isUsingSelectedColor = false
    var selectedName: String? = nil
    
    // The colorInventory if this is a to-be-edited color
    var colorInventory: ColorInventory? = nil
    
    // Database reference
    var dataRef: FIRDatabaseReference? = nil
    
    // Holds the selected color when the user selects one from the
    // color picker
    var chosenColor: UIColor?

    // Holds the selected type when the user selects a color type
    var chosenType: String?

    // Callback to return the color to the addProduct view
    var callback:
        ((color: ColorInventory) -> ())? = nil

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
            colorName = colorName.capitalizedString
            
            if (colorName == "") {
                showErrorAlert("Error: Enter a Color Name", message: "Please enter a name for your new color.")
                return
            }
        }
        // Color Name field does not exist
        else {
            return
        }

        // Check if user is using a preexisting color
        if (isUsingSelectedColor) {
            sendColorToCallback(colorName)
            return
        }
        
        // Check if the color already exists in the database
        dataRef!.child("colors/\(colorName)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists() || snapshot.value == nil {
                self.addColorToDatabase(colorName)
                return
            }

            let currentColor = UIColor(red: CGFloat(snapshot.childSnapshotForPath("Red").value as! Float),
                green: CGFloat(snapshot.childSnapshotForPath("Green").value as! Float),
                blue: CGFloat(snapshot.childSnapshotForPath("Blue").value as! Float), alpha: 1)
            self.showOverrideAlert(colorName, currentColor: currentColor)
        })
    }
    
    // Helper for addColorButton function
    // Adds the new color to the database
    private func addColorToDatabase(name: String) {
        let type = self.chosenType ?? "Shirt"
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Get rgba values from the UIColor
        if !chosenColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            red = 1
            blue = 1
            green = 1
            alpha = 1
        }
        
        let colorDict: NSDictionary = ["Blue" : Float(blue), "Green" : Float(green),
                                   "Red" : Float(red), "Type" : type]
        self.dataRef!.child("colors/\(name)").setValue(colorDict)
        
        sendColorToCallback(name)
    }
    
    // Send selected color to callback
    private func sendColorToCallback(name: String) {
        var sizes = Array<Int>()
        var barcodes = Array<String>()
        
        for size in inventoryCountFields {
            sizes.append(Int(size.text!)!)
        }
        
        for barcode in BarcodeFields {
            barcodes.append(barcode.text!)
        }
        
        let inventory = ColorInventory(newColor: chosenColor!, name: name, type: chosenType!, newSizes: sizes, newBarcodes: barcodes, newTag: tag)
        callback!(color: inventory)
        navigationController?.popViewControllerAnimated(true)
        indicator?.removeFromSuperview()
    }

    // Helper for addColorButton function
    // Notifies the user if they are going to write over a previous color
    private func showOverrideAlert(name: String, currentColor: UIColor) {
        let alert = UIAlertController(title: "\(name) Color Override",
            message: "A color called \(name) already exists, do you really want to override it?",
            preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Use This Current Color", style: .Cancel) { action in
            self.sendColorToCallback(name)
        }
        let override = UIAlertAction(title: "Overwrite", style: .Destructive) { action in
            self.addColorToDatabase(name)
        }
        
        alert.addAction(override)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
        alert.view.tintColor = currentColor
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Uses SwiftHSVColorPicker maintained by johankasperi
    @IBAction func selectColorButtonPushed(sender: AnyObject) {
        showLoadingSymbol(chooseColorTypeButton)
        let colorPicker = storyboard?.instantiateViewControllerWithIdentifier("ColorPicker") as! ColorPickerViewController
        colorPicker.delegate = self
        navigationController?.pushViewController(colorPicker, animated: true)
    }
    
    @IBAction func chooseColorTypeButtonPushed(sender: AnyObject) {
        let sheet = UIAlertController(title: "Choose Type", message: nil, preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        var newButton: UIAlertAction? = nil
        
        // Add all of the color options
        for newType in Constants.Colors.Names {
            
            newButton = UIAlertAction(title: newType, style: .Default) { action in
                if self.chosenType != newType {
                    self.isUsingSelectedColor = false
                    self.presentColorsSheet(newType)
                }
                
                self.chosenType = newType
                self.chooseColorTypeButton.setTitle("Type: \(newType)", forState: .Normal)
            }
            
            sheet.addAction(newButton!)
        }

        sheet.addAction(cancel)
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
    @IBAction func xLargeScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        scanner.index = 4
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func largeScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        scanner.index = 3
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func mediumScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        scanner.index = 2
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func smallScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        scanner.index = 1
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func xSmallScanButtonPushed(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        scanner.index = 0
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    // Presents all of the current color options for that color
    private func presentColorsSheet(type: String) {
        showLoadingSymbol(chooseColorTypeButton)
        
        let sheet = UIAlertController(title: "Choose a \(type) Color", message: "These colors all already exist for the overview color \(type), feel free to choose one.", preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "No, Create New Color", style: .Cancel, handler: nil)
        var newButton: UIAlertAction? = nil
        
        dataRef!.child("colors").queryOrderedByChild("Type").queryEqualToValue(type)
            .observeEventType(.Value, withBlock: { snapshot in
        
            let dict = snapshot.value as? NSDictionary
            
            if (dict != nil) {
                for unconvertedKey in dict!.allKeys {
                    let title: String = unconvertedKey as? String != nil ?
                        unconvertedKey as! String : "error"
                    let key: NSDictionary? = dict?.objectForKey(unconvertedKey) as? NSDictionary
                    
                    if key != nil {
                        newButton = UIAlertAction(title: title, style: .Default) { action in
                            self.chosenColor = UIColor(red: CGFloat(key!.valueForKey("Red") as! Float),
                                green: CGFloat(key!.valueForKey("Green") as! Float),
                                blue: CGFloat(key!.valueForKey("Blue") as! Float), alpha: 1)
                            
                            self.selectedColor.backgroundColor = self.chosenColor
                            self.colorNameField.text = title
                            self.isUsingSelectedColor = true
                            self.selectedName = title
                        }
                        
                        sheet.addAction(newButton!)
                    }
                }
            }
        })
        
        self.indicator?.removeFromSuperview()
        sheet.addAction(cancel)
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
    
    // Called when a textField is selected for editing
    override func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.tag > 2) {
            animateScrollView(textField, distanceLength: 200, up: true)
        }
    }
    
    // Helper for the colorButtonActions method
    // Sets up the new view with the to-be-edited color values
    func addEditedColorValues() {
        tag = colorInventory!.tag
        chosenType = colorInventory!.colorType
        chosenColor = colorInventory!.color
        selectedColor.backgroundColor = colorInventory!.color
        colorNameField.text = colorInventory!.colorName
        chooseColorTypeButton.setTitle("Type: \(chosenType!)", forState: .Normal)
        
        // Set barcodes
        for (index, field) in BarcodeFields.enumerate() {
            if colorInventory?.barcodes[index] != "" {
                field.text = colorInventory?.barcodes[index]
            }
        }
        
        // Set inventory counts for sizes
        for (index, field) in inventoryCountFields.enumerate() {
            if colorInventory?.sizes[index] != 0 {
                field.text = String(colorInventory?.sizes[index])
            }
        }
    }
    
    // Function called by the color picker if a user selects
    // a new color
    func newSelectedColor(color: UIColor) {
        if (chosenColor == nil || !chosenColor!.isEqual(color)) {
            isUsingSelectedColor = false
        }
        
        chosenColor = color
        selectedColor.backgroundColor = color
        indicator?.removeFromSuperview()
    }
    
    // Function called by the barcode scanner when scan is completed
    func backFromBarcodeScanner(barcode: String?, index: Int) {
        if (barcode == nil) {
            BarcodeFields[index].text = "Could not find barcode"
        }
        else {
            BarcodeFields[index].text = barcode
        }
    }

    // Method that ensures false inventory counts are not input
    // Called when a textField is being edited and the Return key is pushed
    override func textFieldDidEndEditing(textField: UITextField) {
        if (textField.tag > 2) {
            animateScrollView(textField, distanceLength: 200, up: false)
        }
        
        // Not the same color if user edits the color name
        if (textField == colorNameField && textField.text != selectedName) {
            self.isUsingSelectedColor = false
        }
        
        // Test input inventory count or barcode
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

    override func viewDidLoad() {
        dismissTextFieldsByTapping()
        
        if colorInventory != nil {
            addEditedColorValues()
        }
    }
}
