//
//  ColorInventory.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/13/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ColorInventory: NSObject {
    // Properties
    private var _color: UIColor?
    var colorName: String?
    var colorType: String
    var sizes: Array<Int>
    var barcodes: Array<String>
    var tag: Int
    
    // Creates an empty color inventory
    override init() {
        _color = UIColor.blackColor()
        colorName = nil
        colorType = "Shirt"
        sizes = [0, 0, 0, 0, 0]
        barcodes = ["", "", "", "", ""]
        tag = -1
    }
    
    // Creates a color inventory with no barcodes
    init(name: String, type: String, newSizes: Array<Int>) {
        _color = nil
        colorName = name
        colorType = type
        sizes = newSizes
        barcodes = ["", "", "", "", ""]
        tag = -1
    }
    
    // Creates a color inventory with a tag number but no barcodes
    init(newColor: UIColor, name: String, type: String, newSizes: Array<Int>, newTag: Int) {
        _color = newColor
        colorName = name
        colorType = type
        sizes = newSizes
        barcodes = ["", "", "", "", ""]
        tag = newTag
    }
    
    // Creates a color inventory with all data values provided by the caller
    init(newColor: UIColor, name: String, type: String, newSizes: Array<Int>, newBarcodes: Array<String>, newTag: Int) {
        _color = newColor
        colorName = name
        colorType = type
        sizes = newSizes
        barcodes = newBarcodes
        tag = newTag
    }
    
    // Creates and returns the new size dictionary
    var sizeDictionary: NSDictionary {
        let dict: NSMutableDictionary = [:]
        
        dict["XSmall"] = sizes[0]
        dict["Small"] = sizes[1]
        dict["Medium"] = sizes[2]
        dict["Large"] = sizes[3]
        dict["XLarge"] = sizes[4]
        
        return dict
    }
    
    // Uploads all of the current new barcodes to the database
    func addBarcodesToDatabase(dataRef: FIRDatabaseReference, productID: String) {
        var index = 0
        
        // Loops through each size name
        for size in Constants.Sizes.Names {
            addBarcodesHelper(size, index: index, productID: productID, dataRef: dataRef)
            index += 1
        }
    }
    
    // Helper for addBarcodesToDatabase
    // Checks and adds a given barcode
    private func addBarcodesHelper(size: String, index: Int, productID: String,
                                   dataRef: FIRDatabaseReference) {
        // Checks if this size's barcode exists
        if (barcodes[index] != "") {
            let ref = dataRef.child("barcodeIDs/\(barcodes[index])")
            ref.child("Color").setValue(colorName)
            ref.child("Product").setValue(productID)
            ref.child("Size").setValue(size)
        }
    }
    
    // Updates the sive inventory counts
    func updateSize(size: String, count: Int) {
        let index = Constants.Sizes.Names.indexOf(size)
        
        // Checks if the index is valid
        if index != nil {
            sizes[index!] = count
        }
    }
    
    // Loads the RGB color info from the database
    func loadUIColor(dataRef: FIRDatabaseReference, callback: (color: UIColor?) -> ()) {
        // Checks if the color exists
        if (colorName == nil) {
            callback(color: nil)
            return
        }
        
        // Access database for RGBA values
        dataRef.child("colors/\(colorName!)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists() {
                callback(color: nil)
                return
            }
            
            self._color = UIColor(red: CGFloat(snapshot.childSnapshotForPath("Red").value as! Float),
                green: CGFloat(snapshot.childSnapshotForPath("Green").value as! Float),
                blue: CGFloat(snapshot.childSnapshotForPath("Blue").value as! Float), alpha: 1)
      
            callback(color: self._color)
        })
    }
    
    // Returns the UIColor of the private color variable
    var color: UIColor? {
        return _color
    }
}
